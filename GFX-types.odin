package paper_gfx

Texture :: struct {
    id : u32,
    width: i32,
    height : i32,
}

Render_Texture :: struct {
    fbo_id : u32,
    texture : Texture,
}

Camera2D :: struct {
    target : [2]f32,
    offset : [2]f32,
    zoom : f32,
    rotation : f32,
}

Rect :: struct {
    x, y : f32,
    width, height: f32,
}

Color :: struct {
    r, g, b, a : u8,
}

WHITE   :: Color{255, 255, 255, 255}
BLACK   :: Color{000, 000, 000, 255}
BLANK   :: Color{000, 000, 000, 000}
RED     :: Color{255, 000, 000, 255}
GREEN   :: Color{000, 255, 000, 255}
BLUE    :: Color{000, 000, 255, 255}
YELLOW  :: Color{255, 255, 000, 255}