const std = @import("std");

const ZERO = @Vector(2, i32){ 0, 0 };

fn reference_impl_step(size: @Vector(2, i32), cellsIn: []const u1, cellsOut: []u1) void {
    std.debug.assert(size[0] > 1 and size[1] > 1);
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
    pub fn @"example: square is stable"() !void {
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

    pub fn @"example: line spins"() !void {
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
};
