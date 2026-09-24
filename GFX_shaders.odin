package paper_gfx

import "core:fmt"
import "core:strings"
import gl "vendor:OpenGL"

Vertex_shader :: `
#version 330 core
layout (location = 0) in vec2 a_pos;
layout (location = 1) in vec2 a_uv;
layout (location = 2) in vec4 a_color;
uniform mat4 u_projection;
out vec2 v_uv;
out vec4 v_color;
void main() {
    v_uv = a_uv;
    v_color = a_color;
    gl_Position = u_projection * vec4(a_pos, 0.0, 1.0);
}
`

Fragment_shader :: `
#version 330 core
in vec2 v_uv;
in vec4 v_color;
out vec4 FragColor;
uniform sampler2D u_texture;
void main() {
    FragColor = texture(u_texture, v_uv) * v_color;
}
`

compile_shader :: proc(source: string, shader_type: u32) -> (u32, bool) {
    id := gl.CreateShader(shader_type)
    c_str := strings.clone_to_cstring(source, context.temp_allocator)
    gl.ShaderSource(id, 1, &c_str, nil)
    gl.CompileShader(id)

    status : i32
    gl.GetShaderiv(id, gl.COMPILE_STATUS, &status)
    if status == 0 {
        log_buf : [512]u8
        gl.GetShaderInfoLog(id, 512, nil, raw_data(log_buf[:]))
        fmt.eprintfln("Shader compile error: %s", string(log_buf[:]))
        gl.DeleteShader(id)
        return 0, false
    }
    return id, true
}

create_shader_program :: proc(vs_src, fs_src : string) -> (u32, bool) {
    vs, vs_ok := compile_shader(vs_src, gl.VERTEX_SHADER)
    if !vs_ok do return 0, false
    defer gl.DeleteShader(vs)

    fs, fs_ok := compile_shader(fs_src, gl.FRAGMENT_SHADER)
    if !fs_ok do return 0, false
    defer gl.DeleteShader(fs)

    program := gl.CreateProgram()
    gl.AttachShader(program, vs)
    gl.AttachShader(program, fs)
    gl.LinkProgram(program)

    status : i32
    gl.GetProgramiv(program, gl.LINK_STATUS, &status)
    if status == 0 {
        log_buf : [512]u8
        gl.GetProgramInfoLog(program, 512, nil, raw_data(log_buf[:]))
        fmt.eprintfln("Program link error: %s", string(log_buf[:]))
        gl.DeleteProgram(program)
        return 0, false
    }
    return program, true    
}