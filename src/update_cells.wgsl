@binding(0) @group(0) var cellsA : texture_2d<u32>;
@binding(1) @group(0) var cellsB : texture_storage_2d<r32uint, write>;

@stage(compute) @workgroup_size(64)
fn main(@builtin(global_invocation_id) GlobalInvocationID : vec3<u32>) {
    let cell_pos : vec2<i32> = vec2<i32>(i32(GlobalInvocationID.x), i32(GlobalInvocationID.y));
    var neighbors: u32 = 0u;

    let size : vec2<i32> = textureDimensions(cellsA);
    for (var x : i32 = -1; x <= 1; x = x + 1) {
        for (var y : i32 = -1; y <= 1; y = y + 1) {
            if (x == 0 && y == 0) {
                continue;
            }
            let pos = vec2<i32>(cell_pos.x + x, cell_pos.y + y);
            if ((pos.x < 0) || (pos.x > size.x) || (pos.y < 0) || (pos.y > size.y)) {
                continue;
            }
            neighbors = neighbors + textureLoad(cellsA, pos, 0).x;
        }
    }
    
    var new_val : u32 = 0u;
    switch (neighbors) {
        case 2u: {
            new_val = textureLoad(cellsA, cell_pos, 0).x;
        }
        case 3u: {
            new_val = 1u;
        }
        //case 0u, 1u: {
        //    cellsB[cell_pos.y * size.x + cell_pos.x] = 0u;
        //}
        //case 4u, 5u, 6u, 7u, 8u: {
        //    cellsB[cell_pos.y * size.x + cell_pos.x] = 0u;
        //}
        default {}
    }
    textureStore(cellsB, cell_pos, vec4<u32>(new_val));
}

