package core

import gl "vendor:OpenGL"
import "vendor:glfw"

default_vertex_shader_source :cstring = `#version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec2 aTexCoord;
    
    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 projection;
    
    out vec2 TexCoord;
    out vec3 FragPosView;  // Solo añadimos esta línea

    void main() {
        // Calculamos posición en view space para el fog
        vec4 viewPos = view * model * vec4(aPos, 1.0);
        FragPosView = viewPos.xyz;  // Y esta línea
        
        gl_Position = projection * viewPos;
        TexCoord = aTexCoord;
    }`

default_fragment_shader_source :cstring =   `#version 330 core
    in vec2 TexCoord;
    in vec3 FragPosView;  // Recibimos la posición en view space
    out vec4 FragColor;
    uniform sampler2D texture1;
    uniform bool useFog = true;
    
    // Parámetros mínimos de fog (puedes convertirlos en uniforms si necesitas ajustarlos)
    const vec3 fogColor = vec3(0.2588, 0.2588, 0.2588);  // Color de niebla
    const float fogDensity = 0.065;               // Densidad de niebla

    void main() {
        vec4 texColor = texture(texture1, TexCoord);
        
        if (useFog){
            float distance = length(FragPosView);           // Distancia a cámara
            float fogFactor = exp(-fogDensity * distance);  // Cálculo de niebla
            texColor.rgb = mix(fogColor, texColor.rgb, fogFactor); // Aplicación
        }
        
        FragColor = texColor;
    }`


create_shaderProgram::proc(frag:^cstring,vertx:^cstring) -> u32{

    // Compilar shaders
    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertex_shader, 1, vertx, nil)
    gl.CompileShader(vertex_shader)

    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragment_shader, 1, frag, nil)
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
