package core

import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:math/linalg/glsl"
import "core:math"
import "core:fmt"


mesh::struct{
    Vao:u32,
    Ebo:u32,
    Vbo:u32,
    index_count:int,
    shader_program:u32,
    tex_data:texture_data,
    position:glsl.vec3,
    rotation:glsl.vec3,
    scale:glsl.vec3,
    pivot:glsl.vec3,

}


configure_mesh::proc(vertices:[dynamic]f32, indices:[dynamic]u32, fragment:^cstring, Vertex:^cstring, texture_img:texture_data) -> mesh {
    // Crear VAO (Vertex Array Object)
    vao: u32
    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    // Crear VBO (Vertex Buffer Object)
    vbo: u32
    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(f32), &vertices[0], gl.STATIC_DRAW)

    //crea EBO (Element Buffer Object)
    ebo:u32
    gl.GenBuffers(1,&ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(u32), raw_data(indices),gl.STATIC_DRAW)

    // Configurar atributos de vértice
    // Atributo de posición (layout location = 0)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)
    
    // Atributo de textura (layout location = 1)
    gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 5 * size_of(f32), 3 * size_of(f32))
    gl.EnableVertexAttribArray(1)


    SHader_PRogram := create_shaderProgram(fragment, Vertex)

    return mesh {
        Vao = vao, 
        index_count = len(indices) , 
        shader_program = SHader_PRogram, 
        scale = {1,1,1}, 
        Ebo = ebo, 
        tex_data = texture_img,
        Vbo = vbo,
        pivot = {0,0,0}
    }
}


draw_mesh::proc(mesh_:mesh, view:^glsl.mat4, projection:^glsl.mat4){
    
    gl.UseProgram(mesh_.shader_program)
    

    pivot_correction:= glsl.mat4Translate(-mesh_.pivot)

    //Model = transform del mesh x y z etc ..
    model := glsl.mat4Translate(mesh_.position) * glsl.mat4Rotate(glsl.vec3{1, 0, 0}, math.to_radians(mesh_.rotation.x)) *glsl.mat4Rotate(glsl.vec3{0, 1, 0}, math.to_radians(mesh_.rotation.y)) *glsl.mat4Rotate(glsl.vec3{0, 0, 1}, math.to_radians(mesh_.rotation.z)) * glsl.mat4Scale(mesh_.scale) * pivot_correction
    
    //conseguir trasformaciones y camara
    model_loc:= gl.GetUniformLocation(mesh_.shader_program,"model")
    view_loc: = gl.GetUniformLocation(mesh_.shader_program,"view")
    projection_loc:= gl.GetUniformLocation(mesh_.shader_program,"projection")
    

    //subir data
    gl.UniformMatrix4fv(model_loc, 1, gl.FALSE, &model[0, 0])
    gl.UniformMatrix4fv(view_loc, 1, gl.FALSE, &view[0, 0])
    gl.UniformMatrix4fv(projection_loc, 1, gl.FALSE, &projection[0, 0])

    tex_loc:= gl.GetUniformLocation(mesh_.shader_program,"texture1")
    gl.Uniform1i(tex_loc,0)
    gl.ActiveTexture(mesh_.tex_data.texture)
    gl.BindTexture(gl.TEXTURE_2D, mesh_.tex_data.texture)
    
    gl.BindVertexArray(mesh_.Vao)
    gl.DrawElements(gl.TRIANGLES,i32(mesh_.index_count),gl.UNSIGNED_INT,nil)
}

look_at_y :: proc(object_pos, target_pos: glsl.vec3) -> f32 {
    direction := target_pos - object_pos
    // Solo calculamos el ángulo horizontal (eje Y) entre -180° y 180°
    return math.atan2(direction.x, direction.z) * (180.0 / math.PI)
}

cleanup_mesh::proc(mesh_:^mesh){
    gl.DeleteVertexArrays(1,&mesh_.Vao)
    gl.DeleteBuffers(1, &mesh_.Ebo)
    gl.DeleteBuffers(1, &mesh_.Vbo)
    gl.DeleteProgram(mesh_.shader_program)
    gl.DeleteTextures(1,&mesh_.tex_data.texture)
    fmt.println("a Mesh was cleaned")
    
    
}