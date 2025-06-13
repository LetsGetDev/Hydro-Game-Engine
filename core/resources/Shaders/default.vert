#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec2 TexCoord;
out vec3 FragPosView;

void main() {
    vec4 viewPos = view * model * vec4(aPos, 1.0);
    FragPosView = viewPos.xyz;
    gl_Position = projection * viewPos;
    TexCoord = aTexCoord;
}