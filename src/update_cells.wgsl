@binding(0) @group(0) var cellsA : texture_2d<u32>;
@binding(1) @group(0) var cellsB : texture_storage_2d<rgba8uint, write>;

var<workgroup> new_val: array<array<bool, 8>, 4>;

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
    for (var j = 0; j < 3; j += 1) {
        tiles[j] = vec4(0u);
        for (var i = 0; i < 3; i += 1) {
            let pos = texel_pos + vec2(i - 1, j - 1);
            if (any(pos < vec2(0)) || any(pos >= size)) {
                continue;
            }
            let texel = textureLoad(cellsA, pos, 0);
            for (var k = 0; k < 4; k += 1) {
                tiles[j][k] |= texel[k] << (8u * u32(i));
            }
        }
    }

    var neighbors: u32 = 0u;
    var prev_value = false;
    for (var i = 0; i < 3; i += 1) {
        for (var j = 0; j < 3; j += 1) {
            let pos = local_pos + vec2(i - 1, j - 1);
            var tile = 0u;
            if (pos.y < 0) {
                tile = tiles[0][(pos.y % TILE_SIZE.y)];
            } else {
                tile = tiles[(pos.y / TILE_SIZE.y) + 1][(pos.y % TILE_SIZE.y)];
            }
            let bit_idx = u32(pos.x + 8);
            let cell = (tile >> bit_idx) & 1u;
            if (all(pos == local_pos)) {
                prev_value = bool(cell);
            } else {
                neighbors += cell;
            }
        }
    }

    switch (neighbors) {
        case 2u: {
            new_val[LocalInvocationID.y][LocalInvocationID.x] = prev_value;
        }
        case 3u: {
            new_val[LocalInvocationID.y][LocalInvocationID.x] = true;
        }
        case 0u, 1u, 4u, 5u, 6u, 7u, 8u: {
            new_val[LocalInvocationID.y][LocalInvocationID.x] = false;
        }
        default: { }
    }

    workgroupBarrier();
    var new_tile = vec4(0u);
    for (var j = 0u; j < 4u; j += 1u) {
        for (var i = 0u; i < 8u; i += 1u) {
            new_tile[j] |= (u32(new_val[j][i]) << i);
        }
    }
    textureStore(cellsB, texel_pos, new_tile);
}

