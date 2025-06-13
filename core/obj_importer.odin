package core

import "core:os"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:slice"
import "core:fmt"









// Estructura que contiene los datos de la malla importada
MeshData :: struct {
    vertices: [dynamic]f32,  // Array intercalado de posiciones (x,y,z) y UVs (u,v)
    indices:  [dynamic]u32,  // Array de índices
}

// Crea un nuevo MeshData
new_mesh_data :: proc() -> MeshData {
    return MeshData{
        vertices = make([dynamic]f32),
        indices  = make([dynamic]u32),
    }
}

// Libera la memoria de MeshData
delete_mesh_data :: proc(md: ^MeshData) {
    if md.vertices != nil do delete(md.vertices)
    if md.indices  != nil do delete(md.indices)
}

// Procesa un vértice individual (v/vt/vn) y lo añade a los vértices
process_vertex :: proc(
    tokens: []string,
    temp_positions: [][3]f32,
    temp_uvs: [][2]f32,
    mesh: ^MeshData,
    vertex_cache: ^map[string]u32,
    next_index: ^u32,
) -> u32 {
    face_data := strings.split(tokens[0], "/")
    defer delete(face_data)
    
    if len(face_data) < 1 do return 0
    
    // Crear clave de caché para este vértice
    cache_key := strings.join(face_data[:], "/", context.temp_allocator)
    
    // Verificar si ya hemos procesado este vértice
    if index, found := vertex_cache[cache_key]; found {
        return index
    }
    
    // Procesar posición
    v_idx := strconv.parse_int(face_data[0]) or_else 0
    if v_idx < 0 do v_idx += len(temp_positions) + 1
    v_idx -= 1 // OBJ usa indexación basada en 1
    
    if v_idx >= 0 && v_idx < len(temp_positions) {
        append(&mesh.vertices, temp_positions[v_idx].x)
        append(&mesh.vertices, temp_positions[v_idx].y)
        append(&mesh.vertices, temp_positions[v_idx].z)
    } else {
        append(&mesh.vertices, 0, 0, 0)
    }
    
    // Procesar UV
    if len(face_data) > 1 && len(face_data[1]) > 0 {
        uv_idx := strconv.parse_int(face_data[1]) or_else 0
        if uv_idx < 0 do uv_idx += len(temp_uvs) + 1
        uv_idx -= 1
        
        if uv_idx >= 0 && uv_idx < len(temp_uvs) {
            append(&mesh.vertices, temp_uvs[uv_idx].x)
            append(&mesh.vertices, temp_uvs[uv_idx].y)
        } else {
            append(&mesh.vertices, 0, 0)
        }
    } else {
        append(&mesh.vertices, 0, 0)
    }
    
    // Almacenar en caché y devolver el nuevo índice
    vertex_cache[cache_key] = next_index^
    result := next_index^
    next_index^ += 1
    return result
}

// Importa desde un archivo OBJ con soporte para quads
import_obj :: proc(filename: string) -> (mesh: MeshData, success: bool) {
    mesh = new_mesh_data()
    vertex_cache := make(map[string]u32)
    defer delete(vertex_cache)
    
    data, ok := os.read_entire_file(filename)
    if !ok do return mesh, false
    defer delete(data)
    
    lines := strings.split(string(data), "\n")
    defer delete(lines)
    
    temp_positions: [dynamic][3]f32
    temp_uvs:       [dynamic][2]f32
    next_index: u32 = 0
    
    for line in lines {
        line := strings.trim_space(line)
        if len(line) == 0 || line[0] == '#' do continue
        
        tokens := strings.split(line, " ")
        defer delete(tokens)
        
        if len(tokens) == 0 do continue
        
        switch tokens[0] {
        case "v": // vértice
            if len(tokens) < 4 do continue
            pos: [3]f32
            for i in 0..<3 {
                pos[i] = strconv.parse_f32(tokens[i+1]) or_else 0.0
            }
            append(&temp_positions, pos)
            
        case "vt": // coordenada de textura
            if len(tokens) < 3 do continue
            uv: [2]f32
            for i in 0..<2 {
                uv[i] = strconv.parse_f32(tokens[i+1]) or_else 0.0
            }
            append(&temp_uvs, uv)
            
        case "f": // cara (soporta triángulos y quads)
            if len(tokens) < 4 do continue
            
            vertex_count := len(tokens) - 1
            face_vertices := make([dynamic]u32, 0, vertex_count)
            defer delete(face_vertices)
            
            // Procesar todos los vértices de la cara
            for i in 1..<len(tokens) {
                index := process_vertex(tokens[i:i+1], temp_positions[:], temp_uvs[:], &mesh, &vertex_cache, &next_index)
                append(&face_vertices, index)
            }
            
            // Convertir quads a triángulos (fan triangulation)
            if vertex_count == 4 {
                // Primer triángulo (0, 1, 2)
                append(&mesh.indices, face_vertices[0], face_vertices[1], face_vertices[2])
                // Segundo triángulo (0, 2, 3)
                append(&mesh.indices, face_vertices[0], face_vertices[2], face_vertices[3])
            } else if vertex_count >= 3 {
                // Triángulo simple
                for i in 1..<vertex_count-1 {
                    append(&mesh.indices, face_vertices[0], face_vertices[i], face_vertices[i+1])
                }
            }
        }
    }
    
    return mesh, true
}