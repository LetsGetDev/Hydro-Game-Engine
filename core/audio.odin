package core

import "core:fmt"
import ma "vendor:miniaudio"

// Variable global para el motor de audio
audio_engine: ma.engine

// Inicializa el sistema de audio (llamar al inicio del programa)
init_audio :: proc() -> bool {
    if result := ma.engine_init(nil, &audio_engine); result != .SUCCESS {
        fmt.eprintln("Failed to initialize audio engine:", result)
        return false
    }
    return true
}

// Limpieza del audio (llamar al cerrar el programa)
cleanup_audio :: proc() {
    ma.engine_uninit(&audio_engine)
}

// Reproduce un sonido sin bloquear
play_sound :: proc(filename: cstring) {
    // Usamos engine_play_sound que maneja la reproducción en segundo plano
    if result := ma.engine_play_sound(&audio_engine, filename, nil); result != .SUCCESS {
        fmt.eprintln("Failed to play sound:", result)
    }
}