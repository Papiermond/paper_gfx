package paper_gfx

import str"core:strings"
import ima "core:image"
import png "core:image/png"
import gl "vendor:OpenGL"
import fmt "core:fmt"

load_texture :: proc(path: string) -> Texture {
    c_path := str.clone_to_cstring(path,context.temp_allocator)
    options := ima.Options{.alpha_add_if_missing}
    img, err := ima.load_from_file(path,options)
    if err != nil {
        return {}
    }
    defer ima.destroy(img)

    id : u32
    gl.GenTextures(1,&id)
    gl.BindTexture(gl.TEXTURE_2D, id)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.TexImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        i32(img.width),
        i32(img.height),
        0,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        raw_data(img.pixels.buf),
    )

    return Texture {
        id = id,
        width = i32(img.width),
        height = i32(img.height),
    }
}

unload_texture :: proc(tex : Texture) {
    id := tex.id
    gl.DeleteTextures(1,&id)
}

unload_render_texture :: proc(tex : Render_Texture) {
    tex_id := tex.texture.id
    gl.DeleteTextures(1, &tex_id)
    fbo_id := tex.fbo_id
    gl.DeleteFramebuffers(1, &fbo_id)
}

load_render_texture :: proc(width, height : i32) -> Render_Texture {
    fbo : u32
    gl.GenFramebuffers(1, &fbo)
    gl.BindFramebuffer(gl.FRAMEBUFFER, fbo)

    tex_id : u32
    gl.GenTextures(1, &tex_id)
    gl.BindTexture(gl.TEXTURE_2D, tex_id)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, nil)

    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex_id, 0)
    if gl.CheckFramebufferStatus(gl.FRAMEBUFFER) !=  gl.FRAMEBUFFER_COMPLETE {
        fmt.eprintln("ERROR: Framebuffer not complete!")
    }

    gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

    return Render_Texture {
        fbo_id = fbo,
        texture = Texture {
            id = tex_id,
            width = width,
            height = height,
        },
    }
}