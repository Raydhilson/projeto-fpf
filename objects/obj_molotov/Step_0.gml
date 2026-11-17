// Pausa durante o Hitstop
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

vspd += grv; // Gravidade da parábola

// Giro visual no ar
image_angle -= sign(hspd) * 15; 

// 1. Colisão com o Chão/Parede (Cria poça de fogo contínua no solo)
if (collision_circle(x + hspd, y + vspd, 6, obj_colisor, false, true) != noone) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.shake_magnitude = 3;
    }
    if (object_exists(obj_fogo_chao)) {
        instance_create_layer(x, y, layer, obj_fogo_chao);
    }
    instance_destroy(); 
    exit;
}

// 2. Colisão com Inimigos (obj_enemy, obj_vespa e obj_boss_centopeia)
var hit_enemy = collision_circle(x + hspd, y + vspd, 10, obj_enemy, false, true);
if (hit_enemy == noone && object_exists(obj_vespa)) {
    hit_enemy = collision_circle(x + hspd, y + vspd, 10, obj_vespa, false, true);
}
if (hit_enemy == noone && object_exists(obj_boss_centopeia)) {
    hit_enemy = collision_circle(x + hspd, y + vspd, 10, obj_boss_centopeia, false, true);
}

if (hit_enemy != noone) {
    with (hit_enemy) {
        // Se for a Centopeia e estiver debaixo da terra, ignora o impacto
        var pode_acertar = true;
        if (object_index == obj_boss_centopeia) {
            if (state == centopeia_state.subterranea || state == centopeia_state.emergindo) {
                pode_acertar = false;
            }
        }
        
        if (pode_acertar) {
            hp -= 3; // Dano explosivo alto
            piscar = 12;
            
            // Aplica queimadura se o inimigo tiver suporte a fogo
            if (variable_instance_exists(id, "queimando_timer")) {
                queimando_timer = 180;
            }
            
            // Pequeno empurrão
            if (object_index != obj_boss_centopeia) {
                hspd = sign(other.hspd) * 5;
                vspd = -3;
            }
        }
    }
    
    // Impacto visual na tela
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 6;
        obj_game_controller.shake_magnitude = 5;
    }
    
    // Também espalha fogo no chão caso o ponto de impacto esteja próximo ao solo
    if (object_exists(obj_fogo_chao)) {
        instance_create_layer(x, y, layer, obj_fogo_chao);
    }
    
    instance_destroy(); // Quebra o molotov
    exit;
}

// Atualiza a posição
x += hspd;
y += vspd;