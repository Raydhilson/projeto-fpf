// Trava de Hitstop
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

// Máquina de Estados Aérea
switch (state) {
    
    // --- FLUTUANDO / PATRULHA ---
    case vespa_state.patrulha:
        // Movimento de flutuação senoidal suave (sobe e desce)
        vspd = sin(current_time / 200) * 1.5;
        hspd = cos(current_time / 300) * 1.0;
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist <= vision_range) {
                state = vespa_state.perseguicao;
            }
        }
        break;
        
    // --- TRAVANDO A MIRA (PERSEGUIÇÃO FLUTUANTE) ---
    case vespa_state.perseguicao:
        if (instance_exists(obj_player)) {
            // Voa na direção do player mantendo altura
            var dir = point_direction(x, y, obj_player.x, obj_player.y - 30);
            hspd = lengthdir_x(vel_voo, dir);
            vspd = lengthdir_y(vel_voo, dir);
            
            // Se aproximar o suficiente, prepara o Rasante
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 100) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
                state = vespa_state.rasante;
                rasante_timer = 30; // Tempo de impulso rápido
            }
        }
        break;
        
    // --- O ATAQUE RASANTE ---
    case vespa_state.rasante:
        if (rasante_timer > 0) {
            rasante_timer--;
            // Dispara em linha reta na velocidade máxima contra o alvo travado
            var dir_rasante = point_direction(x, y, alvo_x, alvo_y);
            hspd = lengthdir_x(vel_voo * 3.5, dir_rasante);
            vspd = lengthdir_y(vel_voo * 3.5, dir_rasante);
        } else {
            // Terminou o rasante, volta a perseguir
            state = vespa_state.perseguicao;
        }
        break;
}

// Movimentação com colisão simples
x += hspd;
y += vspd;

// Vira para o lado do movimento
if (hspd != 0) {
    image_xscale = sign(hspd);
}

// Morte da Vespa
if (hp <= 0) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 3;
    }
    instance_destroy();
}