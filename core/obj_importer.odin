package core

import "core:os"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:slice"
import "core:fmt"

// Updated MeshData structure to include normals
MeshData :: struct {
    vertices: [dynamic]f32,  // Interleaved: position (x,y,z), UV (u,v), normal (nx,ny,nz)
    indices:  [dynamic]u32,  // Vertex indices
}

new_mesh_data :: proc() -> MeshData {
    return MeshData{
        vertices = make([dynamic]f32),
        indices  = make([dynamic]u32),
    }
}

delete_mesh_data :: proc(md: ^MeshData) {
    if md.vertices != nil do delete(md.vertices)
    if md.indices  != nil do delete(md.indices)
}

process_vertex :: proc(
    tokens: []string,
    temp_positions: [][3]f32,
    temp_uvs:       [][2]f32,
    temp_normals:   [][3]f32,
    mesh: ^MeshData,
    vertex_cache: ^map[string]u32,
    next_index: ^u32,
) -> u32 {
    if len(tokens) == 0 do return 0
    
    // Use original token as cache key
    cache_key := tokens[0]
    
    // Return cached index if exists
    if index, found := vertex_cache[cache_key]; found {
        return index
    }
    
    // Split vertex components (v/vt/vn)
    face_data := strings.split(cache_key, "/", context.temp_allocator)
    component_count := len(face_data)
    
    // Process position (always required)
    v_idx := component_count > 0 ? strconv.parse_int(face_data[0]) or_else 0 : 0
    if v_idx < 0 do v_idx += len(temp_positions) + 1
    v_idx -= 1  // Convert to 0-based index
    
    if v_idx >= 0 && v_idx < len(temp_positions) {
        append(&mesh.vertices, temp_positions[v_idx].x, temp_positions[v_idx].y, temp_positions[v_idx].z)
    } else {
        append(&mesh.vertices, 0, 0, 0) // Default position
    }
    
    // Process texture coordinate (optional)
    uv_idx := -1
    if component_count > 1 && len(face_data[1]) > 0 {
        uv_idx = strconv.parse_int(face_data[1]) or_else 0
        if uv_idx < 0 do uv_idx += len(temp_uvs) + 1
        uv_idx -= 1
    }
    
    if uv_idx >= 0 && uv_idx < len(temp_uvs) {
        append(&mesh.vertices, temp_uvs[uv_idx].x, temp_uvs[uv_idx].y)
    } else {
        append(&mesh.vertices, 0, 0) // Default UV
    }
    
    // Process normal (optional)
    n_idx := -1
    if component_count > 2 && len(face_data[2]) > 0 {
        n_idx = strconv.parse_int(face_data[2]) or_else 0
        if n_idx < 0 do n_idx += len(temp_normals) + 1
        n_idx -= 1
    }
    
    if n_idx >= 0 && n_idx < len(temp_normals) {
        append(&mesh.vertices, temp_normals[n_idx].x, temp_normals[n_idx].y, temp_normals[n_idx].z)
    } else {
        append(&mesh.vertices, 0, 0, 0) // Default normal
    }
    
    // Cache and return new index
    vertex_cache[cache_key] = next_index^
    result := next_index^
    next_index^ += 1
    return result
}

import_obj :: proc(filename: string) -> (mesh: MeshData, success: bool) {
    mesh = new_mesh_data()
    vertex_cache := make(map[string]u32)
    defer delete(vertex_cache)
    
    data, ok := os.read_entire_file(filename)
    if !ok do return mesh, false
    defer delete(data)
    
    lines := strings.split(string(data), "\n")
    defer delete(lines)
    
    temp_positions := make([dynamic][3]f32)
    temp_uvs       := make([dynamic][2]f32)
    temp_normals   := make([dynamic][3]f32)
    defer {
        delete(temp_positions)
        delete(temp_uvs)
        delete(temp_normals)
    }
    
    next_index: u32 = 0
    
    for &line in lines {
        line = strings.trim_space(line)
        if len(line) == 0 || line[0] == '#' do continue
        
        tokens := strings.split(line, " ")
        defer delete(tokens)
        if len(tokens) < 1 do continue
        
        switch tokens[0] {
        case "v":  // Vertex position
            if len(tokens) < 4 do continue
            pos: [3]f32
            for i in 0..<3 {
                pos[i] = strconv.parse_f32(tokens[i+1]) or_else 0.0
            }
            append(&temp_positions, pos)
            
        case "vt":  // Texture coordinate
            if len(tokens) < 3 do continue
            uv: [2]f32
            for i in 0..<2 {
                uv[i] = strconv.parse_f32(tokens[i+1]) or_else 0.0
            }
            append(&temp_uvs, uv)
            
        case "vn":  // Vertex normal
            if len(tokens) < 4 do continue
            norm: [3]f32
            for i in 0..<3 {
                norm[i] = strconv.parse_f32(tokens[i+1]) or_else 0.0
            }
            append(&temp_normals, norm)
            
        case "f":  // Face
            if len(tokens) < 4 do continue
            vertex_count := len(tokens) - 1
            
            // Process all vertices in face
            face_vertices := make([dynamic]u32, 0, vertex_count)
            defer delete(face_vertices)
            
            for i in 1..<len(tokens) {
                idx := process_vertex(
                    tokens[i:i+1], 
                    temp_positions[:], 
                    temp_uvs[:], 
                    temp_normals[:], 
                    &mesh, 
                    &vertex_cache, 
                    &next_index
                )
                append(&face_vertices, idx)
            }
            
            // Triangulate face
            if vertex_count >= 3 {
                for i in 1..<vertex_count-1 {
                    append(&mesh.indices, face_vertices[0], face_vertices[i], face_vertices[i+1])
                }
            }
        }
    }
    
    return mesh, true
}