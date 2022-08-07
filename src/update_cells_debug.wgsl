@binding(0) @group(0) var cellsA : texture_2d<u32>;
@binding(1) @group(0) var cellsB : texture_storage_2d<rgba8uint, write>;
@binding(0) @group(1) var debug : texture_storage_2d<rgba8uint, write>;

var<workgroup> new_tile: array<array<bool, 8>, 4>;

@stage(compute) @workgroup_size(8, 4)
fn main(
    @builtin(workgroup_id) WorkGroupID : vec3<u32>,
    @builtin(local_invocation_id) LocalInvocationID : vec3<u32>,
) {
    let texel_pos = vec2<i32>(WorkGroupID.xy);
    let size : vec2<i32> = textureDimensions(cellsA);
    let TILE_SIZE = vec2<i32>(8, 4);
    let local_pos = vec2<i32>(LocalInvocationID.xy);
    
    var tiles: array<vec4<u32>, 3>;
    for (var i = 0; i < 3; i += 1) {
        for (var j = 0; j < 3; j += 1) {
            let pos = texel_pos + vec2(i - 1, j - 1);
            tiles[j] = tiles[j] << vec4(8u, 8u, 8u, 8u);
            if (any(pos < vec2(0)) || any(pos >= size)) {
                continue;
            }
            tiles[j] |= textureLoad(cellsA, pos, 0) & vec4(0xFFu, 0xFFu, 0xFFu, 0xFFu);
        }
    }


    var neighbors: u32 = 0u;
    var prev_value = false;
    for (var i = 0; i < 3; i += 1) {
        for (var j = 0; j < 3; j += 1) {
            let pos = local_pos + vec2(i - 1, j - 1);
            let tile = tiles[(pos.y / TILE_SIZE.y) + 1][(pos.y % TILE_SIZE.y)];
            let bit_idx = u32(pos.x + 8);
            let cell = (tile >> bit_idx) & 1u;
            if (all(pos == local_pos)) {
                prev_value = bool(cell);
            } else {
                neighbors = neighbors + cell;
            }
        }
    }
    
    switch (neighbors) {
        case 2u: {
            new_tile[local_pos.y][local_pos.x] = prev_value;
        }
        case 3u: {
            new_tile[local_pos.y][local_pos.x] = true;
        }
        case 0u, 1u, 4u, 5u, 6u, 7u, 8u: {
            new_tile[local_pos.y][local_pos.x] = false;
        }
        default: { }
    }

    let grow = (!prev_value) && new_tile[local_pos.y][local_pos.x];
    let die = prev_value && !new_tile[local_pos.y][local_pos.x];
    let green = u32(grow) * 255u;
    let red = u32(die) * 255u;
    textureStore(debug, texel_pos * TILE_SIZE + local_pos, vec4<u32>(red,green,neighbors * 64u,255u));

    workgroupBarrier();
    
    var new_val = vec4<u32>(0u);
    for (var c = 0u; c < 4u; c += 1u) {
        for (var i = 0u; i < 8u; i += 1u) {
            if (new_tile[c][i]) {
                new_val[c] = (new_val[c] >> 1u) | 0x80u;
            } else {
                new_val[c] = (new_val[c] >> 1u);
            }
        }
    }
    textureStore(cellsB, texel_pos, vec4<u32>(new_val));
}

