var gw = display_get_gui_width();
var gh = display_get_gui_height();

// ==========================================
// EFEITO GLOBAL DE BRILHO NA TELA (Roda sempre)
// ==========================================
if (variable_global_exists("brilho")) {
    if (global.brilho < 0.5) {
        draw_set_color(c_black);
        draw_set_alpha((0.5 - global.brilho) * 1.4);
        draw_rectangle(0, 0, gw, gh, false);
        draw_set_alpha(1.0);
    } else if (global.brilho > 0.5) {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha((global.brilho - 0.5) * 0.6);
        draw_rectangle(0, 0, gw, gh, false);
        draw_set_alpha(1.0);
        gpu_set_blendmode(bm_normal);
    }
}

// ==========================================
// MENU DE PAUSA
// ==========================================
if (is_paused) {
    draw_set_font(fnt_menu);
    var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    
    draw_set_color(c_black);
    draw_set_alpha(0.88);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (pause_state == 0) {
        draw_set_color(c_white);
        var _titulo = is_pt ? "--- JOGO EM PAUSA ---" : "--- GAME PAUSED ---";
        draw_text(gw / 2, gh * 0.28, _titulo);
        
        pause_opcoes[0] = is_pt ? "CONTINUAR" : "RESUME";
        pause_opcoes[1] = is_pt ? "OPCOES E CONTROLES" : "OPTIONS & CONTROLS";
        pause_opcoes[2] = is_pt ? "SALVAR E SAIR" : "SAVE & QUIT";
        
        for (var i = 0; i < array_length(pause_opcoes); i++) {
            var yy = (gh * 0.45) + (i * 36);
            if (pause_index == i) {
                draw_set_color(c_yellow);
                draw_text(gw / 2, yy, ">> " + pause_opcoes[i] + " <<");
            } else {
                draw_set_color(c_gray);
                draw_text(gw / 2, yy, pause_opcoes[i]);
            }
        }
    }
   else if (pause_state == 1) {
        draw_set_color(c_white);
        var _titulo_cfg = is_pt ? "--- OPCOES E CONTROLES ---" : "--- OPTIONS & CONTROLS ---";
        draw_text(gw / 2, gh * 0.08, _titulo_cfg);
        
        var txt_sim     = is_pt ? "SIM" : "ON";
        var txt_nao     = is_pt ? "NAO" : "OFF";
        var txt_espera  = is_pt ? "[ PRESSIONE UMA TECLA... ]" : "[ PRESS ANY KEY... ]";
        var _brilho_pct = string(round((variable_global_exists("brilho") ? global.brilho : 0.5) * 100)) + "%";
        
        var lista_cfg = [
            (is_pt ? "IDIOMA: " : "LANGUAGE: ") + global.idioma,
            (is_pt ? "TELA CHEIA: " : "FULLSCREEN: ") + (window_get_fullscreen() ? txt_sim : txt_nao),
            (is_pt ? "TREMER TELA: " : "SCREEN SHAKE: ") + (global.tremer_tela ? txt_sim : txt_nao),
            (is_pt ? "BRILHO: < " : "BRIGHTNESS: < ") + _brilho_pct + " >",
            (is_pt ? "PULO: " : "JUMP: ") + ((aguardando_tecla && pause_index == 4) ? txt_espera : nome_tecla(global.key_jump)),
            (is_pt ? "ATAQUE: " : "ATTACK: ") + ((aguardando_tecla && pause_index == 5) ? txt_espera : nome_tecla(global.key_attack)),
            (is_pt ? "ESQUIVA: " : "ROLL: ") + ((aguardando_tecla && pause_index == 6) ? txt_espera : nome_tecla(global.key_roll)),
            (is_pt ? "CURAR: " : "HEAL: ") + ((aguardando_tecla && pause_index == 7) ? txt_espera : nome_tecla(global.key_heal)),
            (is_pt ? "MOLOTOV: " : "THROW: ") + ((aguardando_tecla && pause_index == 8) ? txt_espera : nome_tecla(global.key_throw)),
            (is_pt ? "ANDAR ESQ: " : "MOVE LEFT: ") + ((aguardando_tecla && pause_index == 9) ? txt_espera : nome_tecla(global.key_left)),
            (is_pt ? "ANDAR DIR: " : "MOVE RIGHT: ") + ((aguardando_tecla && pause_index == 10) ? txt_espera : nome_tecla(global.key_right)),
            (is_pt ? "RESTAURAR PADROES" : "RESET DEFAULTS"),
            (is_pt ? "VOLTAR E SALVAR" : "BACK & SAVE")
        ];
        
        for (var j = 0; j < array_length(lista_cfg); j++) {
            var yy = (gh * 0.16) + (j * 20);
            if (pause_index == j) {
                draw_set_color(aguardando_tecla ? c_orange : c_yellow);
                draw_text(gw / 2, yy, ">> " + lista_cfg[j] + " <<");
            } else {
                draw_set_color(c_gray);
                draw_text(gw / 2, yy, lista_cfg[j]);
            }
        }
    
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}