// Garante que a GUI rode sempre na escala proporcional 800x450
if (display_get_gui_width() != 800) {
    display_set_gui_size(800, 450);
}

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
// 2. MENU DE PAUSA EM TELA INTEIRA (800x450 NÍTIDO)
// ==========================================
if (is_paused) {
    draw_set_font(fnt_menu);
    var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    
    var col_bg_panel   = make_color_rgb(14, 16, 22);
    var col_header     = make_color_rgb(24, 28, 38);
    var col_border_out = make_color_rgb(85, 75, 60);
    var col_gold       = make_color_rgb(245, 195, 65);
    var col_highlight  = make_color_rgb(42, 48, 66);
    var col_text_off   = make_color_rgb(175, 180, 195);
    
    var _draw_txt = function(_x, _y, _str, _col) {
        draw_set_color(c_black);
        draw_text(round(_x) + 1, round(_y) + 1, _str);
        draw_set_color(_col);
        draw_text(round(_x), round(_y), _str);
    };
    
    // Fundo escuro cobrindo 100% da tela
    draw_set_color(c_black);
    draw_set_alpha(0.90);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = round(gw * 0.92);
    var ph = round(gh * 0.86);
    var px = round((gw - pw) / 2);
    var py = round((gh - ph) / 2) - 6;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    // ----------------------------------------------------
    // TELA 0: PAUSA PRINCIPAL
    // ----------------------------------------------------
    if (pause_state == 0) {
        draw_set_color(col_header);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + 44, false);
        draw_set_color(col_gold);
        draw_line(px + 2, py + 44, px + pw - 2, py + 44);
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        _draw_txt(gw / 2, py + 24, is_pt ? "JOGO EM PAUSA" : "GAME PAUSED", col_gold);
        
        pause_opcoes[0] = is_pt ? "CONTINUAR JOGO" : "RESUME GAME";
        pause_opcoes[1] = is_pt ? "OPCOES E CONTROLES" : "OPTIONS & CONTROLS";
        pause_opcoes[2] = is_pt ? "SALVAR E SAIR PARA O MENU" : "SAVE & QUIT TO MENU";
        
        var start_y = py + round(ph * 0.36);
        var row_h   = 56;
        var btn_w   = min(380, round(pw * 0.60));
        var bx1     = round((gw - btn_w) / 2);
        var bx2     = bx1 + btn_w;
        
        for (var i = 0; i < array_length(pause_opcoes); i++) {
            var yy = start_y + (i * row_h);
            
            if (pause_index == i) {
                draw_set_color(col_highlight);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, false);
                draw_set_color(col_gold);
                draw_rectangle(bx1, yy - 18, bx1 + 6, yy + 18, false);
                draw_set_color(col_border_out);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, true);
                
                _draw_txt(gw / 2, yy, pause_opcoes[i], c_white);
            } else {
                draw_set_color(col_header);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, false);
                draw_set_color(col_border_out);
                draw_rectangle(bx1, yy - 18, bx2, yy + 18, true);
                _draw_txt(gw / 2, yy, pause_opcoes[i], col_text_off);
            }
        }
    }
    // ----------------------------------------------------
    // TELA 1: OPÇÕES E CONTROLES EM ABAS SEPARADAS
    // ----------------------------------------------------
    else if (pause_state == 1) {
        if (!variable_instance_exists(id, "opcao_aba")) opcao_aba = 0;
        
        var tab_w = (pw - 4) / 2;
        var tab_h = 38;
        var nomes_abas = [
            is_pt ? "[Q] 1. GERAL E VIDEO" : "[Q] 1. GENERAL & VIDEO",
            is_pt ? "2. CONTROLES [E]" : "2. CONTROLS [E]"
        ];
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        for (var t = 0; t < 2; t++) {
            var tx1 = px + 2 + (t * tab_w);
            var tx2 = tx1 + tab_w;
            var ty1 = py + 2;
            var ty2 = ty1 + tab_h;
            
            if (opcao_aba == t) {
                draw_set_color(col_highlight);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_gold);
                draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
                _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t], c_white);
            } else {
                draw_set_color(col_header);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_border_out);
                draw_rectangle(tx1, ty1, tx2, ty2, true);
                _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nomes_abas[t], col_text_off);
            }
        }
        
        var txt_sim     = is_pt ? "LIGADO" : "ON";
        var txt_nao     = is_pt ? "DESLIGADO" : "OFF";
        var txt_espera  = is_pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
        var val_brilho  = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
        var _brilho_pct = string(round(val_brilho * 100)) + "%";
        
        // --- CONTEÚDO DA ABA 0: GERAL E VÍDEO (COM RESOLUÇÃO) ---
        if (opcao_aba == 0) {
            if (!variable_global_exists("res_index")) global.res_index = 0;
            var _res_nomes = ["1280 x 720 (HD)", "1600 x 900 (HD+)", "1920 x 1080 (FHD)"];
            var _res_atual = _res_nomes[clamp(global.res_index, 0, 2)];
            
            var labels_aba0 = [
                is_pt ? "Idioma do Jogo" : "Game Language",
                is_pt ? "Modo Tela Cheia" : "Fullscreen Mode",
                is_pt ? "Resolucao da Janela" : "Window Resolution",
                is_pt ? "Tremor de Tela (Shake)" : "Screen Shake",
                is_pt ? "Nivel de Brilho" : "Brightness Level",
                is_pt ? "Voltar ao Menu de Pausa" : "Back to Pause Menu"
            ];
            
            var values_aba0 = [
                "< " + global.idioma + " >",
                "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
                "< " + _res_atual + " >",
                "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
                "< " + _brilho_pct + " >",
                ""
            ];
            
            var row_h = (ph - 85) / 6;
            var list_y = py + 72;
            
            for (var idx = 0; idx < array_length(labels_aba0); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 32;
                var rx2 = px + pw - 32;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 15, rx2, yy + 15, false);
                    draw_set_color(col_gold);
                    draw_rectangle(rx1, yy - 15, rx1 + 5, yy + 15, false);
                }
                
                draw_set_halign(fa_left);
                _draw_txt(rx1 + 16, yy, labels_aba0[idx], is_sel ? c_white : col_text_off);
                
                draw_set_halign(fa_right);
                if (idx == 4) {
                    var bar_w = 100;
                    var bar_h = 10;
                    var bar_x1 = rx2 - 80 - bar_w;
                    var bar_y1 = yy - (bar_h / 2);
                    draw_set_color(c_dkgray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
                    draw_set_color(is_sel ? col_gold : c_gray);
                    draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_brilho), bar_y1 + bar_h, false);
                    _draw_txt(rx2 - 14, yy, values_aba0[idx], is_sel ? col_gold : c_ltgray);
                } else if (idx < 5) {
                    _draw_txt(rx2 - 14, yy, values_aba0[idx], is_sel ? col_gold : c_ltgray);
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
                is_pt ? "Voltar ao Menu de Pausa" : "Back to Pause Menu"
            ];
            
            var keys_array = [global.key_jump, global.key_attack, global.key_roll, global.key_heal, global.key_throw, global.key_left, global.key_right];
            
            var row_h = (ph - 80) / 8;
            var list_y = py + 66;
            
            for (var idx = 0; idx < array_length(labels_aba1); idx++) {
                var yy = list_y + (idx * row_h);
                var rx1 = px + 32;
                var rx2 = px + pw - 32;
                var is_sel = (pause_index == idx);
                
                if (is_sel) {
                    draw_set_color(col_highlight);
                    draw_rectangle(rx1, yy - 13, rx2, yy + 13, false);
                    draw_set_color(aguardando_tecla ? c_orange : col_gold);
                    draw_rectangle(rx1, yy - 13, rx1 + 5, yy + 13, false);
                }
                
                draw_set_halign(fa_left);
                _draw_txt(rx1 + 16, yy, labels_aba1[idx], is_sel ? c_white : col_text_off);
                
                draw_set_halign(fa_right);
                if (idx < 7) {
                    var txt_k = (aguardando_tecla && pause_index == idx) ? txt_espera : "[ " + nome_tecla(keys_array[idx]) + " ]";
                    _draw_txt(rx2 - 14, yy, txt_k, is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
                }
            }
        }
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var dica_rodape = is_pt 
        ? "[W/S] Navegar   |   [Q/E] Aba   |   [A/D ou ENTER] Alterar   |   [ESC] Voltar" 
        : "[W/S] Navigate   |   [Q/E] Tab   |   [A/D or ENTER] Change   |   [ESC] Back";
    _draw_txt(gw / 2, gh - 15, dica_rodape, col_text_off);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}