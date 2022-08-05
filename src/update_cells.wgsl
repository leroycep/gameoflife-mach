@binding(0) @group(0) var<uniform> size : vec2<i32>;
@binding(1) @group(0) var<storage, read> cellsA : array<u32>;
@binding(2) @group(0) var<storage, read_write> cellsB : array<u32>;

@stage(compute) @workgroup_size(64)
fn main(@builtin(global_invocation_id) GlobalInvocationID : vec3<u32>) {
    let cell_pos : vec2<i32> = vec2<i32>(i32(GlobalInvocationID.x), i32(GlobalInvocationID.y));
    var neighbors: u32 = 0u;

    for (var x : i32 = -1; x <= 1; x = x + 1) {
        for (var y : i32 = -1; y <= 1; y = y + 1) {
            if (x == 0 && y == 0) {
                continue;
            }
            let pos = vec2<i32>(cell_pos.x + x, cell_pos.y + y);
            if ((pos.x < 0) || (pos.x > size.x) || (pos.y < 0) || (pos.y > size.y)) {
                continue;
            }
            neighbors = neighbors + cellsA[pos.y * size.x + pos.x];
        }
    }
    
    switch (neighbors) {
        case 0u, 1u: {
            cellsB[cell_pos.y * size.x + cell_pos.x] = 0u;
        }
        case 2u: {
            cellsB[cell_pos.y * size.x + cell_pos.x] = cellsA[cell_pos.y * size.x + cell_pos.x];
        }
        case 3u: {
            cellsB[cell_pos.y * size.x + cell_pos.x] = 1u;
        }
        case 4u, 5u, 6u, 7u, 8u: {
            cellsB[cell_pos.y * size.x + cell_pos.x] = 0u;
        }
        default {}
    }
}

