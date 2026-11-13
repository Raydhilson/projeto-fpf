// Trava de Hitstop
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

// Localiza o jogador de pé mais próximo (Ignora quem está nocauteado / downed!)
var alvo = noone;
var menor_dist = 999999;
with (obj_player) {
    if (state != player_state.downed) {
        var _d = point_distance(x, y, other.x, other.y);
        if (_d < menor_dist) {
            menor_dist = _d;
            alvo = id;
        }
    }
}

switch (state) {
    
    // 1. PATRULHA SENOIDAL
    case vespa_state.patrulha:
        vspd = sin(current_time / 200) * 1.5;
        hspd = cos(current_time / 300) * 1.0;
        
        if (alvo != noone) {
            if (point_distance(x, y, alvo.x, alvo.y) <= vision_range) {
                state = vespa_state.perseguicao;
            }
        }
        break;
        
    // 2. PERSEGUIÇÃO MANTENDO ALTURA
    case vespa_state.perseguicao:
        if (alvo != noone) {
            var dir = point_direction(x, y, alvo.x, alvo.y - 35);
            hspd = lengthdir_x(vel_voo, dir);
            vspd = lengthdir_y(vel_voo, dir);
            
            var dist = point_distance(x, y, alvo.x, alvo.y);
            if (dist < 110) {
                alvo_x = alvo.x;
                alvo_y = alvo.y;
                state_timer = 25; // 25 frames de aviso antes do bote
                state = vespa_state.preparando;
            } else if (dist > vision_range * 1.5) {
                state = vespa_state.patrulha;
            }
        } else {
            state = vespa_state.patrulha;
        }
        break;
        
    // 3. PREPARANDO O BOTE (Telegraph Visual: Treme no ar mirando)
    case vespa_state.preparando:
        hspd = irandom_range(-1, 1);
        vspd = -0.5;
        
        if (alvo != noone) {
            alvo_x = alvo.x;
            alvo_y = alvo.y;
            if (alvo.x != x) image_xscale = sign(alvo.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            var dir_rasante = point_direction(x, y, alvo_x, alvo_y);
            hspd = lengthdir_x(vel_voo * 3.8, dir_rasante);
            vspd = lengthdir_y(vel_voo * 3.8, dir_rasante);
            state_timer = 25;
            state = vespa_state.rasante;
        }
        break;
        
    // 4. ATAQUE RASANTE
    case vespa_state.rasante:
        state_timer--;
        if (place_meeting(x + hspd, y + vspd, obj_colisor) || state_timer <= 0) {
            hspd = 0;
            vspd = 0;
            state_timer = 35;
            state = vespa_state.recuperando;
        }
        break;
        
    // 5. RECUPERANDO O FÔLEGO
    case vespa_state.recuperando:
        hspd = lerp(hspd, 0, 0.2);
        vspd = sin(current_time / 150) * 0.8;
        state_timer--;
        if (state_timer <= 0) {
            state = vespa_state.perseguicao;
        }
        break;
}

// Aplicação de movimento evitando atravessar paredes
if (!place_meeting(x + hspd, y, obj_colisor)) x += hspd;
if (!place_meeting(x, y + vspd, obj_colisor)) y += vspd;

if (hspd != 0 && state != vespa_state.preparando) {
    image_xscale = sign(hspd);
}

// Morte da Vespa + Drops + XP da Arma para ambos os jogadores
if (hp <= 0) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 3;
    }
    
    with (obj_player) {
        arma_xp += 5;
        if (arma_xp >= arma_xp_max) {
            if (arma_nivel == 1) {
                arma_nivel = 2;
                arma_xp = 0;
                arma_xp_max = 20;
            } else if (arma_nivel == 2) {
                arma_nivel = 3;
                arma_xp = arma_xp_max;
            }
        }
    }
    
    instance_create_layer(x, y, layer, obj_scrap);
    
    if (irandom(99) < 60 && object_exists(obj_item_drop)) {
        var _drop = instance_create_layer(x, y, layer, obj_item_drop);
        _drop.tipo_item = 2; // Ferrão
    }
    
    instance_destroy();
}