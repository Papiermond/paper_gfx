package paper_gfx

import "core:strings"
import "core:math"

color_alpha :: proc(c: Color, alpha: f32) -> Color {
    a := u8(clamp(alpha,0.0,1.0) * 255)
    return{c.r, c.g, c.b, a}
}

get_screen_to_world :: proc(pos : [2]f32, cam : Camera2D) -> [2]f32 {
    rad := -math.to_radians(cam.rotation)
    cos_r := math.cos(rad)
    sin_r := math.sin(rad)

    p_offset := pos - cam.offset

    rotated := [2]f32 {
        p_offset.x * cos_r - p_offset.y * sin_r,
        p_offset.x * sin_r + p_offset.y * cos_r
    }

    return (rotated / cam.zoom) + cam.target
}