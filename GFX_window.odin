package paper_gfx

import "core:fmt"
import "core:strings"
import input "./../paper_input"
import "core:mem"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"

init_window :: proc(width, height: i32, title : string) -> bool {
    if !bool(glfw.Init()) {
        fmt.eprintln("Failed to initialize GLFW")
        return false
    }

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.RESIZABLE, false)

    c_title := strings.clone_to_cstring(title, context.temp_allocator)
    window := glfw.CreateWindow(width, height, c_title, nil, nil)
    if window == nil {
        fmt.eprintln("Failed to create GLFW window")
        glfw.Terminate()
        return false
    }

    global_renderer.window = window
    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    input.init_input(window)

    gl.load_up_to(3, 3, glfw.gl_set_proc_address)
    init_renderer(width, height)
    global_renderer.last_time = glfw.GetTime()
    return true
}

close_window :: proc() {
    cleanup_renderer()
    if global_renderer.window != nil {
        glfw.DestroyWindow(global_renderer.window)
    }
    glfw.Terminate()
}

window_should_close :: proc() -> bool {
    if global_renderer.window == nil do return true
    return bool(glfw.WindowShouldClose(global_renderer.window))
}

begin_drawing :: proc() {
    input.begin_frame()

    curr_time := glfw.GetTime()
    global_renderer.delta_time = f32(curr_time - global_renderer.last_time)
    global_renderer.last_time = curr_time

    glfw.PollEvents()
}

end_drawing :: proc() {
    glfw.SwapBuffers(global_renderer.window)
}

get_frame_time :: proc() -> f32 {
    return global_renderer.delta_time
}

get_time :: proc() -> f64 {
    return glfw.GetTime()
}

set_target_fps :: proc(fps : int) {
    if fps <= 0 {
        glfw.SwapInterval(0)
    } else {
        glfw.SwapInterval(1)
    }
}

set_window_title :: proc(title : string) {
    c_title := strings.clone_to_cstring(title, context.temp_allocator)
    glfw.SetWindowTitle(global_renderer.window, c_title)
}

get_screen_size :: proc() -> [2]i32 {
    return {global_renderer.screen_width,global_renderer.screen_height}
}

set_window_should_close :: proc(should_close : bool = true){
    if global_renderer.window != nil {
        glfw.SetWindowShouldClose(global_renderer.window,b32(should_close))
    }
}