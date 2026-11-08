// ==========================================
// 0. SISTEMA DE HITSTOP (PAUSA O INIMIGO)
// ==========================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
} else {
    image_speed = 1;
}

// ==========================================
// 1. GRAVIDADE, TIMERS E QUEIMADURA
// ==========================================
vspd += grv;
if (piscar > 0) piscar--;
if (attack_cooldown > 0) attack_cooldown--;

// Lógica de dano contínuo de Fogo (Queimadura)
if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

var on_ground = place_meeting(x, y + 1, obj_colisor);

// ==========================================
// 2. MÁQUINA DE ESTADOS DA IA (BESOURO BOMBARDEIRO)
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
        
        if ((hit_wall || no_ledge) && on_ground) {
            facing = -facing; 
        }
        
        if (instance_exists(obj_player)) {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= vision_range) {
                state = enemy_state.chase; 
            }
        }
        break;
        
    // --- ESTADO 2: PERSEGUIÇÃO ---
    case enemy_state.chase:
        image_blend = (queimando_timer > 0) ? c_orange : c_red; 
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            var dir_to_player = sign(obj_player.x - x);
            
            if (dir_to_player != 0 && piscar <= 0) {
                facing = dir_to_player;
            }
            
            // Evita cair de buracos enquanto persegue normal
            var no_ledge = !place_meeting(x + (15 * facing), y + 1, obj_colisor);
            if (no_ledge && on_ground) {
                hspd = 0;
            } else if (piscar <= 0) {
                hspd = lerp(hspd, chase_spd * facing, 0.12);
            }
            
            // GATILHO QUÍMICO: Se chegar perto e o ataque estiver pronto, prepara a explosão!
            if (dist <= 75 && on_ground && attack_cooldown <= 0) {
                state = enemy_state.chemical_prep;
                state_timer = 28; // 0.45s fervendo antes de dar o bote
                hspd = 0;
            }
            
            if (dist > lose_interest_range) {
                state = enemy_state.patrol;
            }
        } else {
            state = enemy_state.patrol;
        }
        break;
        
    // --- ESTADO 3: PREPARANDO REAÇÃO QUÍMICA (Aviso Visual!) ---
    case enemy_state.chemical_prep:
        hspd = lerp(hspd, 0, 0.3);
        // Pisca entre amarelo e laranja fervendo os reagentes
        image_blend = ((state_timer div 4) mod 2 == 0) ? c_yellow : c_orange;
        
        if (instance_exists(obj_player) && obj_player.x != x) {
            facing = sign(obj_player.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            state = enemy_state.charge;
            state_timer = 22; // Duração da arrancada explosiva
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 2; // Tremor do disparo químico
            }
        }
        break;
        
    // --- ESTADO 4: INVESTIDA EXPLOSIVA ---
    case enemy_state.charge:
        image_blend = c_orange;
        hspd = facing * charge_spd;
        state_timer--;
        
        // Se bater na parede ou acabar o impulso, entra em resfriamento
        if (place_meeting(x + facing, y, obj_colisor) || state_timer <= 0) {
            hspd = 0;
            state = enemy_state.cooldown;
            state_timer = 40;     // 40 frames vulnerável para o player bater
            attack_cooldown = 90; // Só pode usar reação química de novo após 1.5s
        }
        break;
        
    // --- ESTADO 5: RESFRIANDO (Janela vulnerável pós-ataque) ---
    case enemy_state.cooldown:
        hspd = lerp(hspd, 0, 0.2);
        image_blend = c_gray; // Fica acinzentado/fumegando enquanto recupera o fôlego
        state_timer--;
        if (state_timer <= 0) {
            state = enemy_state.chase;
        }
        break;
}

if (facing != 0) {
    image_xscale = facing;
}

// ==========================================
// 3. COLISÕES FÍSICAS
// ==========================================
if (place_meeting(x + hspd, y, obj_colisor)) {
    while (!place_meeting(x + sign(hspd), y, obj_colisor)) {
        x += sign(hspd);
    }
    hspd = 0;
}
x += hspd;

if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
        y += sign(vspd);
    }
    vspd = 0;
}
y += vspd;

// ==========================================
// 4. MORTE, XP DE MAESTRIA, BUFF E DROPS DO BESOURO
// ==========================================
if (hp <= 0) {
    if (instance_exists(obj_player)) {
        obj_player.arma_xp += 5;
        
        if (obj_player.arma_xp >= obj_player.arma_xp_max) {
            if (obj_player.arma_nivel == 1) {
                obj_player.arma_nivel = 2;
                obj_player.arma_xp = 0;
                obj_player.arma_xp_max = 20;
            } else if (obj_player.arma_nivel == 2) {
                obj_player.arma_nivel = 3;
                obj_player.arma_xp = obj_player.arma_xp_max;
            }
        }
        
        if (eh_bombardeiro) {
            obj_player.buff_fogo_timer = 600;
        }
    }
    
    // 1. Dropa Sucata garantida
    instance_create_layer(x, y - 6, layer, obj_scrap);
    
    // 2. Chance de dropar Alimento / Carne (70% de chance -> tipo_item = 0)
    if (irandom(99) < 70 && object_exists(obj_item_drop)) {
        var _carne = instance_create_layer(x - 4, y - 8, layer, obj_item_drop);
        _carne.tipo_item = 0;
    }
    
    // 3. Chance de dropar Glândula Química (50% de chance -> tipo_item = 1)
    if (eh_bombardeiro && irandom(99) < 50 && object_exists(obj_item_drop)) {
        var _glandula = instance_create_layer(x + 4, y - 8, layer, obj_item_drop);
        _glandula.tipo_item = 1;
    }
    
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 6;
        obj_game_controller.shake_magnitude = 5;
    }
    
    instance_destroy();
}