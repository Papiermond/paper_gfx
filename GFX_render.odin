package paper_gfx

import "core:fmt"
import "core:math"
import glsl "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

init_renderer :: proc(viewport_width, viewport_height: i32) {
	prog, ok := create_shader_program(Vertex_shader, Fragment_shader)
	if !ok {
		fmt.eprintln("Failed to create default shader Program")
		return
	}
	global_renderer.shader_id = prog

	gl.UseProgram(prog)
	global_renderer.u_proj_loc = gl.GetUniformLocation(prog, "u_projection")
	u_tex_loc := gl.GetUniformLocation(prog, "u_texture")
	if u_tex_loc != -1 {
		gl.Uniform1i(u_tex_loc, 0)
	}

	gl.GenVertexArrays(1, &global_renderer.vao)
	gl.GenBuffers(1, &global_renderer.vbo)
	gl.GenBuffers(1, &global_renderer.ebo)

	gl.BindVertexArray(global_renderer.vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, global_renderer.vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(Vertex) * 4, nil, gl.DYNAMIC_DRAW)

	indices := [6]u32{0, 1, 2, 2, 3, 0}
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, global_renderer.ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices), &indices[0], gl.STATIC_DRAW)

	stride := i32(size_of(Vertex))

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, stride, offset_of(Vertex, pos))


	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, stride, offset_of(Vertex, uv))


	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, stride, offset_of(Vertex, color))

	gl.BindVertexArray(0)
	gl.Disable(gl.CULL_FACE)
	gl.Disable(gl.DEPTH_TEST)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	white_pixel := [4]u8{255, 255, 255, 255}
	gl.GenTextures(1, &global_renderer.white_texture.id)
	gl.BindTexture(gl.TEXTURE_2D, global_renderer.white_texture.id)
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, &white_pixel[0])
	global_renderer.white_texture.width = 1
	global_renderer.white_texture.height = 1

	global_renderer.screen_width = viewport_width
	global_renderer.screen_height = viewport_height

	set_projection(viewport_width, viewport_height)
}

set_projection :: proc(width, height: i32) {
	global_renderer.currrent_proj = glsl.mat4Ortho3d(0, f32(width), f32(height), 0, -1, 1)
	gl.UseProgram(global_renderer.shader_id)
	gl.UniformMatrix4fv(global_renderer.u_proj_loc, 1, false, &global_renderer.currrent_proj[0, 0])
}

cleanup_renderer :: proc() {
	gl.DeleteProgram(global_renderer.shader_id)
	gl.DeleteVertexArrays(1, &global_renderer.vao)
	gl.DeleteBuffers(1, &global_renderer.vbo)
	gl.DeleteBuffers(1, &global_renderer.ebo)
}

begin_texture_mode :: proc(target: Render_Texture) {
	gl.BindFramebuffer(gl.FRAMEBUFFER, target.fbo_id)
	gl.Viewport(0, 0, target.texture.width, target.texture.height)
	set_projection(target.texture.width, target.texture.height)
}

end_texture_mode :: proc() {
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
	gl.Viewport(0, 0, global_renderer.screen_width, global_renderer.screen_height)
	set_projection(global_renderer.screen_width, global_renderer.screen_height)
}

begin_mode_2d :: proc(cam: Camera2D) {
	w := f32(global_renderer.screen_width)
	h := f32(global_renderer.screen_height)

	proj := glsl.mat4Ortho3d(0, w, h, 0, -1, 1)

	rad := math.to_radians(cam.rotation)

	mat_offset := glsl.mat4Translate({cam.offset.x, cam.offset.y, 0})
	mat_rot := glsl.mat4Rotate({0, 0, 1}, rad)
	mat_scale := glsl.mat4Scale({cam.zoom, cam.zoom, 1})
	mat_target := glsl.mat4Translate({-cam.target.x, -cam.target.y, 0})

	view := mat_offset * mat_rot * mat_scale * mat_target

	global_renderer.currrent_proj = proj * view
	gl.UseProgram(global_renderer.shader_id)
	gl.UniformMatrix4fv(global_renderer.u_proj_loc, 1, false, &global_renderer.currrent_proj[0, 0])
}

end_mode_2d :: proc() {
	set_projection(global_renderer.screen_width, global_renderer.screen_height)
}

clear_background :: proc(c: Color) {
	gl.ClearColor(f32(c.r) / 255.0, f32(c.g) / 255.0, f32(c.b) / 255.0, f32(c.a) / 255.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}
