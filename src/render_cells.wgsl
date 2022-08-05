struct Uniforms {
  size : vec2<u32>,
};
@binding(0) @group(0) var<uniform> uniforms : Uniforms;

struct VertexOutput {
  @builtin(position) pos : vec4<f32>,
  @location(0) @interpolate(flat) color: u32,
};

@stage(vertex)
fn vert_main(@builtin(instance_index) index : u32,
             @location(0) color : u32,
             @location(1) a_pos : vec2<f32>,
) -> VertexOutput {
  let grid_pos = vec2<f32>(f32(index % uniforms.size.x), f32(index / uniforms.size.x));
  let sizef = vec2<f32>(f32(uniforms.size.x), f32(uniforms.size.y));
  var output: VertexOutput;
  output.pos = vec4<f32>(((grid_pos + a_pos) / sizef) * 2.0 - 1.0, 0.0, 1.0);
  output.color = color;
  return output;
}

@stage(fragment)
fn frag_main(
    @builtin(position) pos: vec4<f32>,
    @location(0) @interpolate(flat) color: u32,
) -> @location(0) vec4<f32> {
  switch (color) {
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

