package paper_gfx

import easy_font "vendor:stb/easy_font"

draw_text :: proc(text: string, x,y: f32, scale: f32 = 1.0, color: Color = WHITE) {
    if len(text) == 0 do return

    stack_quads : [1024]easy_font.Quad = ---
    quad_slice: []easy_font.Quad = stack_quads[:]

    needed := len(text) * 4
    if needed > len(stack_quads) {
        quad_slice = make([]easy_font.Quad, needed, context.temp_allocator)
    }

    c := easy_font.Color{color.r, color.g, color.b, color.a}
    num_quads := easy_font.print(x, y, text, c, quad_slice, scale)

    for q in quad_slice[:num_quads] {
        t1 := q.tl.v
        br := q.br.v
        rect := Rect{x = t1.x, y = t1.y, width = br.x - t1.x, height = br.y - t1.y}
        draw_rect(rect, color)
    }
}

measure_text :: proc(text: string, scale: f32 = 1.0) -> [2]f32 {
    w := f32(easy_font.width(text)) * scale
    h := f32(easy_font.height(text)) * scale
    return {w, h}
}