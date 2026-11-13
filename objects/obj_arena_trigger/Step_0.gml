// Pause ou Hitstop
if (instance_exists(obj_game_controller) && (obj_game_controller.is_paused || obj_game_controller.hitstop_timer > 0)) {
    exit;
}

if (aviso_timer > 0) aviso_timer--;

// ==========================================
// ESTADO 0: AGUARDANDO JOGADOR ENTRAR NA ZONA
// ==========================================
if (arena_state == 0) {
    if (instance_exists(obj_player)) {
        var _p = instance_nearest(x, y, obj_player);
        // Quando o jogador chega perto do centro do gatilho, tranca a arena!
        if (abs(_p.x - x) < 48 && abs(_p.y - y) < 60) {
            arena_state = 1;
            wave_atual = 1;
            wave_delay_timer = 45; // 0.75s antes da Onda 1 nascer
            aviso_timer = 120;
            
            // Puxa o Player 2 junto caso ele esteja um pouco atrás da porta!
            with (obj_player) {
                x = clamp(x, other.x - other.arena_half_w + 28, other.x + other.arena_half_w - 28);
            }
            
            // Cria as 2 barreiras físicas laterais usando o próprio obj_colisor
            parede_esq = instance_create_layer(x - arena_half_w, y - arena_height, layer, obj_colisor);
            parede_esq.image_xscale = 1;
            parede_esq.image_yscale = arena_height / max(1, sprite_get_height(parede_esq.sprite_index));
            parede_esq.visible = false; // Desenharemos o visual de laser/grade no Draw!
            
            parede_dir = instance_create_layer(x + arena_half_w - 16, y - arena_height, layer, obj_colisor);
            parede_dir.image_xscale = 1;
            parede_dir.image_yscale = arena_height / max(1, sprite_get_height(parede_dir.sprite_index));
            parede_dir.visible = false;
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 6;
            }
        }
    }
}

// ==========================================
// ESTADO 1: ARENA TRANCADA (GERENCIANDO WAVES)
// ==========================================
else if (arena_state == 1) {
    // 1. Limpa da lista os inimigos que já morreram
    for (var i = array_length(inimigos_arena) - 1; i >= 0; i--) {
        if (!instance_exists(inimigos_arena[i])) {
            array_delete(inimigos_arena, i, 1);
        }
    }
    
    // 2. Se está no intervalo de spawnar a onda atual
    if (wave_delay_timer > 0) {
        wave_delay_timer--;
        
        if (wave_delay_timer == 0) {
            var _spawn_esq = x - arena_half_w + 42;
            var _spawn_dir = x + arena_half_w - 42;
            
            if (wave_atual == 1) {
                // ONDA 1: 2 Besouros Bombardeiros nas pontas
                var e1 = instance_create_layer(_spawn_esq, y - 16, layer, obj_enemy);
                var e2 = instance_create_layer(_spawn_dir, y - 16, layer, obj_enemy);
                array_push(inimigos_arena, e1, e2);
            }
            else if (wave_atual == 2) {
                // ONDA 2: 1 Besouro + 2 Vespas aéreas
                var e1 = instance_create_layer(_spawn_esq, y - 16, layer, obj_enemy);
                array_push(inimigos_arena, e1);
                if (object_exists(obj_vespa)) {
                    var v1 = instance_create_layer(_spawn_esq + 20, y - 75, layer, obj_vespa);
                    var v2 = instance_create_layer(_spawn_dir - 20, y - 75, layer, obj_vespa);
                    array_push(inimigos_arena, v1, v2);
                }
            }
            else if (wave_atual == 3) {
                // ONDA 3 (FINAL): 2 Besouros + 2 Vespas
                var e1 = instance_create_layer(_spawn_esq, y - 16, layer, obj_enemy);
                var e2 = instance_create_layer(_spawn_dir, y - 16, layer, obj_enemy);
                array_push(inimigos_arena, e1, e2);
                if (object_exists(obj_vespa)) {
                    var v1 = instance_create_layer(x - 60, y - 85, layer, obj_vespa);
                    var v2 = instance_create_layer(x + 60, y - 85, layer, obj_vespa);
                    array_push(inimigos_arena, v1, v2);
                }
            }
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 4;
            }
        }
    }
    // 3. Se todos os inimigos da onda atual morreram, avança para a próxima ou destranca!
    else if (array_length(inimigos_arena) == 0) {
        if (wave_atual < max_waves) {
            wave_atual++;
            wave_delay_timer = 65; // 1 segundo de respiro antes da próxima onda
            aviso_timer = 110;
        } else {
            // VITÓRIA NA ARENA! Destranca as portas e solta recompensa!
            arena_state = 2;
            aviso_timer = 150;
            
            if (instance_exists(parede_esq)) instance_destroy(parede_esq);
            if (instance_exists(parede_dir)) instance_destroy(parede_dir);
            
            if (instance_exists(obj_game_controller)) {
                obj_game_controller.shake_magnitude = 7;
            }
            
            // Chuva de Sucatas de recompensa no centro da arena
            if (object_exists(obj_scrap)) {
                repeat(6) {
                    instance_create_layer(x + irandom_range(-40, 40), y - 20, layer, obj_scrap);
                }
            }
        }
    }
}