const std = @import("std");
const mach = @import("mach");
const gpu = @import("gpu");
const World = @import("./world.zig");

world: World,
render_pipeline: gpu.RenderPipeline,
sprite_vertex_buffer: gpu.Buffer,
render_bind_groups: [2]gpu.BindGroup,
frame_counter: usize,

pub const App = @This();

const WIDTH = 1024;
const HEIGHT = 1024;

const TileElemType = [4]u8;

comptime {
    std.debug.assert(@sizeOf(TileElemType) == 4);
}

pub fn init(app: *App, core: *mach.Core) !void {
    var world: World = undefined;
    try world.init(core, .{ WIDTH, HEIGHT });

    // Create a buffer that initializes the cells to a random value
    var initial_cell_data: [WIDTH * HEIGHT]World.Tile = undefined;
    var rng = std.rand.DefaultPrng.init(0);
    const random = rng.random();
    for (initial_cell_data) |*cell| {
        random.bytes(std.mem.asBytes(cell));
    }
    try world.set(core, &initial_cell_data);

    const sprite_shader_module = core.device.createShaderModule(&.{
        .label = "render cells shader module",
        .code = .{ .wgsl = @embedFile("render_cells.wgsl") },
    });

    const vertex_buffer_attributes = [_]gpu.VertexAttribute{
        .{
            // vertex positions
            .shader_location = 0,
            .offset = 0,
            .format = .float32x2,
        },
    };

    const render_pipeline = core.device.createRenderPipeline(&gpu.RenderPipeline.Descriptor{
        .vertex = .{
            .module = sprite_shader_module,
            .entry_point = "vert_main",
            .buffers = &[_]gpu.VertexBufferLayout{
                .{
                    // vertex buffer
                    .array_stride = 2 * @sizeOf(f32),
                    .step_mode = .vertex,
                    .attribute_count = vertex_buffer_attributes.len,
                    .attributes = &vertex_buffer_attributes,
                },
            },
        },
        .fragment = &gpu.FragmentState{ .module = sprite_shader_module, .entry_point = "frag_main", .targets = &[_]gpu.ColorTargetState{
            .{
                .format = core.swap_chain_format,
            },
        } },
    });

    const vert_buffer_data = [_]f32{
        -1, -1,
        1,  -1,
        -1, 1,

        1,  -1,
        1,  1,
        -1, 1,
    };

    const sprite_vertex_buffer = core.device.createBuffer(&gpu.Buffer.Descriptor{
        .usage = .{ .vertex = true, .copy_dst = true },
        .size = vert_buffer_data.len * @sizeOf(f32),
    });
    core.device.getQueue().writeBuffer(sprite_vertex_buffer, 0, f32, &vert_buffer_data);

    var render_bind_groups: [2]gpu.BindGroup = undefined;
    for (render_bind_groups) |*bind_group, i| {
        bind_group.* = core.device.createBindGroup(&gpu.BindGroup.Descriptor{
            .layout = render_pipeline.getBindGroupLayout(0),
            .entries = &[_]gpu.BindGroup.Entry{
                gpu.BindGroup.Entry.textureView(0, world.cell_textures[i].createView(&gpu.TextureView.Descriptor{})),
            },
        });
    }

    app.* = .{
        .world = world,
        .render_pipeline = render_pipeline,
        .sprite_vertex_buffer = sprite_vertex_buffer,
        .render_bind_groups = render_bind_groups,
        .frame_counter = 0,
    };
}

pub fn deinit(_: *App, _: *mach.Core) void {}

pub fn update(app: *App, core: *mach.Core) !void {
    const back_buffer_view = core.swap_chain.?.getCurrentTextureView();
    const color_attachment = gpu.RenderPassColorAttachment{
        .view = back_buffer_view,
        .resolve_target = null,
        .clear_value = std.mem.zeroes(gpu.Color),
        .load_op = .clear,
        .store_op = .store,
    };

    const render_pass_descriptor = gpu.RenderPassEncoder.Descriptor{ .color_attachments = &[_]gpu.RenderPassColorAttachment{
        color_attachment,
    } };

    const command_encoder = core.device.createCommandEncoder(null);
    try app.world.step(command_encoder);
    {
        const pass_encoder = command_encoder.beginRenderPass(&render_pass_descriptor);
        pass_encoder.setPipeline(app.render_pipeline);
        pass_encoder.setBindGroup(0, app.render_bind_groups[app.world.generations % 2], null);
        pass_encoder.setVertexBuffer(0, app.sprite_vertex_buffer, 0, 12 * @sizeOf(f32));
        pass_encoder.draw(6, 1, 0, 0);
        pass_encoder.end();
        pass_encoder.release();
    }

    app.frame_counter += 1;
    if (app.frame_counter % 60 == 0) {
        std.log.info("Frame {}", .{app.frame_counter});
    }

    var command = command_encoder.finish(null);
    command_encoder.release();
    core.device.getQueue().submit(&.{command});
    command.release();

    core.swap_chain.?.present();
    back_buffer_view.release();
}
