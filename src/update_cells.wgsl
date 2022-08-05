@binding(0) @group(0) var cellsA : texture_2d<u32>;
@binding(1) @group(0) var cellsB : texture_storage_2d<r32uint, write>;

@stage(compute) @workgroup_size(1)
fn main(@builtin(global_invocation_id) GlobalInvocationID : vec3<u32>) {
    let cell_pos : vec2<i32> = vec2<i32>(i32(GlobalInvocationID.x), i32(GlobalInvocationID.y));
    let size : vec2<i32> = textureDimensions(cellsA);

    var neighbors: u32 = 0u;

    let min_pos = clamp(cell_pos - 1, vec2(0), size - 1);
    let max_pos = clamp(cell_pos + 1, vec2(0), size - 1);
    for (var pos = min_pos; pos.x <= max_pos.x; pos.x = pos.x + 1) {
        for (pos.y = min_pos.y; pos.y <= max_pos.y; pos.y = pos.y + 1) {
            if (all(pos == cell_pos)) {
                continue;
            }
            neighbors = neighbors + min(1u, textureLoad(cellsA, pos, 0).x);
        }
    }
    
    var new_val : u32 = 0u;
    switch (neighbors) {
        case 2u: {
            new_val = min(1u, textureLoad(cellsA, cell_pos, 0).x);
        }
        case 3u: {
            new_val = 1u;
        }
        default {}
    }
    textureStore(cellsB, cell_pos, vec4<u32>(new_val));
}

