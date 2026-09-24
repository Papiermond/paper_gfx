package paper_gfx

import gl "vendor:OpenGL"
import "core:fmt"
import "core:math/linalg/glsl"
import "core:math"

draw_texture_pro :: proc(
    tex: Texture,
    src: Rect,
    dst: Rect,
    origin : [2]f32,
    rotation: f32,
    tint : Color = WHITE
){
    if tex.id == 0 do return

    color := [4]f32 {
        f32(tint.r) / 255.0,
        f32(tint.g) / 255.0,
        f32(tint.b) / 255.0,
        f32(tint.a) / 255.0,
    }

    tex_width   := f32(tex.width)
    tex_height  := f32(tex.height)

    u0 := src.x / tex_width
    v0 := src.y / tex_height
    u1 := (src.x + src.width) / tex_width
    v1 := (src.y + src.height) / tex_height

    if src.width < 0 {
        u0 = (src.x - src.width) / tex_width
        u1 = src.x / tex_width
    }
    
    if src.height < 0 {
        v0 = (src.y - src.height) / tex_height
        v1 = src.y / tex_height
    }

    pos_01 := [2]f32{-origin.x, - origin.y}
    pos_02 := [2]f32{-origin.x + dst.width, - origin.y}
    pos_03 := [2]f32{-origin.x + dst.width, - origin.y + dst.height}
    pos_04 := [2]f32{-origin.x, - origin.y + dst.height}

    if rotation != 0 {
        rad := math.to_radians(rotation)
        cos_r := math.cos(rad)
        sin_r := math.sin(rad)

        rotate :: proc(p: [2]f32, cos_r, sin_r:f32) -> [2]f32 {
            return {p.x * cos_r - p.y * sin_r, p.x * sin_r + p.y * cos_r}
        }

        pos_01 = rotate(pos_01, cos_r, sin_r)
        pos_02 = rotate(pos_02, cos_r, sin_r)
        pos_03 = rotate(pos_03, cos_r, sin_r)
        pos_04 = rotate(pos_04, cos_r, sin_r)
    }

    pos_01 += {dst.x, dst.y}
    pos_02 += {dst.x, dst.y}
    pos_03 += {dst.x, dst.y}
    pos_04 += {dst.x, dst.y}

    vertices := [4]Vertex {
        {pos = pos_01,uv = {u0, v0}, color = color},
        {pos = pos_02,uv = {u1, v0}, color = color},
        {pos = pos_03,uv = {u1, v1}, color = color},
        {pos = pos_04,uv = {u0, v1}, color = color},
    }

    gl.UseProgram(global_renderer.shader_id)
    gl.Disable(gl.CULL_FACE)
    gl.BindVertexArray(global_renderer.vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, global_renderer.vbo)
    gl.BufferSubData(gl.ARRAY_BUFFER, 0, size_of(vertices), &vertices[0])

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, global_renderer.ebo)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, tex.id)

    gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

    gl.BindVertexArray(0)
}

draw_texture_rec :: proc(tex: Texture, src: Rect, pos: [2]f32, tint: Color = WHITE) {
    dst := Rect{pos.x, pos.y, math.abs(src.width), math.abs(src.height)}
    draw_texture_pro(tex, src, dst, {0, 0}, 0.0, tint)
}

draw_texture :: proc(tex: Texture, x, y: i32, tint: Color = WHITE) {
    src := Rect{0, 0, f32(tex.width), f32(tex.height)}
    dst := Rect{f32(x), f32(y), f32(tex.width), f32(tex.height)}
    draw_texture_pro(tex, src, dst, {0, 0}, 0.0, tint)
}

draw_rect :: proc(rect : Rect, color: Color) {
    draw_texture_pro(global_renderer.white_texture, {0, 0, 1, 1}, rect, {0, 0}, 0, color)
}

draw_rect_lines :: proc(rect: Rect, line_thick: f32, color: Color) {
    draw_rect(Rect{rect.x, rect.y, rect.width, line_thick}, color)
    draw_rect(Rect{rect.x, rect.y + rect.height - line_thick, rect.width, line_thick}, color)
    draw_rect(Rect{rect.x, rect.y, line_thick, rect.height}, color)
    draw_rect(Rect{rect.x + rect.width - line_thick, rect.y, line_thick, rect.height}, color)
}