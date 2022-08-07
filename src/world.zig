const std = @import("std");
const mach = @import("mach");
const gpu = @import("gpu");

size: @Vector(2, u32),
generations: u64,
compute_pipeline: gpu.ComputePipeline,
cell_textures: [2]gpu.Texture,
cell_bind_groups: [2]gpu.BindGroup,

const World = @This();

pub const TILE_SIZE = @Vector(2, u32){ 8, 4 };
const Tile = [4]@Vector(8, u1);

comptime {
    std.debug.assert(@sizeOf(@Vector(8, u1)) == 1);
    std.debug.assert(@sizeOf(Tile) == 4);
}

pub fn init(this: *@This(), core: *mach.Core, size: @Vector(2, u32)) !void {
    if (size[0] % TILE_SIZE[0] != 0 or size[1] % TILE_SIZE[1] != 0) {
        return error.MultipleOfTileSize;
    }

    const update_cells_shader_module = core.device.createShaderModule(&.{
        .label = "update cells shader module",
        .code = .{ .wgsl = @embedFile("update_cells.wgsl") },
    });

    const compute_pipeline = core.device.createComputePipeline(&gpu.ComputePipeline.Descriptor{ .compute = gpu.ProgrammableStageDescriptor{
        .module = update_cells_shader_module,
        .entry_point = "main",
    } });

    // Create the buffers that will represent the cells
    var cell_textures: [2]gpu.Texture = undefined;
    const cell_texture_size = gpu.Extent3D{
        .width = size[0],
        .height = size[1],
    };
    for (cell_textures) |*texture| {
        texture.* = core.device.createTexture(&gpu.Texture.Descriptor{
            .format = .rgba8_uint,
            .usage = .{
                .copy_src = true,
                .copy_dst = true,
                .storage_binding = true,
                .texture_binding = true,
            },
            .size = cell_texture_size,
        });
    }

    // Create 2 bind groups. The first bind group is { cell_buffers[0], cell_buffers[1] }, and the second is { cell_buffers[1], cell_buffers[0] }.
    // This enables "double buffering" the cells when updating.
    var cell_bind_groups: [2]gpu.BindGroup = undefined;
    for (cell_bind_groups) |*bind_group, i| {
        bind_group.* = core.device.createBindGroup(&gpu.BindGroup.Descriptor{
            .layout = compute_pipeline.getBindGroupLayout(0),
            .entries = &[_]gpu.BindGroup.Entry{
                gpu.BindGroup.Entry.textureView(0, cell_textures[i].createView(&gpu.TextureView.Descriptor{})),
                gpu.BindGroup.Entry.textureView(1, cell_textures[(i + 1) % 2].createView(&gpu.TextureView.Descriptor{})),
            },
        });
    }

    this.* = .{
        .size = size,
        .generations = 0,
        .compute_pipeline = compute_pipeline,
        .cell_textures = cell_textures,
        .cell_bind_groups = cell_bind_groups,
    };
}

pub fn deinit(_: *@This(), _: *mach.Core) void {}

pub fn tilesFromU1Slice(size: @Vector(2, u32), src: []const u1, out: []Tile) void {
    std.debug.assert(src.len == size[0] * size[1]);
    std.debug.assert(size[0] % TILE_SIZE[0] == 0 or size[1] % TILE_SIZE[1] == 0);

    const texture_size = @divExact(size, TILE_SIZE);
    std.debug.assert(out.len == texture_size[0] * texture_size[1]);

    var texel_pos = @Vector(2, u32){ 0, 0 };
    while (texel_pos[1] < texture_size[1]) : (texel_pos[1] += 1) {
        texel_pos[0] = 0;
        while (texel_pos[0] < texture_size[0]) : (texel_pos[0] += 1) {
            const texel_idx = texel_pos[1] * texture_size[0] + texel_pos[0];

            var row: u32 = 0;
            while (row < TILE_SIZE[1]) : (row += 1) {
                const src_pos = texel_pos * TILE_SIZE + @Vector(2, u32){ 0, row };
                const src_idx = @intCast(u32, src_pos[1] * size[0] + src_pos[0]);
                out[texel_idx][row] = src[src_idx..][0..TILE_SIZE[0]].*;
            }
        }
    }
}

pub fn set(this: *@This(), core: *mach.Core, src: []const Tile) !void {
    const texture_size = @divExact(this.size, TILE_SIZE);
    std.debug.assert(src.len == texture_size[0] * texture_size[1]);

    const texture_extents = gpu.Extent3D{ .width = texture_size[0], .height = texture_size[1] };
    core.device.getQueue().writeTexture(
        &.{ .texture = this.cell_textures[this.generations % 2] },
        &.{
            .bytes_per_row = texture_size[0] * @sizeOf(Tile),
            .rows_per_image = texture_size[1],
        },
        &texture_extents,
        Tile,
        src,
    );
}

pub fn get(this: *@This(), core: *mach.Core) void {
    const texture_size = @divExact(this.size, TILE_SIZE);

    comptime std.debug.assert(@sizeOf(@Vector(8, u1)) == 1);

    const download = core.device.createBuffer(&.{
        .size = texture_size[0] * texture_size[1] * @sizeOf(Tile),
        .usage = .{
            .copy_dst = true,
            .map_read = true,
        },
        .mapped_at_creation = false,
    });
    //gpu.Buffer.MapCallback.init(void, {}, textureReadCallback);
    const encoder = core.device.createCommandEncoder(&.{ .label = @src().fn_name });
    encoder.copyTextureToBuffer(this.cell_textures[(this.generations + 1) % 2], &download);

    const commands = encoder.finish();
    encoder.release();

    core.device.getQueue().submit(commands);
    commands.release();

    download.mapAsync();
}

pub fn step(this: *@This(), command_encoder: gpu.CommandEncoder) !void {
    const pass_encoder = command_encoder.beginComputePass(null);
    pass_encoder.setPipeline(this.compute_pipeline);
    pass_encoder.setBindGroup(0, this.cell_bind_groups[this.generations % 2], null);
    pass_encoder.dispatch(this.size[0], this.size[1], 1);
    pass_encoder.end();
    pass_encoder.release();
    this.generations += 1;
}

const ZERO = @Vector(2, i32){ 0, 0 };
fn reference_impl_step(size: @Vector(2, i32), cellsIn: []const u1, cellsOut: []u1) void {
    std.debug.assert(size[0] > 0 and size[1] > 0);
    std.debug.assert(cellsIn.len == size[0] * size[1]);
    std.debug.assert(cellsIn.len == cellsOut.len);

    var pos = @Vector(2, i32){ 0, 0 };
    while (pos[1] < size[1]) : (pos[1] += 1) {
        pos[0] = 0;
        while (pos[0] < size[0]) : (pos[0] += 1) {
            var neighbors: u32 = 0;
            var off = @Vector(2, i32){ -1, -1 };
            while (off[1] <= 1) : (off[1] += 1) {
                off[0] = -1;
                while (off[0] <= 1) : (off[0] += 1) {
                    if (off[0] == 0 and off[1] == 0) {
                        continue;
                    }
                    const neigh_pos = pos + off;
                    if (@reduce(.Or, neigh_pos < ZERO) or
                        @reduce(.Or, neigh_pos >= size))
                    {
                        continue;
                    }
                    const index = @intCast(u32, neigh_pos[1] * size[0] + neigh_pos[0]);
                    neighbors += cellsIn[index];
                }
            }

            const index = @intCast(u32, pos[1] * size[0] + pos[0]);
            switch (neighbors) {
                0...1 => cellsOut[index] = 0,
                2 => cellsOut[index] = cellsIn[index],
                3 => cellsOut[index] = 1,
                4...8 => cellsOut[index] = 0,
                else => unreachable,
            }
        }
    }
}

pub const tests = struct {
    pub fn @"reference example: square is stable"(_: *mach.Core) !void {
        const size = @Vector(2, i32){ 4, 4 };
        const input = &[_]u1{
            0, 0, 0, 0,
            0, 1, 1, 0,
            0, 1, 1, 0,
            0, 0, 0, 0,
        };
        var output: [input.len]u1 = undefined;
        reference_impl_step(size, input, &output);
        try std.testing.expectEqualSlices(u1, input, &output);
    }

    pub fn @"reference example: line spins"(_: *mach.Core) !void {
        const size = @Vector(2, i32){ 3, 3 };
        const input = &[_]u1{
            0, 0, 0,
            1, 1, 1,
            0, 0, 0,
        };
        var output: [input.len]u1 = undefined;
        reference_impl_step(size, input, &output);
        try std.testing.expectEqualSlices(u1, &[_]u1{
            0, 1, 0,
            0, 1, 0,
            0, 1, 0,
        }, &output);
    }

    pub fn @"webgpu impl matches reference"(core: *mach.Core) !void {
        var rng = std.rand.DefaultPrng.init(0);
        const random = rng.random();

        // Choose a random size
        const size_tiles = @Vector(2, u32){
            random.intRangeAtMost(u32, 1, 100),
            random.intRangeAtMost(u32, 1, 200),
        };
        const size = size_tiles * TILE_SIZE;

        // Generate initial grid
        const cells_initial = try core.allocator.alloc(u1, @intCast(usize, size[0] * size[1]));
        defer core.allocator.free(cells_initial);
        for (cells_initial) |*cell| {
            cell.* = random.int(u1);
        }

        // Run reference implementation
        const cells_after = try core.allocator.alloc(u1, @intCast(usize, size[0] * size[1]));
        defer core.allocator.free(cells_after);
        reference_impl_step(@intCast(@Vector(2, i32), size), cells_initial, cells_after);

        // Setup webgpu version
        const tiles = try core.allocator.alloc(Tile, @intCast(usize, size_tiles[0] * size_tiles[1]));
        defer core.allocator.free(tiles);
        tilesFromU1Slice(size, cells_initial, tiles);

        const tiles_expected = try core.allocator.alloc(Tile, @intCast(usize, size_tiles[0] * size_tiles[1]));
        defer core.allocator.free(tiles_expected);
        tilesFromU1Slice(size, cells_after, tiles_expected);

        var world: World = undefined;
        try world.init(core, size);
        try world.set(core, tiles);

        {
            const command_encoder = core.device.createCommandEncoder(null);
            try world.step(command_encoder);

            const command = command_encoder.finish(null);
            command_encoder.release();
            core.device.getQueue().submit(&.{command});
            command.release();
        }

        // download cells from gpu
        {
            // When copying a texture into a buffer, `bytes_per_row` *must* be a multiple of `256`.
            // Here we do the math
            const download_bytes_per_row = ((size_tiles[0] * @sizeOf(Tile) / 256) + 1) * 256;
            const download = core.device.createBuffer(&.{
                .size = download_bytes_per_row * size_tiles[1],
                .usage = .{
                    .copy_dst = true,
                    .map_read = true,
                },
                .mapped_at_creation = false,
            });

            const download_copy_buffer_desc = gpu.ImageCopyBuffer{
                .layout = .{
                    .bytes_per_row = download_bytes_per_row,
                    .rows_per_image = size_tiles[1],
                },
                .buffer = download,
            };

            const encoder = core.device.createCommandEncoder(&.{ .label = @src().fn_name });
            encoder.copyTextureToBuffer(
                &.{ .texture = world.cell_textures[world.generations % 2] },
                &download_copy_buffer_desc,
                &.{ .width = size_tiles[0], .height = size_tiles[1] },
            );

            const commands = encoder.finish(null);
            encoder.release();

            core.device.getQueue().submit(&.{commands});
            commands.release();

            std.debug.print("{s}:{}\n", .{ @src().fn_name, @src().line });
            var ret_val: ?gpu.Buffer.MapAsyncStatus = null;
            var callback = gpu.Buffer.MapCallback.init(*?gpu.Buffer.MapAsyncStatus, &ret_val, setStatusPtrCallback);
            download.mapAsync(.read, 0, download_bytes_per_row * size_tiles[1], &callback);
            while (true) {
                if (ret_val == null) {
                    core.device.tick();
                } else {
                    break;
                }
            }
            std.debug.print("{s}:{} ret_val = {?}\n", .{ @src().fn_name, @src().line, ret_val });
            defer download.unmap();
            if (ret_val) |code| {
                switch (code) {
                    .success => {},
                    else => |err| {
                        std.log.err("Error downloading cell texture {}", .{err});
                        return error.Download;
                    },
                }
            }

            std.debug.print("{s}:{}\n", .{ @src().fn_name, @src().line });
            var y: u32 = 0;
            while (y < size_tiles[1]) : (y += 1) {
                errdefer std.debug.print("y = {}\n\n", .{y});
                const tiles_row = download.getConstMappedRange(Tile, y * download_bytes_per_row, size_tiles[0]);
                try std.testing.expectEqualSlices(Tile, tiles_expected[0..size_tiles[0]], tiles_row);
            }
            std.debug.print("{s}:{}\n", .{ @src().fn_name, @src().line });
        }
    }
};

fn setStatusPtrCallback(status_ptr: *?gpu.Buffer.MapAsyncStatus, status: gpu.Buffer.MapAsyncStatus) void {
    status_ptr.* = status;
}
