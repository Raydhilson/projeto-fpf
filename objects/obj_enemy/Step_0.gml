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
// 2. MÁQUINA DE ESTADOS DA IA (BESOURO BOMBARDEIRO)
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
            
            // Evita cair de buracos enquanto persegue normal
            var no_ledge = !place_meeting(x + (15 * facing), y + 1, obj_colisor);
            if (no_ledge && on_ground) {
                hspd = 0;
            } else if (piscar <= 0) {
                hspd = lerp(hspd, chase_spd * facing, 0.12);
            }
            
            // GATILHO DE TRANSIÇÃO DE ATAQUE (Decide entre Avanço e Bombardeio Químico)
            if (dist <= 85 && on_ground && attack_cooldown <= 0) {
                state = enemy_state.chemical_prep;
                hspd = 0;
                
                // Se for Bombardeiro e o player estiver muito perto (<= 55px) ou no sorteio tático, usa o Bombardeio!
                if (eh_bombardeiro && (dist <= 55 || irandom(1) == 1)) {
                    tipo_ataque_atual = 1; // Bombardeio (spr_enemy_attack_defense)
                    sprite_index = spr_atk_defense;
                    state_timer = 16; // Tempo para tocar os frames 0 a 2 (preparação química)
                } else {
                    tipo_ataque_atual = 0; // Avanço físico (spr_enemy_attack)
                    sprite_index = spr_atk_charge;
                    state_timer = 14; // Tempo para tocar os frames 0 a 2 (preparação da investida)
                }
                image_index = 0;
            }
            
            if (dist > lose_interest_range) {
                state = enemy_state.patrol;
            }
        } else {
            state = enemy_state.patrol;
        }
        break;
        
    // --- ESTADO 3: PREPARAÇÃO DO ATAQUE (Frames iniciais de Windup: 0 a 2) ---
    case enemy_state.chemical_prep:
        hspd = lerp(hspd, 0, 0.3);
        sprite_index = (tipo_ataque_atual == 1) ? spr_atk_defense : spr_atk_charge;
        image_speed = 0.8; 
        image_blend = c_white;
        
        // Trava nos frames de preparação (0 a 2) antes de soltar o golpe
        if (image_index >= 3) {
            image_index = 2.9;
            image_speed = 0;
        }
        
        if (instance_exists(obj_player) && obj_player.x != x) {
            facing = sign(obj_player.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            state = enemy_state.charge;
            image_index = 3; // Salta exatamente para o Frame 3 (início do impacto/jato!)
            image_speed = 1.1;
            
            if (tipo_ataque_atual == 1) {
                state_timer = 26; // Duração do espirro químico (spr_enemy_attack_defense)
            } else {
                state_timer = 22; // Duração da arrancada física (spr_enemy_attack)
            }
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = (tipo_ataque_atual == 1) ? 3 : 2;
            }
        }
        break;
        
    // --- ESTADO 4: EXECUÇÃO DO ATAQUE (Avanço ou Bombardeio Químico: Frames 3 até o fim) ---
    case enemy_state.charge:
        sprite_index = (tipo_ataque_atual == 1) ? spr_atk_defense : spr_atk_charge;
        image_blend = c_white;
        state_timer--;
        
        if (tipo_ataque_atual == 1) {
            // MODO 1: BOMBARDEIO QUÍMICO (spr_enemy_attack_defense)
            hspd = lerp(hspd, 0, 0.25);
            
            // Cria poça de fogo no chão se o objeto existir no projeto
            if (state_timer == 18 || state_timer == 12) {
                var obj_fogo = asset_get_index("obj_fogo_chao");
                if (obj_fogo == -1) obj_fogo = asset_get_index("obj_poca_fogo");
                if (obj_fogo != -1) {
                    var dist_fogo = (state_timer == 18) ? 28 : 48;
                    instance_create_layer(x + (facing * dist_fogo), y, "Instances", obj_fogo);
                }
            }
        } else {
            // MODO 0: AVANÇO / INVESTIDA (spr_enemy_attack)
            hspd = facing * charge_spd;
        }
        
        // Mantém no último frame se a animação terminar antes dos últimos steps
        if (image_index >= image_number - 1) {
            image_index = image_number - 1;
            image_speed = 0;
        }
        
        // Finaliza o ataque se bater na parede (no avanço) ou quando acabar o state_timer
        var bateu_parede = (tipo_ataque_atual == 0 && place_meeting(x + facing, y, obj_colisor));
        if (bateu_parede || state_timer <= 0) {
            hspd = 0;
            state = enemy_state.cooldown;
            state_timer = 38;     // Janela vulnerável pós-ataque
            attack_cooldown = 90; // 1.5s de recarga
        }
        break;
        
    // --- ESTADO 5: RESFRIANDO (Janela vulnerável pós-ataque) ---
    case enemy_state.cooldown:
        sprite_index = spr_walk;
        image_index = 0;
        image_speed = 0; // Fica parado recuperando o fôlego
        hspd = lerp(hspd, 0, 0.2);
        image_blend = c_ltgray; 
        state_timer--;
        if (state_timer <= 0) {
            image_speed = 1;
            image_blend = c_white;
            state = enemy_state.chase;
        }
        break;
}

// Aplica a direção e a escala reduzida do Besouro (0.75)
if (facing != 0) {
    image_xscale = facing * escala_base;
}
image_yscale = escala_base;

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