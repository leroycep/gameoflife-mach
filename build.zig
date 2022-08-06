const std = @import("std");
const mach = @import("libs/mach/build.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const app = mach.App.init(b, .{
        .name = "gameoflife",
        .src = "src/main.zig",
        .target = target,
        .deps = &[_]std.build.Pkg{},
    });
    app.setBuildMode(mode);
    app.link(.{});
    app.install();

    const run_cmd = app.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Test binary
    const tests = mach.App.init(b, .{
        .name = "gameoflife-test",
        .src = "src/test.zig",
        .target = target,
        .deps = &[_]std.build.Pkg{},
    });
    tests.setBuildMode(mode);
    tests.link(.{});
    tests.install();

    const test_cmd = tests.run();
    test_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        test_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run the test binary");
    test_step.dependOn(&test_cmd.step);
}
