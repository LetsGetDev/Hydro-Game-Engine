#version 330 core
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
}