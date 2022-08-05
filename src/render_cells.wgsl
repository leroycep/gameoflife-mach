@binding(0) @group(0) var cells : texture_2d<u32>;

@stage(vertex)
fn vert_main(@location(0) a_pos : vec2<f32>) -> @builtin(position) vec4<f32> {
  return vec4<f32>(a_pos, 0.0, 1.0);
}

@stage(fragment)
fn frag_main(
    @builtin(position) pos: vec4<f32>,
) -> @location(0) vec4<f32> {
  let size : vec2<i32> = textureDimensions(cells);
  let posi = vec2<i32>(i32(pos.x), i32(pos.y));
  if (any(posi >= size)) {
    discard;
  }
  let cell = textureLoad(cells, posi, 0).x;
  switch (cell) {
    case 0u: {
      return vec4<f32>(0.0, 0.0, 0.0, 1.0);
    }
    case 1u: {
      return vec4<f32>(1.0, 1.0, 1.0, 1.0);
    }
    case 3u: {
      return vec4<f32>(1.0, 1.0, 0.0, 1.0);
    }
    case 4u: {
      return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
    case 5u: {
      return vec4<f32>(0.0, 1.0, 0.0, 1.0);
    }
    case 6u: {
      return vec4<f32>(0.0, 0.0, 1.0, 1.0);
    }
    default: {
      return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
  }
}

