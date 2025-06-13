package core

/*import stbi "vendor:stb/image"
import gl "vendor:OpenGL"
import "core:fmt"
import "core:math/linalg/glsl"


skyboxVertices:= []f32{
    // positions          
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0, -1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,

     1.0, -1.0, -1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0, -1.0,
     1.0, -1.0, -1.0,

    -1.0, -1.0,  1.0,
    -1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
     1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,

    -1.0,  1.0, -1.0,
     1.0,  1.0, -1.0,
     1.0,  1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,

    -1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0
}


default_skybox_vertex_sh :cstring =   `#version 330 core 
    layout (location = 0) in vec3 aPos; 
    out vec3 TexCoords; 
    uniform mat4 projection; 
    uniform mat4 view; 
    
    void main() { 
        TexCoords = aPos; 
        gl_Position = projection * view * vec4(aPos, 1.0); 

    }`


default_skybox_fragment_sh :cstring =   `#version 330 core 
    out vec4 FragColor; 
    
    in vec3 TexCoords; 
    
    uniform samplerCube skybox; 
    
    void main() { 
        FragColor = texture(skybox, TexCoords); 
    
    }`



cubemap::struct{
    texture:u32,
    success:bool
}

skybox::struct{
    Vao:u32,
    Vbo:u32,
    vertex_count:int,
    shader_program:u32,
    cubemap_data:cubemap
}


default_cubemap_tex:[6]cstring = {
    "core/resources/skybox/Standard-Cube-Map/nx.png",
    "core/resources/skybox/Standard-Cube-Map/ny.png",
    "core/resources/skybox/Standard-Cube-Map/nz.png",
    "core/resources/skybox/Standard-Cube-Map/px.png",
    "core/resources/skybox/Standard-Cube-Map/py.png",
    "core/resources/skybox/Standard-Cube-Map/pz.png",
}


setup_skybox::proc(vertices:[]f32,fragment:^cstring, vertex:^cstring) -> skybox{
    vao, vbo:u32

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(f32), &vertices[0], gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    SHader_PRogram := create_shaderProgram(fragment, vertex)
    gl.UseProgram(SHader_PRogram)
    gl.Uniform1i(gl.GetUniformLocation(SHader_PRogram, "skybox"), 0)


    return skybox{Vao = vao, Vbo = vbo, shader_program = SHader_PRogram, vertex_count = len(vertices)/3 }
}


//solo texturas divicibles por 2 
load_cubemap::proc(file_paths:[6]cstring)-> cubemap {
    
    stbi.set_flip_vertically_on_load(0)

    //create texture
    texture_:cubemap
    
    gl.GenTextures(1 , &texture_.texture)
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, texture_.texture)

    width, height, nrChannels:i32
    for i in 0..<6{
        data:= stbi.load(file_paths[i], &width, &height, &nrChannels,4)
  
        if data == nil{
            fmt.eprintfln("ERROR LOADING CUBE MAP:",i)
            texture_.texture = 0
            texture_.success = false
            stbi.image_free(data)
            return texture_
        }

        gl.TexImage2D(gl.TEXTURE_CUBE_MAP_POSITIVE_X + u32(i),0, gl.RGBA,width,height,0, gl.RGBA, gl.UNSIGNED_BYTE, rawptr(data))

    }
    

    //configure texture parameters
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR)


    gl.GenerateMipmap(gl.TEXTURE_CUBE_MAP)
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, 0)

    //stbi.image_free(data)
    texture_.success = true
    return texture_

}

draw_skybox :: proc(skybox: ^skybox, projection, view: ^glsl.mat4) {
    gl.DepthMask(gl.FALSE)
    gl.UseProgram(skybox.shader_program)

    // Remove translation from view matrix
    view_no_trans := view
    view_no_trans[3] = glsl.vec4{0, 0, 0, 1} // Reset translation column

    // Set matrices
    proj_loc := gl.GetUniformLocation(skybox.shader_program, "projection")
    view_loc := gl.GetUniformLocation(skybox.shader_program, "view")
    gl.UniformMatrix4fv(proj_loc, 1, gl.FALSE, &projection[0, 0])
    gl.UniformMatrix4fv(view_loc, 1, gl.FALSE, &view_no_trans[0, 0])

    // Bind textures
    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_CUBE_MAP, skybox.cubemap_data.texture)

    // Draw
    gl.BindVertexArray(skybox.Vao)
    gl.DrawArrays(gl.TRIANGLES, 0, i32(skybox.vertex_count))
    gl.BindVertexArray(0)

    gl.DepthMask(gl.TRUE)
}
*/