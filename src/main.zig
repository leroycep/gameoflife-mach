const std = @import("std");
const mach = @import("mach");
const gpu = @import("gpu");

compute_pipeline: gpu.ComputePipeline,
render_pipeline: gpu.RenderPipeline,
sprite_vertex_buffer: gpu.Buffer,
cell_textures: [2]gpu.Texture,
cell_bind_groups: [2]gpu.BindGroup,
render_bind_groups: [2]gpu.BindGroup,
frame_counter: usize,

pub const App = @This();

const WIDTH = 640;
const HEIGHT = 480;

const SIZE = [_]u32{ WIDTH, HEIGHT };
const CellElemType = u32;

pub fn init(app: *App, core: *mach.Core) !void {
    const sprite_shader_module = core.device.createShaderModule(&.{
        .label = "render cells shader module",
        .code = .{ .wgsl = @embedFile("render_cells.wgsl") },
    });

    const update_cells_shader_module = core.device.createShaderModule(&.{
        .label = "update cells shader module",
        .code = .{ .wgsl = @embedFile("update_cells.wgsl") },
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

    const compute_pipeline = core.device.createComputePipeline(&gpu.ComputePipeline.Descriptor{ .compute = gpu.ProgrammableStageDescriptor{
        .module = update_cells_shader_module,
        .entry_point = "main",
    } });

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

    // Create a buffer that initializes the cells to a random value
    var initial_cell_data: [WIDTH * HEIGHT]CellElemType = undefined;
    var rng = std.rand.DefaultPrng.init(0);
    const random = rng.random();
    for (initial_cell_data) |*cell| {
        cell.* = random.int(u1);
    }

    // Create the buffers that will represent the cells
    var cell_textures: [2]gpu.Texture = undefined;
    const cell_texture_size = gpu.Extent3D{ .width = WIDTH, .height = HEIGHT };
    for (cell_textures) |*texture| {
        texture.* = core.device.createTexture(&gpu.Texture.Descriptor{
            .format = .r32_uint,
            .usage = .{
                .copy_dst = true,
                .storage_binding = true,
                .texture_binding = true,
            },
            .size = cell_texture_size,
        });
        core.device.getQueue().writeTexture(
            &.{ .texture = texture.* },
            &.{ .bytes_per_row = WIDTH * @sizeOf(CellElemType), .rows_per_image = HEIGHT },
            &cell_texture_size,
            CellElemType,
            &initial_cell_data,
        );
    }

    // Create 2 bind groups. The first bind group is { cell_buffers[0], cell_buffers[1] }, and the second is { cell_buffers[1], cell_buffers[0] }.
    // This enables "double buffering" the cells when updating.
    var cell_bind_groups: [2]gpu.BindGroup = undefined;
    for (cell_bind_groups) |*bind_group, i| {
        bind_group.* = core.device.createBindGroup(&gpu.BindGroup.Descriptor{ .layout = compute_pipeline.getBindGroupLayout(0), .entries = &[_]gpu.BindGroup.Entry{
            gpu.BindGroup.Entry.textureView(0, cell_textures[i].createView(&gpu.TextureView.Descriptor{})),
            gpu.BindGroup.Entry.textureView(1, cell_textures[(i + 1) % 2].createView(&gpu.TextureView.Descriptor{})),
        } });
    }

    var render_bind_groups: [2]gpu.BindGroup = undefined;
    for (render_bind_groups) |*bind_group, i| {
        bind_group.* = core.device.createBindGroup(&gpu.BindGroup.Descriptor{
            .layout = render_pipeline.getBindGroupLayout(0),
            .entries = &[_]gpu.BindGroup.Entry{
                gpu.BindGroup.Entry.textureView(0, cell_textures[i].createView(&gpu.TextureView.Descriptor{})),
            },
        });
    }

    app.compute_pipeline = compute_pipeline;
    app.render_pipeline = render_pipeline;
    app.sprite_vertex_buffer = sprite_vertex_buffer;
    app.cell_textures = cell_textures;
    app.cell_bind_groups = cell_bind_groups;
    app.render_bind_groups = render_bind_groups;
    app.frame_counter = 0;
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
    {
        const pass_encoder = command_encoder.beginComputePass(null);
        pass_encoder.setPipeline(app.compute_pipeline);
        pass_encoder.setBindGroup(0, app.cell_bind_groups[app.frame_counter % 2], null);
        pass_encoder.dispatch(WIDTH, HEIGHT, 1);
        pass_encoder.end();
        pass_encoder.release();
    }
    {
        const pass_encoder = command_encoder.beginRenderPass(&render_pass_descriptor);
        pass_encoder.setPipeline(app.render_pipeline);
        pass_encoder.setBindGroup(0, app.render_bind_groups[(app.frame_counter + 1) % 2], null);
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
