const std = @import("std");
const glfw = @import("glfw");
const zgpu = @import("zgpu");

const world = @import("./world.zig");

pub fn main() !void {
    try glfw.init(.{});
    defer glfw.terminate();

    zgpu.checkSystem("") catch return;

    const window = try glfw.Window.create(640, 480, "gameoflife-test", null, null, .{
        .client_api = .no_api,
        .cocoa_retina_framebuffer = true,
    });
    defer window.destroy();
    try window.setSizeLimits(.{ .width = 400, .height = 400 }, .{ .width = null, .height = null });

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const gctx = try zgpu.GraphicsContext.init(allocator, window);

    std.log.info("hello from {s}", .{@src().fn_name});

    inline for (@typeInfo(world.tests).Struct.decls) |decl, i| {
        std.debug.print("Running world.tests[{}] {s}...", .{ i, decl.name });
        const func = @field(world.tests, decl.name);
        const result = func(allocator, gctx);
        if (result) |_| {
            std.debug.print("PASS\n", .{});
        } else |err| {
            std.debug.print("FAIL ({s})\n", .{@errorName(err)});
            if (@errorReturnTrace()) |trace| {
                std.debug.dumpStackTrace(trace.*);
            }
        }
    }
}

comptime {
    _ = world;
}
