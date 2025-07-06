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
    window := core.InitWindow("window", 1270, 780, true)
    defer glfw.Terminate()
    defer glfw.DestroyWindow(window)


    model_geometry , ok := core.ImportObj("core/resources/switch_sketchfab.obj")
    model_tex:= core.LoadTexture("core/resources/switch.png",false)
    model:= core.SetupMesh(model_geometry.vertices,model_geometry.indices,"core/resources/Shaders/default.frag", "core/resources/Shaders/default.vert",model_tex)

    //skybox_geometry , sky_ok := core.ImportObj("core/resources/skybox_model/skybox_obj.obj")
    //skybox_tex := core.LoadTexture("core/resources/skybox_model/Skybox.png",true)
    //skybox:= core.SetupMesh(skybox_geometry.vertices,skybox_geometry.indices,"core/resources/Shaders/default.frag","core/resources/Shaders/default.vert",skybox_tex)


    gizmo_geometry, gizmo_ok:= core.ImportObj("core/resources/gizmo_model/gizmo.obj")
    gizmo_tex:= core.LoadTexture("core/resources/gizmo_model/texture.png", false)
    gizmo:= core.SetupMesh(gizmo_geometry.vertices,gizmo_geometry.indices,"core/resources/Shaders/default.frag","core/resources/Shaders/default.vert", gizmo_tex)


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
   

    
    core.configure_editor(window)
    defer im.DestroyContext()
    defer imgui_impl_glfw.Shutdown()
    defer imgui_impl_opengl3.Shutdown()

    
    core.init_audio()
    defer core.cleanup_audio()
    core.play_sound("core/resources/gamblecore.wav")

    last_frame:f32  
    glfw.SetFramebufferSizeCallback(window,win_size_callback)


    gizmo.position.y = 5

    
    // Bucle principal
    for !glfw.WindowShouldClose(window) {
        core.EventsInit()



        //setup delta time
        current_frame := f32(glfw.GetTime())
        delta_time := current_frame - last_frame
        last_frame = current_frame


        //draw camera & rotate camera
        view , projection:= core.initialize_camera(&main_camera,window)
        core.freely_rotate_cam(&main_camera,window,delta_time)
        
        core.draw_mesh(model,&view,&projection)

        model.scale = 0.1

        model.position.y = -1
       
        gl.Uniform3f(gl.GetUniformLocation(model.shader_program, "lightPos"), gizmo.position.x, gizmo.position.y, gizmo.position.z)
        gl.Uniform3f(gl.GetUniformLocation(model.shader_program, "viewPos"), main_camera.camera_pos.x, main_camera.camera_pos.y, main_camera.camera_pos.z)
        gl.Uniform3f(gl.GetUniformLocation(model.shader_program, "lightColor"), 1.0, 1.0, 1.0)
        


        //core.draw_mesh(skybox,&view,&projection)
        //skybox.position = main_camera.camera_pos
        //skybox.scale = 3.0


        core.draw_mesh(gizmo,&view,&projection)
        gizmo.scale = 0.5
        gizmo.position.y -= 0.6 * delta_time
        

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