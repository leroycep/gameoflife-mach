@binding(0) @group(0) var cellsA : texture_2d<u32>;

@stage(vertex)
fn vert_main(@location(0) a_pos : vec2<f32>) -> @builtin(position) vec4<f32> {
  return vec4<f32>(a_pos, 0.0, 1.0);
}

@stage(fragment)
fn frag_main(
    @builtin(position) pos: vec4<f32>,
) -> @location(0) vec4<f32> {
  switch (textureLoad(cellsA, vec2<i32>(i32(pos.x), i32(pos.y)), 0).x) {
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

