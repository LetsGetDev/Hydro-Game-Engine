package core

import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:os"
import "core:strings"
import "core:fmt"


create_shaderProgram::proc(frag_path:string,vertx_path:string) -> u32{


    //loading vertex shader
    vertx_data , vertx_ok:= os.read_entire_file(vertx_path)
    if vertx_data == nil do fmt.panicf("No se pudo cargar el vertex shader: %s", vertx_path)
    defer delete(vertx_data)
    vertx_source:= strings.clone_to_cstring(string(vertx_data))
    defer delete(vertx_source)

    //loading fragment shader
    frag_data, frag_ok:= os.read_entire_file(frag_path)
    if frag_data == nil do fmt.panicf("No se pudo cargar el fragment shader: %s", frag_path)
    defer delete(frag_data)
    frag_source:= strings.clone_to_cstring(string(frag_data))
    defer delete( frag_source)

    // Compilar shaders
    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, &vertx_source, nil)
    gl.CompileShader(vertex_shader)

    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, &frag_source, nil)
    gl.CompileShader(fragment_shader)

    // Crear programa de shaders
    shader_program := gl.CreateProgram()
    gl.AttachShader(shader_program, vertex_shader)
    gl.AttachShader(shader_program, fragment_shader)
    gl.LinkProgram(shader_program)

    gl.DeleteShader(vertex_shader)
    gl.DeleteShader(fragment_shader)

    return shader_program
}
