// ==========================================
// 0. SISTEMA DE HITSTOP (PAUSA O INIMIGO)
// ==========================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit; // Corta a leitura de física/movimento neste frame!
} else {
    image_speed = 1;
}

// ==========================================
// 1. GRAVIDADE, TIMERS E QUEIMADURA
// ==========================================
vspd += grv;
if (piscar > 0) piscar--;

// Lógica de dano contínuo de Fogo (Queimadura)
if (queimando_timer > 0) {
    queimando_timer--;
    // A cada 60 frames (1 segundo), causa 0.5 de dano de queimadura
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4; // Pisca rapidinho para mostrar que tomou dano do fogo
    }
}

// ==========================================
// 2. MÁQUINA DE ESTADOS DA IA (BESOURO)
// ==========================================
switch (state) {
    
    // --- ESTADO 1: PATRULHA ---
    case enemy_state.patrol:
        if (piscar <= 0) {
            hspd = lerp(hspd, walk_spd * facing, 0.1);
        }
        image_blend = (queimando_timer > 0) ? c_orange : c_white; 
        
        var hit_wall = place_meeting(x + facing, y, obj_colisor);
        var no_ledge = !place_meeting(x + (15 * facing), y + 1, obj_colisor); 
        
        if ((hit_wall || no_ledge) && place_meeting(x, y + 1, obj_colisor)) {
            facing = -facing; 
        }
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            if (dist <= vision_range) {
                state = enemy_state.chase; 
            }
        }
        break;
        
    // --- ESTADO 2: PERSEGUIÇÃO E INVESTIDA TÁTICA ---
    case enemy_state.chase:
        image_blend = (queimando_timer > 0) ? c_orange : c_red; 
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            var dir_to_player = sign(obj_player.x - x);
            
            if (dir_to_player != 0 && piscar <= 0) {
                facing = dir_to_player;
            }
            
            // MELHORIA: Se o rato estiver muito perto (menos de 60 pixels), o besouro dá uma investida rápida para frente!
            if (dist < 60 && place_meeting(x, y + 1, obj_colisor)) {
                hspd = facing * (chase_spd * 1.8); // Dá um "dash" de investida
            } else {
                if (piscar <= 0) {
                    hspd = lerp(hspd, chase_spd * facing, 0.1);
                }
            }
            
            // Perde o interesse se o player fugir muito longe
            if (dist > lose_interest_range) {
                state = enemy_state.patrol;
            }
        } else {
            state = enemy_state.patrol;
        }
        break;
}

// Vira a imagem do inimigo
if (facing != 0) {
    image_xscale = facing;
}

// ==========================================
// 3. COLISÕES FÍSICAS
// ==========================================
// Horizontal
if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) {
        x += sign(hspd);
    }
    hspd = 0;
}
x += hspd;

// Vertical
if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
        y += sign(vspd);
    }
    vspd = 0;
}
y += vspd;

// ==========================================
// 4. MORTE, XP DE MAESTRIA E BUFF DO BESOURO
// ==========================================
if (hp <= 0) {
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 5; // Cada inimigo dá 5 de XP
        show_debug_message("Ganhou 5 XP! Total: " + string(obj_player.arma_xp));
        
        // Verifica o Level Up da Lança (Suporte para Nível 2 e Nível 3)
        if (obj_player.arma_xp >= obj_player.arma_xp_max) {
            if (obj_player.arma_nivel == 1) {
                obj_player.arma_nivel = 2;
                obj_player.arma_xp = 0;
                obj_player.arma_xp_max = 20; // Meta para o Nível 3
                show_debug_message("LEVEL UP! Lança Nível 2: Velocidade +15% e Combo Duplo!");
            } else if (obj_player.arma_nivel == 2) {
                obj_player.arma_nivel = 3;
                obj_player.arma_xp = obj_player.arma_xp_max;
                show_debug_message("LEVEL UP MÁXIMO! Lança Nível 3: Predador Alfa Desbloqueado!");
            }
        }
        
        // BUFF INSTINTIVO: Se for o Besouro Bombardeiro, reveste a lança com fogo por 10s (600 frames)
        if (eh_bombardeiro) {
            obj_player.buff_fogo_timer = 600;
            show_debug_message("BUFF INSTINTIVO ATIVADO! Lança em chamas por 10 segundos!");
        }
    }
    
    // Tremor extra ao matar o inimigo para dar peso ao golpe final
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 6;
        obj_game_controller.shake_magnitude = 5;
    }
    
    instance_destroy();
}