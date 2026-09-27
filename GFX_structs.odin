package paper_gfx

import "core:math"
import "vendor:glfw"

Renderer :: struct {
	window:        glfw.WindowHandle,
	last_time:     f64,
	delta_time:    f32,
	shader_id:     u32,
	vao:           u32,
	vbo:           u32,
	ebo:           u32,
	u_proj_loc:    i32,
	currrent_proj: matrix[4, 4]f32,
	screen_width:  i32,
	screen_height: i32,
	white_texture: Texture,
}

global_renderer: Renderer

Vertex :: struct {
	pos:   [2]f32,
	uv:    [2]f32,
	color: [4]f32,
}
