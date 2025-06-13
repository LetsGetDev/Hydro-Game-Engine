package core

import "vendor:glfw"
import "core:math"
import "core:math/linalg/glsl"
import "core:fmt"


freely_rotate_cam::proc(camera_:^camera,window:glfw.WindowHandle,delta:f32){
    
    velocity:= camera_.camera_speed * delta
    
    if camera_.camera_pitch <= -89.00 {
        camera_.camera_pitch = -89.00
    }

    if camera_.camera_pitch >= 89.00 {
        camera_.camera_pitch = 89.00
    }

    // UP & Down rotation
    if glfw.GetKey(window,glfw.KEY_UP) == glfw.PRESS {
        camera_.camera_pitch += 64 * delta
    }

    if glfw.GetKey(window,glfw.KEY_DOWN) == glfw.PRESS {
        camera_.camera_pitch -= 64 * delta
    }


    //lEFT & RIGHT rotation
    if glfw.GetKey(window,glfw.KEY_LEFT) == glfw.PRESS {
        camera_.camera_yaw -= 64 * delta
    }

    if glfw.GetKey(window,glfw.KEY_RIGHT) == glfw.PRESS {
        camera_.camera_yaw += 64 * delta
    }


    //MOVEMENT forward & backwards
    if glfw.GetKey(window,glfw.KEY_W) == glfw.PRESS {
        camera_.camera_pos += camera_.camera_front * velocity
    }

    if glfw.GetKey(window,glfw.KEY_S) == glfw.PRESS {
        camera_.camera_pos -= camera_.camera_front * velocity
    }

    if glfw.GetKey(window,glfw.KEY_A) == glfw.PRESS {
        camera_.camera_pos -= camera_.camera_right * velocity
    }

    if glfw.GetKey(window,glfw.KEY_D) == glfw.PRESS {
        camera_.camera_pos += camera_.camera_right * velocity
    }

    if glfw.GetKey(window, glfw.KEY_SPACE) == glfw.PRESS {
        camera_.camera_pos.y += velocity
    }

    if glfw.GetKey(window, glfw.KEY_LEFT_SHIFT) == glfw.PRESS {
        camera_.camera_pos.y -= velocity
    }

}