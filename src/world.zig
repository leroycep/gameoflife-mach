const std = @import("std");
const zgpu = @import("zgpu");
const wgpu = zgpu.wgpu;

size: @Vector(2, u32),
generations: u64,
gctx: *zgpu.GraphicsContext,
compute_pipeline: zgpu.ComputePipelineHandle,
cell_textures: [2]zgpu.TextureHandle,
cell_bind_groups: [2]zgpu.BindGroupHandle,

const World = @This();

pub const TILE_SIZE = @Vector(2, u32){ 8, 4 };
const Tile = [4]@Vector(8, u1);

comptime {
    std.debug.assert(@sizeOf(@Vector(8, u1)) == 1);
    std.debug.assert(@sizeOf(Tile) == 4);
}

pub fn init(this: *@This(), gctx: *zgpu.GraphicsContext, size: @Vector(2, u32)) !void {
    if (size[0] % TILE_SIZE[0] != 0 or size[1] % TILE_SIZE[1] != 0) {
        return error.MultipleOfTileSize;
    }

    const update_cells_shader_module = zgpu.util.createWgslShaderModule(gctx.device, @embedFile("update_cells.wgsl"), "compute update cells");
    defer update_cells_shader_module.release();

    const compute_pipeline_layout = gctx.createPipelineLayout(&.{});

    const compute_pipeline_descriptor = wgpu.ComputePipelineDescriptor{ .compute = wgpu.ProgrammableStageDescriptor{
        .module = update_cells_shader_module,
        .entry_point = "main",
    } };

    const compute_pipeline = gctx.createComputePipeline(compute_pipeline_layout, compute_pipeline_descriptor);

    // Create the buffers that will represent the cells
    const cell_texture_size = wgpu.Extent3D{
        .width = size[0],
        .height = size[1],
    };
    const cell_texture_descriptor = wgpu.TextureDescriptor{
        .format = .rgba8_uint,
        .usage = .{
            .copy_src = true,
            .copy_dst = true,
            .storage_binding = true,
            .texture_binding = true,
        },
        .size = cell_texture_size,
    };

    var cell_textures = [2]zgpu.TextureHandle{
        gctx.createTexture(cell_texture_descriptor),
        gctx.createTexture(cell_texture_descriptor),
    };

    const cell_texture_views = [2]zgpu.TextureViewHandle{
        gctx.createTextureView(cell_textures[0], .{}),
        gctx.createTextureView(cell_textures[1], .{}),
    };

    // Create 2 bind groups. The first bind group is { cell_buffers[0], cell_buffers[1] }, and the second is { cell_buffers[1], cell_buffers[0] }.
    // This enables "double buffering" the cells when updating.
    const bind_group_layout = gctx.createBindGroupLayout(&.{
        zgpu.bglTexture(0, .{ .compute = true }, .uint, .tvdim_2d, false),
        zgpu.bglStorageTexture(1, .{ .compute = true }, .write_only, .rgba8_uint, .tvdim_2d),
    });

    defer gctx.releaseResource(bind_group_layout);
    var cell_bind_groups: [2]zgpu.BindGroupHandle = undefined;
    for (cell_bind_groups) |*bind_group, i| {
        bind_group.* = gctx.createBindGroup(bind_group_layout, &.{
            .{ .binding = 0, .texture_view_handle = cell_texture_views[i] },
            .{ .binding = 0, .texture_view_handle = cell_texture_views[(i + 1) % 2] },
        });
    }

    this.* = .{
        .size = size,
        .generations = 0,
        .gctx = gctx,
        .compute_pipeline = compute_pipeline,
        .cell_textures = cell_textures,
        .cell_bind_groups = cell_bind_groups,
    };
}

pub fn deinit(_: *@This(), _: *zgpu.GraphicsContext) void {}

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

pub fn set(this: *@This(), src: []const Tile) !void {
    const texture_size = @divExact(this.size, TILE_SIZE);
    std.debug.assert(src.len == texture_size[0] * texture_size[1]);

    const texture_extents = wgpu.Extent3D{ .width = texture_size[0], .height = texture_size[1] };
    this.gctx.queue.writeTexture(
        .{ .texture = this.gctx.lookupResource(this.cell_textures[this.generations % 2]).? },
        .{
            .bytes_per_row = texture_size[0] * @sizeOf(Tile),
            .rows_per_image = texture_size[1],
        },
        texture_extents,
        Tile,
        src,
    );
}

pub fn get(this: *@This(), gctx: *zgpu.GraphicsContext) void {
    const texture_size = @divExact(this.size, TILE_SIZE);

    comptime std.debug.assert(@sizeOf(@Vector(8, u1)) == 1);

    const download = gctx.createBuffer(&.{
        .size = texture_size[0] * texture_size[1] * @sizeOf(Tile),
        .usage = .{
            .copy_dst = true,
            .map_read = true,
        },
        .mapped_at_creation = false,
    });
    //gpu.Buffer.MapCallback.init(void, {}, textureReadCallback);
    const encoder = gctx.createCommandEncoder(&.{ .label = @src().fn_name });
    encoder.copyTextureToBuffer(this.cell_textures[(this.generations + 1) % 2], &download);

    const commands = encoder.finish();
    encoder.release();

    gctx.queue.submit(commands);
    commands.release();

    download.mapAsync();
}

pub fn step(this: *@This(), command_encoder: wgpu.CommandEncoder) !void {
    const pass_encoder = command_encoder.beginComputePass(null);
    pass_encoder.setPipeline(this.gctx.lookupResource(this.compute_pipeline).?);
    pass_encoder.setBindGroup(0, this.gctx.lookupResource(this.cell_bind_groups[this.generations % 2]).?, null);
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
    pub fn @"reference example: square is stable"(_: std.mem.Allocator, _: *zgpu.GraphicsContext) !void {
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

    pub fn @"reference example: line spins"(_: std.mem.Allocator, _: *zgpu.GraphicsContext) !void {
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

    pub fn @"example: square is stable"(_: std.mem.Allocator, gctx: *zgpu.GraphicsContext) !void {
        const square = [4]@Vector(8, u1){
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
            .{ 0, 0, 0, 1, 1, 0, 0, 0 },
            .{ 0, 0, 0, 1, 1, 0, 0, 0 },
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
        };
        try expectGrid(gctx, .{ 1, 1 }, &.{square}, &.{square});
    }

    pub fn @"example: line spins"(_: std.mem.Allocator, gctx: *zgpu.GraphicsContext) !void {
        const input = [4]@Vector(8, u1){
            .{ 0, 1, 0, 0, 0, 0, 0, 0 },
            .{ 0, 1, 0, 0, 0, 0, 0, 0 },
            .{ 0, 1, 0, 0, 0, 0, 0, 0 },
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
        };
        const output = [4]@Vector(8, u1){
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
            .{ 1, 1, 1, 0, 0, 0, 0, 0 },
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
            .{ 0, 0, 0, 0, 0, 0, 0, 0 },
        };
        try expectGrid(gctx, .{ 1, 1 }, &.{input}, &.{output});
    }

    pub fn @"webgpu impl matches reference"(allocator: std.mem.Allocator, gctx: *zgpu.GraphicsContext) !void {
        var rng = std.rand.DefaultPrng.init(0);
        const random = rng.random();

        // Choose a random size
        const size_tiles = @Vector(2, u32){
            random.intRangeAtMost(u32, 1, 100),
            random.intRangeAtMost(u32, 1, 200),
        };
        const size = size_tiles * TILE_SIZE;

        // Generate initial grid
        const cells_initial = try allocator.alloc(u1, @intCast(usize, size[0] * size[1]));
        defer allocator.free(cells_initial);
        for (cells_initial) |*cell| {
            cell.* = random.int(u1);
        }

        // Run reference implementation
        const cells_after = try allocator.alloc(u1, @intCast(usize, size[0] * size[1]));
        defer allocator.free(cells_after);
        reference_impl_step(@intCast(@Vector(2, i32), size), cells_initial, cells_after);

        // Setup webgpu version
        const tiles_initial = try allocator.alloc(Tile, @intCast(usize, size_tiles[0] * size_tiles[1]));
        defer allocator.free(tiles_initial);
        tilesFromU1Slice(size, cells_initial, tiles_initial);

        const tiles_expected = try allocator.alloc(Tile, @intCast(usize, size_tiles[0] * size_tiles[1]));
        defer allocator.free(tiles_expected);
        tilesFromU1Slice(size, cells_after, tiles_expected);

        try expectGrid(gctx, size_tiles, tiles_expected, tiles_initial);
    }
};

pub fn expectGrid(gctx: *zgpu.GraphicsContext, size_tiles: @Vector(2, u32), tiles_expected: []const Tile, tiles_initial: []const Tile) !void {
    const size = size_tiles * TILE_SIZE;

    var world: World = undefined;
    try world.init(gctx, size);
    try world.set(tiles_initial);

    {
        const command_encoder = gctx.device.createCommandEncoder(null);
        try world.step(command_encoder);

        const command = command_encoder.finish(null);
        command_encoder.release();
        gctx.queue.submit(&.{command});
        command.release();
    }

    // download cells from gpu
    {
        // When copying a texture into a buffer, `bytes_per_row` *must* be a multiple of `256`.
        // Here we do the math
        const download_bytes_per_row = ((size_tiles[0] * @sizeOf(Tile) / 256) + 1) * 256;
        const download = gctx.createBuffer(.{
            .size = download_bytes_per_row * size_tiles[1],
            .usage = .{
                .copy_dst = true,
                .map_read = true,
            },
            .mapped_at_creation = false,
        });

        const download_copy_buffer_desc = wgpu.ImageCopyBuffer{
            .layout = .{
                .bytes_per_row = download_bytes_per_row,
                .rows_per_image = size_tiles[1],
            },
            .buffer = gctx.lookupResource(download).?,
        };

        const encoder = gctx.device.createCommandEncoder(wgpu.CommandEncoderDescriptor{ .label = @src().fn_name });
        encoder.copyTextureToBuffer(
            .{ .texture = gctx.lookupResource(world.cell_textures[world.generations % 2]).? },
            download_copy_buffer_desc,
            .{ .width = size_tiles[0], .height = size_tiles[1] },
        );

        const commands = encoder.finish(null);
        encoder.release();

        gctx.queue.submit(&.{commands});
        commands.release();

        std.debug.print("{s}:{}\n", .{ @src().fn_name, @src().line });
        var ret_val: ?wgpu.BufferMapAsyncStatus = null;
        gctx.lookupResource(download).?.mapAsync(.{ .read = true }, 0, download_bytes_per_row * size_tiles[1], setStatusPtrCallback, &ret_val);
        while (true) {
            if (ret_val == null) {
                gctx.device.tick();
            } else {
                break;
            }
        }
        std.debug.print("{s}:{} ret_val = {?}\n", .{ @src().fn_name, @src().line, ret_val });
        defer gctx.lookupResource(download).?.unmap();
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
            const tiles_row = gctx.lookupResource(download).?.getConstMappedRange(Tile, y * download_bytes_per_row, size_tiles[0]).?;
            try std.testing.expectEqualSlices(Tile, tiles_expected[0..size_tiles[0]], tiles_row);
        }
        std.debug.print("{s}:{}\n", .{ @src().fn_name, @src().line });
    }
}

fn setStatusPtrCallback(status: wgpu.BufferMapAsyncStatus, userdata: ?*anyopaque) callconv(.C) void {
    const status_ptr = @ptrCast(*?wgpu.BufferMapAsyncStatus, @alignCast(@alignOf(*?wgpu.BufferMapAsyncStatus), userdata.?));
    status_ptr.* = status;
}
