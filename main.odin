package main

DISABLE_DOCKING :: #config(DISABLE_DOCKING, false)


//import math stuff and utilities
import "core:fmt"
import "core:math"
import "core:c"
import "core:math/linalg/glsl"
import "core"
import "core:strings"

//import opengl & glfw
import gl "vendor:OpenGL"
import "vendor:glfw"
import im "core/Imgui"
import "core/Imgui/imgui_impl_glfw"
import "core/Imgui/imgui_impl_opengl3"


main :: proc() {
    window := core.init_window()
    defer glfw.Terminate()
    defer glfw.DestroyWindow(window)


    vertices := []f32{
    // Posiciones (x, y, z)   // UVS (1-0)
    -0.5, -0.5, 0.0,          0.0, 0.0,   // Vértice 0: abajo-izquierda
     0.5, -0.5, 0.0,          1.0, 0.0,   // Vértice 1: abajo-derecha
     0.5,  0.5, 0.0,          1.0, 1.0,  // Vértice 2: arriba-derecha
    -0.5,  0.5, 0.0,          0.0, 1.0,  // Vértice 3: arriba-izquierda
    }

    indices := []u32{
        0, 1, 2,  // Primer triángulo (abajo-derecha)
        2, 3, 0   // Segundo triángulo (arriba-izquierda)
    }

    model_geometry , ok := core.import_obj("core/resources/switch_sketchfab.obj")
    model_tex:= core.load_texture("core/resources/switch.png",false)
    model:= core.configure_mesh(model_geometry.vertices,model_geometry.indices,"core/resources/Shaders/default.frag", "core/resources/Shaders/default.vert",model_tex)

    skybox_geometry , sky_ok := core.import_obj("core/resources/skybox_model/skybox_obj.obj")
    skybox_tex := core.load_texture("core/resources/skybox_model/Skybox.png",true)
    skybox:= core.configure_mesh(skybox_geometry.vertices,skybox_geometry.indices,"core/resources/Shaders/default.frag","core/resources/Shaders/default.vert",skybox_tex)


    gizmo_geometry, gizmo_ok:= core.import_obj("core/resources/gizmo_model/gizmo.obj")
    gizmo_tex:= core.load_texture("core/resources/gizmo_model/texture.png", false)
    gizmo:= core.configure_mesh(gizmo_geometry.vertices,gizmo_geometry.indices,"core/resources/Shaders/default.frag","core/resources/Shaders/default.vert", gizmo_tex)


    defer {
        core.cleanup_mesh(&model)
        //core.cleanup_mesh(&skybox)
        core.cleanup_mesh(&gizmo)
    }

    main_camera:core.camera = {
        camera_pos = {0,0,0}, 
        camera_front = {0,0,-1}, 
        camera_up = {0,1,0}, 
        camera_yaw = -90,
        camera_pitch = 0,
        camera_speed = 2.5,
        camera_right = 0.0

    }
   
    defer fmt.println(main_camera.camera_pitch)
    defer fmt.println(main_camera.camera_pos.y)

    
    core.configure_editor(window)
    defer im.DestroyContext()
    defer imgui_impl_glfw.Shutdown()
    defer imgui_impl_opengl3.Shutdown()

    
    last_frame:f32  
    gl.Enable(gl.DEPTH_TEST)
    gl.ClearColor(0.2, 0.3, 0.3, 1.0);
    glfw.SetFramebufferSizeCallback(window,win_size_callback)
    gl.Enable(gl.CULL_FACE)
    gl.CullFace(gl.BACK)
    gl.FrontFace(gl.CCW)
    
    core.init_audio()
    defer core.cleanup_audio()
    core.play_sound("core/resources/gamblecore.wav")

    
    // Bucle principal
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
        gl.Clear(gl.COLOR_BUFFER_BIT)
        gl.Clear(gl.DEPTH_BUFFER_BIT)
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)


        //setup delta time
        current_frame := f32(glfw.GetTime())
        delta_time := current_frame - last_frame
        last_frame = current_frame


        //draw camera & rotate camera
        view , projection:= core.initialize_camera(&main_camera,window)
        core.freely_rotate_cam(&main_camera,window,delta_time)
        
        core.draw_mesh(model,&view,&projection)
        model.scale = 0.05
        model.pivot.xz = 10


        core.draw_mesh(skybox,&view,&projection)
        skybox.position = main_camera.camera_pos
        skybox.scale = 3.0


        core.draw_mesh(gizmo,&view,&projection)
        gizmo.scale = 0.5
        


        core.render_editor()
        
        glfw.SwapBuffers(window)
    }

}


win_size_callback::proc "c"(window:glfw.WindowHandle,width,height:i32) {
    gl.Viewport(0,0,width,height)
}



// Im making a game engine in Odin lang using only glfw & and opengl
//this took me more than 2 months.


// I finally got 3d models working :)