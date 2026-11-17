// ==========================================
// CONFIGURAÇÃO AUTOMÁTICA DAS SPRITES DO BESOURO
// ==========================================
var spr_walk = (asset_get_index("spr_enemy_walk") != -1) ? asset_get_index("spr_enemy_walk") : ((asset_get_index("spr_besouro_walk") != -1) ? asset_get_index("spr_besouro_walk") : sprite_index);
var spr_atk_charge  = (asset_get_index("spr_enemy_attack") != -1) ? asset_get_index("spr_enemy_attack") : spr_walk;
var spr_atk_defense = (asset_get_index("spr_enemy_attack_defense") != -1) ? asset_get_index("spr_enemy_attack_defense") : spr_atk_charge;

if (!variable_instance_exists(id, "tipo_ataque_atual")) tipo_ataque_atual = 0;
if (!variable_instance_exists(id, "escala_base")) escala_base = 0.75;

// ==========================================
// 0. SISTEMA DE HITSTOP (PAUSA O INIMIGO)
// ==========================================
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    image_speed = 0;
    exit;
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
// MÁQUINA DE ESTADOS DA IA (BESOURO TÁTICO)
// ==========================================
switch (state) {
    
    // --- ESTADO 1: PATRULHA ---
    case enemy_state.patrol:
        if (sprite_index != spr_walk) {
            sprite_index = spr_walk;
            image_index = 0;
        }
        image_speed = 1;
        
        if (piscar <= 0) {
            hspd = lerp(hspd, walk_spd * facing, 0.1);
        }
        image_blend = (queimando_timer > 0) ? c_orange : c_white; 
        
        var hit_wall = place_meeting(x + (facing * 2), y, obj_colisor);
        var no_ledge = !place_meeting(x + (20 * facing), y + 2, obj_colisor); 
        
        if ((hit_wall || no_ledge) && on_ground) {
            facing = -facing; 
        }
        
        if (instance_exists(obj_player)) {
            if (point_distance(x, y, obj_player.x, obj_player.y) <= vision_range && abs(y - obj_player.y) < 48) {
                state = enemy_state.chase; 
            }
        }
        break;
        
    // --- ESTADO 2: PERSEGUIÇÃO (Tenta alcançar o range de bote) ---
    case enemy_state.chase:
        if (sprite_index != spr_walk) {
            sprite_index = spr_walk;
            image_index = 0;
        }
        image_speed = 1.25;
        image_blend = (queimando_timer > 0) ? c_orange : c_white; 
        
        if (instance_exists(obj_player)) {
            var dist = point_distance(x, y, obj_player.x, obj_player.y);
            var dir_to_player = sign(obj_player.x - x);
            
            if (dir_to_player != 0 && piscar <= 0) {
                facing = dir_to_player;
            }
            
            var no_ledge = !place_meeting(x + (20 * facing), y + 2, obj_colisor);
            var hit_wall = place_meeting(x + (facing * 2), y, obj_colisor);
            
            if ((no_ledge || hit_wall) && on_ground) {
                hspd = 0; 
            } else if (piscar <= 0) {
                hspd = lerp(hspd, chase_spd * facing, 0.12);
            }
            
            // QUANDO CHEGA NO RANGE DE BOTE (Ex: 95 pixels) E O COOLDOWN ACABOU:
            // Ele entra na preparação de 1 segundo (60 frames) antes de dar o charge!
            if (dist <= 95 && on_ground && attack_cooldown <= 0) {
                state = enemy_state.chemical_prep;
                hspd = 0;
                tipo_ataque_atual = 0; // 0 = Investida
                sprite_index = spr_atk_charge;
                image_index = 0;
                state_timer = 60; // EXATAMENTE 1 SEGUNDO DE PREPARAÇÃO (60 steps)
            }
            
            if (dist > lose_interest_range) {
                state = enemy_state.patrol;
            }
        } else {
            state = enemy_state.patrol;
        }
        break;
        
    // --- ESTADO 3: PREPARAÇÃO DE 1 SEGUNDO (Janela de Reação do Player) ---
    case enemy_state.chemical_prep:
        hspd = lerp(hspd, 0, 0.3); // Para totalmente para focar no bote
        image_speed = 0.5; // Animação mais lenta tensionando o corpo
        image_blend = c_white;
        
        // Mantém olhando para o player durante a preparação
        if (instance_exists(obj_player) && obj_player.x != x) {
            facing = sign(obj_player.x - x);
        }
        
        state_timer--; // Conta os 60 frames (1 segundo)
        
        if (state_timer <= 0) {
            state = enemy_state.charge; // Libera o avanço!
            image_index = 0;
            image_speed = 1.3;
            state_timer = 24; // Duração máxima da investida
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 3;
            }
        }
        break;
        
    // --- ESTADO 4: EXECUÇÃO DO CHARGE (O Avanço) ---
    case enemy_state.charge:
        sprite_index = spr_atk_charge;
        image_blend = c_white;
        state_timer--;
        
        // Aqui ele acelera com força para a frente
        hspd = facing * charge_spd;
        
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        var bateu_parede = place_meeting(x + facing, y, obj_colisor);
        if (bateu_parede || state_timer <= 0) {
            hspd = 0;
            state = enemy_state.cooldown;
            state_timer = 45;     // Janela generosa para o player punir o besouro pós-investida
            attack_cooldown = 110; // Tempo até ele poder dar outro bote
        }
        break;
        
    // --- ESTADO 5: COOLDOWN (Janela de Punição) ---
    case enemy_state.cooldown:
        sprite_index = spr_walk;
        image_index = 0;
        image_speed = 0; 
        hspd = lerp(hspd, 0, 0.2);
        image_blend = c_ltgray; // Fica cinza indicando cansaço/vulnerabilidade
        state_timer--;
        if (state_timer <= 0) {
            image_speed = 1;
            image_blend = c_white;
            state = enemy_state.chase;
        }
        break;
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
// 4. MORTE E DROPS
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
    
    instance_create_layer(x, y - 6, layer, obj_scrap);
    
    if (irandom(99) < 70 && object_exists(obj_item_drop)) {
        var _carne = instance_create_layer(x - 4, y - 8, layer, obj_item_drop);
        _carne.tipo_item = 0;
    }
    
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