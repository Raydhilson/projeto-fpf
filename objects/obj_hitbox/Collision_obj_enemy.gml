if (other.piscar <= 0) {
    var dano_final = dano;
    var foi_critico = false;
    
    // 1. CÁLCULO DE ACERTO CRÍTICO (15% base, ou 30% no Nível 3 de Maestria)
    var chance = variable_global_exists("chance_critico") ? global.chance_critico : 15;
    if (instance_exists(obj_player) && obj_player.arma_nivel >= 3) {
        chance = 30; // Bônus do Nível 3 de Maestria
    }
    
    if (random(100) < chance) {
        foi_critico = true;
        var mult = variable_global_exists("multiplicador_crit") ? global.multiplicador_crit : 2.0;
        dano_final = dano * mult;
    }
    
    // 2. APLICA DANO E EFEITO DE QUEIMADURA (BUFF DO BESOURO)
    other.hp -= dano_final;
    other.piscar = 10; 
    
    if (aplica_fogo) {
        other.queimando_timer = 180; // Queima o inimigo por 3 segundos (180 frames)
    }
    
    // 3. KNOCKBACK (Mais forte se for crítico)
    var kb_forca = foi_critico ? 9 : 6;
    other.hspd = sign(image_xscale) * kb_forca; 
    other.vspd = -4;                     
    
    // 4. HITSTOP E SCREEN SHAKE (Pesado no Crítico, Suave e Seco no Normal)
    if (instance_exists(obj_game_controller)) {
        if (foi_critico) {
            obj_game_controller.hitstop_timer = 10;   // Congelamento pesado de crítico
            obj_game_controller.shake_magnitude = 5;  // Tremor forte
            show_debug_message("CRITICO BRUTAL! Dano: " + string(dano_final) + " | Vida do Inimigo: " + string(other.hp));
        } else {
            obj_game_controller.hitstop_timer = 4;    // 4 frames (curto e seco)
            obj_game_controller.shake_magnitude = 1.5; // Tremor sutil de 1.5 pixels
            show_debug_message("BATEU! Vida do Inimigo: " + string(other.hp));
        }
    }
}