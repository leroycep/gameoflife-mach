const std = @import("std");
const mach = @import("mach");
const gpu = @import("gpu");
const builtin = @import("builtin");
const world = @import("./world.zig");

pub const App = @This();

const WIDTH = 4;
const HEIGHT = 8;

pub fn init(app: *App, core: *mach.Core) !void {
    _ = app;

    inline for (@typeInfo(world.tests).Struct.decls) |decl, i| {
        std.debug.print("Running world.tests[{}] {s}...", .{ i, decl.name });
        const func = @field(world.tests, decl.name);
        const result = func();
        if (result) |_| {
            std.debug.print("PASS\n", .{});
        } else |err| {
            std.debug.print("FAIL ({s})\n", .{@errorName(err)});
            if (@errorReturnTrace()) |trace| {
                std.debug.dumpStackTrace(trace.*);
            }
        }
    }

    core.setShouldClose(true);
}

pub fn deinit(_: *App, _: *mach.Core) void {}

pub fn update(_: *App, _: *mach.Core) !void {}

comptime {
    _ = world;
}
