// ==========================================
// 0. SISTEMA DE HITSTOP (PAUSA O CHEFE)
// ==========================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

if (piscar > 0) piscar--;

// Dano de queimadura se a lança estiver em chamas
if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

// Super Armor: impede que a estocada do rato jogue o chefe para o alto
if (piscar == 9 && state != centopeia_state.emergindo) {
    vspd = 0;
    hspd *= 0.2; // Reduz 80% do empurrão da lança (chefe pesado!)
}

// ==========================================
// 1. MÁQUINA DE ESTADOS DA CENTOPEIA
// ==========================================
switch (state) {
    
    // --- ESTADO 1: SUBTERRÂNEA (ESCONDIDA) ---
    case centopeia_state.subterranea:
        hspd = 0;
        vspd = 0;
        image_blend = c_dkgray; 
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist < 200) {
                alvo_x = obj_player.x;
                alvo_y = obj_player.y;
                state = centopeia_state.emergindo;
                action_timer = 45; 
                
                if (instance_exists(obj_game_controller)) {
                    obj_game_controller.shake_timer = 45;
                    obj_game_controller.shake_magnitude = 1;
                }
            }
        }
        break;
        
    // --- ESTADO 2: EMERGINDO (O BOTE SURPRESA) ---
    case centopeia_state.emergindo:
        hspd = 0;
        vspd = 0;
        image_blend = c_orange; 
        
        action_timer--;
        if (action_timer <= 0) {
            x = alvo_x;
            y = alvo_y - 20;
            vspd = -6; 
            state = centopeia_state.patrulha_luta;
            action_timer = 120; 
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.hitstop_timer = 12;
                obj_game_controller.shake_magnitude = 8;
            }
        }
        break;
        
    // --- ESTADO 3: COMBATE NA TELA ---
    case centopeia_state.patrulha_luta:
        image_blend = c_red; 
        vspd += grv;
        
        if (instance_exists(obj_player)) {
            var dir = sign(obj_player.x - x);
            if (dir != 0) facing = dir;
            
            hspd = facing * 2.0;
            
            action_timer--;
            if (action_timer <= 0) {
                // Sorteia entre Investida, Cuspir Ácido ou Cavar
                var proximo_ataque = choose(
                    centopeia_state.investida, 
                    centopeia_state.cuspindo, 
                    centopeia_state.cavando
                );
                
                state = proximo_ataque;
                
                if (proximo_ataque == centopeia_state.investida) {
                    action_timer = 30;
                } else if (proximo_ataque == centopeia_state.cuspindo) {
                    action_timer = 60;
                } else {
                    action_timer = 30; // Tempo afundando na terra
                }
            }
        }
        break;
        
    // --- ESTADO 4: INVESTIDA FEROZ ---
    case centopeia_state.investida:
        hspd = facing * 5.5; 
        vspd += grv; // Mantém gravidade caso passe por uma borda
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.patrulha_luta;
            action_timer = 90;
        }
        break;

    // --- ESTADO 5: CUSPINDO ÁCIDO ---
    case centopeia_state.cuspindo:
        hspd = 0;
        vspd += grv;
        image_blend = c_lime;
        
        if (instance_exists(obj_player)) {
            var dir = sign(obj_player.x - x);
            if (dir != 0) facing = dir;
        }
        
        action_timer--;
        
        if (action_timer == 40 || action_timer == 25 || action_timer == 10) {
            var tiro = instance_create_layer(x + (facing * 20), y - 16, "Instances", obj_acido_centopeia);
            var dist_x = instance_exists(obj_player) ? abs(obj_player.x - x) : 120;
            var forca_h = clamp(dist_x / 35, 3, 7) + random_range(-0.8, 0.8);
            
            tiro.hspd = facing * forca_h;
            tiro.vspd = random_range(-6.5, -4.5);
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 2;
            }
        }
        
        if (action_timer <= 0) {
            state = centopeia_state.patrulha_luta;
            action_timer = 90;
        }
        break;
        
    // --- ESTADO 6: CAVANDO (FUGINDO PARA O SUBTERRÂNEO) ---
    case centopeia_state.cavando:
        hspd = 0;
        vspd = 1.5; // Afunda visualmente no chão
        image_blend = c_dkgray;
        
        action_timer--;
        if (action_timer <= 0) {
            state = centopeia_state.subterranea;
        }
        break;
}

if (facing != 0) {
    image_xscale = facing;
}

// ==========================================
// 2. COLISÕES FÍSICAS (IGNORA O CHÃO QUANDO ESTÁ CAVANDO)
// ==========================================
if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) {
        x += sign(hspd);
    }
    hspd = 0;
}
x += hspd;

// Só colide com o chão se NÃO estiver cavando para fugir
if (state != centopeia_state.cavando && state != centopeia_state.subterranea) {
    if (place_meeting(x, y + vspd, obj_colisor)) {
        while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
            y += sign(vspd);
        }
        vspd = 0;
    }
}
y += vspd;

// ==========================================
// 3. MORTE DO CHEFE (VITÓRIA DA DEMO!)
// ==========================================
if (hp <= 0) {
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 30;
        obj_game_controller.shake_magnitude = 10;
    }
    show_debug_message("CHEFE DERROTADO! A floresta está livre!");
    
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 50;
    }
    
    instance_destroy();
}