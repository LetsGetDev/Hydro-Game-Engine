package core

import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:fmt"

init_window::proc()-> glfw.WindowHandle{
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


    // Crear ventana
    window := glfw.CreateWindow(800, 600, "Triángulo OpenGL en Odin", nil, nil)
    if window == nil {
        fmt.println("Error al crear ventana GLFW")
        return nil
    }

    glfw.MakeContextCurrent(window)
    
    gl.load_up_to(3, 3, proc(p: rawptr, name: cstring) {
	(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
    })
    
    glfw.SwapInterval(1)
    gl.Enable(gl.MULTISAMPLE)

    return window
}
