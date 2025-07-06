package core

import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:fmt"
import "core:c"

InitWindow::proc(name:cstring, width, height: c.int, vsync:bool)-> glfw.WindowHandle{
    // Inicializar GLFW
    if ! cast(bool) glfw.Init() {
        // log error, exit
        return nil
    }

    // Configurar versión de OpenGL (3.3 Core)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
    glfw.WindowHint(glfw.SAMPLES , 8)
    glfw.WindowHint(glfw.MAXIMIZED,1)


    // Crear ventana
    window := glfw.CreateWindow(width, height, name, nil, nil)
    if window == nil {
        fmt.println("Error al crear ventana GLFW")
        return nil
    }

    glfw.MakeContextCurrent(window)
    
    gl.load_up_to(3, 3, proc(p: rawptr, name: cstring) {
	(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
    })
    
    glfw.SwapInterval(i32(vsync))
    gl.Enable(gl.MULTISAMPLE)

    return window
}


EventsInit::proc(){
    glfw.PollEvents()
    
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
    
    //activa texturas transparentes & activa face culling
    gl.Enable(gl.BLEND | gl.CULL_FACE)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    
    gl.Enable(gl.DEPTH_TEST)
    gl.ClearColor(0.2, 0.3, 0.3, 1.0);
    
    //configura como Cull Fa
    gl.CullFace(gl.BACK)
    gl.FrontFace(gl.CCW)
}