@binding(0) @group(0) var cells : texture_2d<u32>;
//@binding(1) @group(0) var debug : texture_2d<u32>;

@stage(vertex)
fn vert_main(@location(0) a_pos : vec2<f32>) -> @builtin(position) vec4<f32> {
  return vec4<f32>(a_pos, 0.0, 1.0);
}

@stage(fragment)
fn frag_main(
    @builtin(position) frag_pos: vec4<f32>,
) -> @location(0) vec4<f32> {
  let pos = frag_pos.xy / 16.0;


  let size : vec2<i32> = textureDimensions(cells);
  let posi = vec2<i32>(pos.xy) / vec2(8, 4);

  if (any(posi >= size)) {
    let is_grid = (vec2<i32>(pos) & vec2(0x4)) > vec2(0);
    if ((is_grid.x && !is_grid.y) || (!is_grid.x && is_grid.y)) {
      return vec4<f32>(0.4, 0.1, 0.4, 1.0);
    }
    discard;
  }
  let tile = textureLoad(cells, posi, 0);
  let cell_local_pos = vec2<u32>(pos.xy) % vec2(8u, 4u);
  let byte = tile[cell_local_pos.y];
  let cell = (byte >> cell_local_pos.x) & 1u;
  switch (cell) {
    case 0u: {
      return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }
    case 1u: {
      return vec4<f32>(1.0, 1.0, 1.0, 1.0);
    }
    default: {
      return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
  }
}

