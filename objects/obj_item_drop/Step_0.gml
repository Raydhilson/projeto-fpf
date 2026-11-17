// ==========================================
// 1. TIMERS E FÍSICA DE QUEDA
// ==========================================
if (coletavel_timer > 0) {
    coletavel_timer--;
}

vspd += grv;

// Colisão Horizontal
if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) {
        x += sign(hspd);
    }
    hspd = 0;
}
x += hspd;

// Colisão Vertical e Frenagem no Chão
if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
        y += sign(vspd);
    }
    vspd = 0;
    hspd = lerp(hspd, 0, 0.2); // Freia gradualmente ao tocar o solo
}
y += vspd;

// ==========================================
// 2. COLETA PELO JOGADOR
// ==========================================
if (coletavel_timer <= 0 && instance_exists(obj_player)) {
    if (place_meeting(x, y, obj_player)) {
        switch (tipo_item) {
            case 0: obj_player.carne_count++;    break; // Carne (Besouro)
            case 1: obj_player.glandula_count++; break; // Glândula (Besouro)
            case 2: obj_player.ferrao_count++;   break; // Ferrão (Vespa)
        }
        
        // Futuramente aqui entra o som de coleta: audio_play_sound(snd_pickup, 1, false);
        instance_destroy();
    }
}