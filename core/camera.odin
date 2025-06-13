package core

import "core:math/linalg/glsl"
import "core:math"
import "vendor:glfw"

camera::struct{
    camera_pos:glsl.vec3,
    camera_front:glsl.vec3,
    camera_up:glsl.vec3,
    camera_yaw:f32,  // Mirando hacia -Z
    camera_pitch:f32,
    camera_speed:f32,
    camera_right:glsl.vec3,
}

initialize_camera::proc(curr_camera:^camera, window:glfw.WindowHandle) ->(view_return:glsl.mat4, projection_return:glsl.mat4) {
    front:= glsl.vec3{
            //1
            math.cos_f32(glsl.radians(curr_camera.camera_yaw)) * math.cos_f32(glsl.radians(curr_camera.camera_pitch)),
            //2
            math.sin_f32(glsl.radians(curr_camera.camera_pitch)),
            //3
            math.sin_f32(glsl.radians(curr_camera.camera_yaw)) * math.cos_f32(glsl.radians(curr_camera.camera_pitch))
        }
    
    curr_camera.camera_front = glsl.normalize(front)
    
    curr_camera.camera_right = glsl.normalize(glsl.cross_vec3(curr_camera.camera_front, {0,1,0}))


    view := glsl.mat4LookAt(curr_camera.camera_pos, curr_camera.camera_pos + curr_camera.camera_front ,curr_camera.camera_up)
    width_win , height_win := glfw.GetWindowSize(window)
    aspect_ratio := f32(width_win) / f32(height_win)
    projection := glsl.mat4Perspective(45.0,aspect_ratio,0.1,100.0)

    return view , projection

}