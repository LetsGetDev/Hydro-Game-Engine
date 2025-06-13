package core

import stbi "vendor:stb/image"
import gl "vendor:OpenGL"
import "core:fmt"


texture_data::struct{
    texture:u32,
    success:bool
}

//solo texturas divicibles por 2 
load_texture::proc(file_path:cstring,interpolation:bool)-> texture_data {
    
    stbi.set_flip_vertically_on_load(1)

    //create texture
    texture_:texture_data
    
    gl.GenTextures(1 , &texture_.texture)
    gl.BindTexture(gl.TEXTURE_2D, texture_.texture)

    //configure texture parameters
    
    if interpolation == false{
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    }
    else{
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    }
    
    
    

    width, height, nrChannels:i32
    data:= stbi.load(file_path, &width, &height, &nrChannels,0)
    defer stbi.image_free(data)

    if data == nil{
        fmt.eprintf("ERROR:: Failed to load texture: %s\n", file_path)
        texture_.texture = 0
        texture_.success = false
        return texture_
    }

    gl.TexImage2D(gl.TEXTURE_2D,0, gl.RGBA,width,height,0, gl.RGBA, gl.UNSIGNED_BYTE, rawptr(data))

    gl.GenerateMipmap(gl.TEXTURE_2D)
    gl.BindTexture(gl.TEXTURE_2D, 0)

    return texture_

}