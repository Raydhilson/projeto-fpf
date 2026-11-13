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
if (defense_cooldown > 0) defense_cooldown--;

// Lógica de dano contínuo de Fogo (Queimadura)
if (queimando_timer > 0) {
    queimando_timer--;
    if (queimando_timer mod 60 == 0) {
        hp -= 0.5;
        piscar = 4;
    }
}

var on_ground = place_meeting(x, y + 1, obj_colisor);

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

// GATILHO DE DEFESA POR DANO: Se tomou um golpe com vida > 0 e tem defesa pronta, reage!
if (hp < hp_anterior && hp > 0 && eh_bombardeiro && defense_cooldown <= 0 && state != enemy_state.chemical_defense) {
    if (alvo != noone) {
        if (alvo.x != x) facing = sign(alvo.x - x);
        state = enemy_state.chemical_defense;
        state_timer = 32; // 18 frames fervendo + 14 frames de jato químico
        hspd = -facing * 2.5; // Dá um pulinho tático para trás ao ativar a defesa
        vspd = -2.0;
    }
}
hp_anterior = hp;

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
        
        if (alvo != noone) {
            if (point_distance(x, y, alvo.x, alvo.y) <= vision_range) {
                state = enemy_state.chase; 
            }
        }
        break;
        
    // --- ESTADO 2: PERSEGUIÇÃO ---
    case enemy_state.chase:
        image_blend = (queimando_timer > 0) ? c_orange : c_red; 
        
        if (alvo != noone) {
            var dist = point_distance(x, y, alvo.x, alvo.y);
            var dir_to_player = sign(alvo.x - x);
            
            if (dir_to_player != 0 && piscar <= 0) {
                facing = dir_to_player;
            }
            
            var no_ledge = !place_meeting(x + (15 * facing), y + 1, obj_colisor);
            if (no_ledge && on_ground) {
                hspd = 0;
            } else if (piscar <= 0) {
                hspd = lerp(hspd, chase_spd * facing, 0.12);
            }
            
            // 1. GATILHO DE MECANISMO DE DEFESA (Se o rato colar demais: <= 55px)
            if (eh_bombardeiro && dist <= 55 && on_ground && defense_cooldown <= 0) {
                state = enemy_state.chemical_defense;
                state_timer = 32; 
                hspd = -facing * 2.0; // Recua levemente preparando o spray
            }
            // 2. GATILHO DE INVESTIDA (Média distância: <= 85px)
            else if (dist <= 85 && on_ground && attack_cooldown <= 0) {
                state = enemy_state.chemical_prep;
                state_timer = 28;
                hspd = 0;
            }
            
            if (dist > lose_interest_range) {
                state = enemy_state.patrol;
            }
        } else {
            state = enemy_state.patrol;
        }
        break;
        
    // --- ESTADO 3: PREPARANDO INVESTIDA (Aviso Visual!) ---
    case enemy_state.chemical_prep:
        hspd = lerp(hspd, 0, 0.3);
        image_blend = ((state_timer div 4) mod 2 == 0) ? c_yellow : c_orange;
        
        if (alvo != noone && alvo.x != x) {
            facing = sign(alvo.x - x);
        }
        
        state_timer--;
        if (state_timer <= 0) {
            state = enemy_state.charge;
            state_timer = 22;
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 2;
            }
        }
        break;
        
    // --- ESTADO 4: INVESTIDA EXPLOSIVA ---
    case enemy_state.charge:
        image_blend = c_orange;
        hspd = facing * charge_spd;
        state_timer--;
        
        // Deixa um rastro de fogo no início da arrancada química se existir obj_fogo_chao
        if (state_timer == 18 && eh_bombardeiro && object_exists(obj_fogo_chao)) {
            instance_create_layer(x, y, layer, obj_fogo_chao);
        }
        
        if (place_meeting(x + facing, y, obj_colisor) || state_timer <= 0) {
            hspd = 0;
            state = enemy_state.cooldown;
            state_timer = 40;
            attack_cooldown = 90;
        }
        break;

    // --- ESTADO 4.5: MECANISMO DE DEFESA (SPRAY QUÍMICO QUE QUEIMA!) ---
    case enemy_state.chemical_defense:
        hspd = lerp(hspd, 0, 0.2);
        
        // Fase 1 (Frames 32 a 15): Pressurizando o abdômen (Pisca Vermelho/Amarelo rápido)
        if (state_timer > 14) {
            image_blend = ((state_timer div 2) mod 2 == 0) ? c_red : c_yellow;
            if (alvo != noone && alvo.x != x) facing = sign(alvo.x - x);
        }
        // Frame 14: EXPLOSÃO DO JATO QUÍMICO FERVENTE!
        else if (state_timer == 14) {
            image_blend = c_orange;
            hspd = -facing * 2.5; // Coice do disparo químico
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 4;
            }
            
            // 1. Cria poças de reação química (obj_fogo_chao) na frente do besouro!
            if (object_exists(obj_fogo_chao)) {
                instance_create_layer(x + (facing * 20), y, layer, obj_fogo_chao);
                instance_create_layer(x + (facing * 42), y, layer, obj_fogo_chao);
            }
            
            // 2. Verifica se algum jogador de pé está na zona do jato químico (56px à frente)
            var _x1 = (facing == 1) ? bbox_right : (bbox_left - 56);
            var _x2 = (facing == 1) ? (bbox_right + 56) : bbox_left;
            var _y1 = bbox_top - 10;
            var _y2 = bbox_bottom + 4;
            
            with (obj_player) {
                if (collision_rectangle(_x1, _y1, _x2, _y2, id, false, false)) {
                    if (!is_invulnerable && state != player_state.roll && state != player_state.downed) {
                        hp -= 12; // Dano direto do jato fervente
                        is_invulnerable = true;
                        iframe_timer = 50;
                        hspd = other.facing * 5.5;
                        vspd = -4.0;
                        state = player_state.air;
                        
                        // Aplica queimadura contínua no jogador por 3 segundos (180 frames)!
                        queimando_player_timer = 180;
                    }
                }
            }
        }
        // Fase 2 (Frames 13 a 1): Mantém a nuvem química ativa
        else {
            image_blend = c_orange;
        }
        
        state_timer--;
        if (state_timer <= 0) {
            state = enemy_state.cooldown;
            state_timer = 35;       // Fica recuperando o fôlego após esvaziar a glândula
            defense_cooldown = 150; // 2.5s de recarga para usar a defesa química novamente
        }
        break;
        
    // --- ESTADO 5: RESFRIANDO (Janela vulnerável pós-ataque) ---
    case enemy_state.cooldown:
        hspd = lerp(hspd, 0, 0.2);
        image_blend = c_gray;
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
// 4. MORTE, XP DE MAESTRIA, BUFF E DROPS DO BESOURO (PARA TODOS OS PLAYERS!)
// ==========================================
if (hp <= 0) {
    var _era_bombardeiro = eh_bombardeiro;
    
    // Concede XP e o Buff de Fogo para TODOS os jogadores ativos na sala!
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
        
        if (_era_bombardeiro) {
            buff_fogo_timer = 600;
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