// Trava de Hitstop
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

switch (state) {
    
    // 1. PATRULHA SENOIDAL
    case vespa_state.patrulha:
        vspd = sin(current_time / 200) * 1.5;
        hspd = cos(current_time / 300) * 1.0;
        
        if (instance_exists(obj_player)) {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= vision_range) {
                state = vespa_state.perseguicao;
            }
        }
        break;
        
    // 2. PERSEGUIÇÃO MANTENDO ALTURA
    case vespa_state.perseguicao:
        if (instance_exists(obj_player)) {
            var dir = point_direction(x, y, obj_player.x, obj_player.y - 35);
            hspd = lengthdir_x(vel_voo, dir);
            vspd = lengthdir_y(vel_voo, dir);
            
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 110) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
                state_timer = 25; // 25 frames de aviso antes do bote
                state = vespa_state.preparando;
            } else if (dist > vision_range * 1.5) {
                state = vespa_state.patrulha;
            }
        }
        break;
        
    // 3. PREPARANDO O BOTE (Telegraph Visual: Treme no ar mirando)
    case vespa_state.preparando:
        hspd = irandom_range(-1, 1);
        vspd = -0.5; // Sobe levemente antes de mergulhar
        
        if (instance_exists(obj_player)) {
            alvo_x = obj_player.x;
            alvo_y = obj_player.y;
            if (obj_player.x != x) image_xscale = sign(obj_player.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            var dir_rasante = point_direction(x, y, alvo_x, alvo_y);
            hspd = lengthdir_x(vel_voo * 3.8, dir_rasante);
            vspd = lengthdir_y(vel_voo * 3.8, dir_rasante);
            state_timer = 25; // Duração do bote
            state = vespa_state.rasante;
        }
        break;
        
    // 4. ATAQUE RASANTE
    case vespa_state.rasante:
        state_timer--;
        // Se bater no chão/parede ou acabar o tempo, entra em recuperação
        if (place_meeting(x + hspd, y + vspd, obj_colisor) || state_timer <= 0) {
            hspd = 0;
            vspd = 0;
            state_timer = 35; // Pequena janela vulnerável após o ataque
            state = vespa_state.recuperando;
        }
        break;
        
    // 5. RECUPERANDO O FÔLEGO (Janela para o Player contra-atacar)
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

// Morte da Vespa + Drops (Sucata + Chance de Ferrão)
// Morte da Vespa + Drops (Sucata + Chance de Ferrão + XP da Arma)
if (hp <= 0) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 5;
        obj_game_controller.shake_magnitude = 3;
    }
    
    // Dá +5 de XP para a Lança do Rato ao derrotar a Vespa
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 5;
    }
    
    // Dropa Sucata
    instance_create_layer(x, y, layer, obj_scrap);
    
    // 60% de chance de dropar Ferrão (tipo_item = 2) com trava de segurança
    if (irandom(99) < 60 && object_exists(obj_item_drop)) {
        var _drop = instance_create_layer(x, y, layer, obj_item_drop);
        _drop.tipo_item = 2; // Ferrão
    }
    
    instance_destroy();
}
    
