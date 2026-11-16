var gw = display_get_gui_width();
var gh = display_get_gui_height();

// ==========================================
// 1. EFEITO GLOBAL DE BRILHO NA TELA
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
// 2. MENU DE PAUSA EM TELA INTEIRA (UI MODERNA)
// ==========================================
if (is_paused) {
    draw_set_font(fnt_menu);
    var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    
    var col_bg_panel   = make_color_rgb(18, 20, 26);
    var col_header     = make_color_rgb(28, 32, 42);
    var col_border_out = make_color_rgb(90, 80, 65);
    var col_gold       = make_color_rgb(235, 185, 60);
    var col_highlight  = make_color_rgb(45, 50, 65);
    var col_text_off   = make_color_rgb(150, 155, 165);
    
    // Fundo escuro cobrindo a tela inteira por trás da pausa
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    // ----------------------------------------------------
    // TELA 0: PAUSA PRINCIPAL
    // ----------------------------------------------------
    if (pause_state == 0) {
        var pw = min(420, gw * 0.80);
        var ph = min(280, gh * 0.70);
        var px = (gw - pw) / 2;
        var py = (gh - ph) / 2;
        
        draw_set_color(col_bg_panel);
        draw_rectangle(px, py, px + pw, py + ph, false);
        
        draw_set_color(col_header);
        draw_rectangle(px, py, px + pw, py + 50, false);
        
        draw_set_color(col_border_out);
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_color(col_gold);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
        draw_line(px + 3, py + 50, px + pw - 3, py + 50);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(col_gold);
        draw_text(gw / 2, py + 25, is_pt ? "JOGO EM PAUSA" : "GAME PAUSED");
        
        pause_opcoes[0] = is_pt ? "CONTINUAR" : "RESUME";
        pause_opcoes[1] = is_pt ? "OPCOES E CONTROLES" : "OPTIONS & CONTROLS";
        pause_opcoes[2] = is_pt ? "SALVAR E SAIR" : "SAVE & QUIT";
        
        var start_y = py + 105;
        var row_h   = 50;
        
        for (var i = 0; i < array_length(pause_opcoes); i++) {
            var yy = start_y + (i * row_h);
            var bx1 = px + 24;
            var bx2 = px + pw - 24;
            
            if (pause_index == i) {
                draw_set_color(col_highlight);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, false);
                draw_set_color(col_gold);
                draw_rectangle(bx1, yy - 18, bx1 + 6, yy + 18, false);
                draw_set_color(col_border_out);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, true);
                
                draw_set_color(c_white);
                draw_text(gw / 2, yy, pause_opcoes[i]);
            } else {
                draw_set_color(col_text_off);
                draw_text(gw / 2, yy, pause_opcoes[i]);
            }
        }
    }
    // ----------------------------------------------------
    // TELA 1: OPÇÕES E CONTROLES EM ABAS SEPARADAS
    // ----------------------------------------------------
    else if (pause_state == 1) {
        if (!variable_instance_exists(id, "opcao_aba")) opcao_aba = 0;
        
        var pw = min(620, gw * 0.90);
        var ph = min(420, gh * 0.88);
        var px = (gw - pw) / 2;
        var py = (gh - ph) / 2;
        
        draw_set_color(col_bg_panel);
        draw_rectangle(px, py, px + pw, py + ph, false);
        draw_set_color(col_border_out);
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_color(col_gold);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
        
        // --- DESENHO DAS ABAS SUPERIORES ---
        var tab_w = (pw - 6) / 2;
        var tab_h = 44;
        var nomes_abas = [
            is_pt ? "1. GERAL E VIDEO" : "1. GENERAL & VIDEO",
            is_pt ? "2. CONTROLES" : "2. CONTROLS"
        ];
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        for (var t = 0; t < 2; t++) {
            var tx1 = px + 3 + (t * tab_w);
            var tx2 = tx1 + tab_w;
            var ty1 = py + 3;
            var ty2 = ty1 + tab_h;
            
            if (opcao_aba == t) {
                draw_set_color(col_highlight);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_gold);
                draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
                draw_set_color(c_white);
                draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t]);
            } else {
                draw_set_color(col_header);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_text_off);
                draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t]);
            }
        }
        
        var txt_sim     = is_pt ? "LIGADO" : "ON";
        var txt_nao     = is_pt ? "DESLIGADO" : "OFF";
        var txt_espera  = is_pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
        var val_brilho  = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
        var _brilho_pct = string(round(val_brilho * 100)) + "%";
        
        // --- CONTEÚDO DA ABA 0: GERAL E VÍDEO ---
        if (opcao_aba == 0) {
            var labels_aba0 = [
                is_pt ? "Idioma do Jogo" : "Game Language",
                is_pt ? "Modo Tela Cheia" : "Fullscreen Mode",
                is_pt ? "Tremor de Tela (Shake)" : "Screen Shake",
                is_pt ? "Nivel de Brilho" : "Brightness Level",
                is_pt ? "Voltar ao Menu" : "Back to Menu"
            ];
            
            var values_aba0 = [
                "< " + global.idioma + " >",
                "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
                "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
                "< " + _brilho_pct + " >",
                ""
            ];
            
            var row_h = 44;
            var list_y = py + 80;
            
            for (var idx = 0; idx < array_length(labels_aba0); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 28;
                var rx2 = px + pw - 28;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 18, rx2, yy + 18, false);
                    draw_set_color(col_gold);
                    draw_rectangle(rx1, yy - 18, rx1 + 5, yy + 18, false);
                }
                
                draw_set_halign(fa_left);
                draw_set_color(is_sel ? c_white : col_text_off);
                draw_text(rx1 + 16, yy, labels_aba0[idx]);
                
                draw_set_halign(fa_right);
                draw_set_color(is_sel ? col_gold : c_ltgray);
                
                if (idx == 3) {
                    var bar_w = 90;
                    var bar_h = 10;
                    var bar_x1 = rx2 - 80 - bar_w;
                    var bar_y1 = yy - (bar_h / 2);
                    draw_set_color(c_dkgray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
                    draw_set_color(is_sel ? col_gold : c_gray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_brilho), bar_y1 + bar_h, false);
                    draw_text(rx2 - 14, yy, values_aba0[idx]);
                } else if (idx < 4) {
                    draw_text(rx2 - 14, yy, values_aba0[idx]);
                }
            }
        }
        // --- CONTEÚDO DA ABA 1: CONTROLES ---
        else if (opcao_aba == 1) {
            var labels_aba1 = [
                is_pt ? "Pular" : "Jump",
                is_pt ? "Atacar (Lanca)" : "Attack (Spear)",
                is_pt ? "Esquivar (Roll)" : "Dodge (Roll)",
                is_pt ? "Usar Curativo" : "Use Bandage",
                is_pt ? "Arremessar Item" : "Throw Item",
                is_pt ? "Mover Esquerda" : "Move Left",
                is_pt ? "Mover Direita" : "Move Right",
                is_pt ? "Voltar ao Menu" : "Back to Menu"
            ];
            
            var keys_array = [global.key_jump, global.key_attack, global.key_roll, global.key_heal, global.key_throw, global.key_left, global.key_right];
            
            var row_h = 32;
            var list_y = py + 65;
            
            for (var idx = 0; idx < array_length(labels_aba1); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 28;
                var rx2 = px + pw - 28;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 14, rx2, yy + 14, false);
                    draw_set_color(aguardando_tecla ? c_orange : col_gold);
                    draw_rectangle(rx1, yy - 14, rx1 + 5, yy + 14, false);
                }
                
                draw_set_halign(fa_left);
                draw_set_color(is_sel ? c_white : col_text_off);
                draw_text(rx1 + 16, yy, labels_aba1[idx]);
                
                draw_set_halign(fa_right);
                draw_set_color(is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
                
                if (idx < 7) {
                    var txt_k = (aguardando_tecla && pause_index == idx) ? txt_espera : "[ " + nome_tecla(keys_array[idx]) + " ]";
                    draw_text(rx2 - 14, yy, txt_k);
                }
            }
        }
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text_off);
    var dica_rodape = is_pt 
        ? "[W/S] Navegar    [Q/E ou A/D] Trocar Aba    [ENTER / A] Confirmar    [ESC] Voltar" 
        : "[W/S] Navigate    [Q/E or A/D] Switch Tab    [ENTER / A] Confirm    [ESC] Back";
    draw_text(gw / 2, gh - 22, dica_rodape);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}