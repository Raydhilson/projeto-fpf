var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");

draw_set_font(fnt_menu);

var col_bg_panel   = make_color_rgb(18, 20, 26);
var col_header     = make_color_rgb(28, 32, 42);
var col_border_out = make_color_rgb(90, 80, 65);
var col_gold       = make_color_rgb(235, 185, 60);
var col_highlight  = make_color_rgb(45, 50, 65);
var col_text_off   = make_color_rgb(150, 155, 165);

draw_set_color(make_color_rgb(10, 12, 16));
draw_rectangle(0, 0, _gw, _gh, false);

// ==========================================
// TELA 0: CAPA DO JOGO (MENU PRINCIPAL LATERAL)
// ==========================================
if (menu_state == 0) {
    var title_x = 90;
    var title_y = 110;
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    draw_set_color(col_text_off);
    draw_text(title_x, title_y, _pt ? "TNK GAMES APRESENTA" : "TNK GAMES PRESENTS");
    
    draw_set_color(col_gold);
    draw_text(title_x, title_y + 26, _pt ? "PROJETO FPF: SOBREVIVENCIA" : "PROJECT FPF: SURVIVAL");
    
    draw_set_color(col_border_out);
    draw_line(title_x, title_y + 72, title_x + 420, title_y + 72);
    
    var menu_x = 90;
    var menu_y = title_y + 110;
    var item_h = 48;
    
    draw_set_valign(fa_middle);
    
    for (var i = 0; i < array_length(options); i++) {
        var _option = options[i];
        var _text = "";
        
        switch (_option) {
            case "new_game":      _text = _pt ? "NOVO JOGO" : "NEW GAME"; break;
            case "continue_game": _text = _pt ? "CONTINUAR" : "CONTINUE"; break;
            case "options":       _text = _pt ? "OPCOES"    : "OPTIONS";  break;
            case "quit":          _text = _pt ? "SAIR"      : "QUIT";     break;
        }
        
        var yy = menu_y + (i * item_h);
        
        if (_option == "continue_game" && !has_save) {
            draw_set_color(c_dkgray);
            draw_text(menu_x, yy, _text);
        } else if (i == menu_index) {
            draw_set_color(col_highlight);
            draw_rectangle(menu_x - 12, yy - 18, menu_x + 280, yy + 18, false);
            draw_set_color(col_gold);
            draw_rectangle(menu_x - 12, yy - 18, menu_x - 6, yy + 18, false);
            draw_set_color(col_border_out);
            draw_rectangle(menu_x - 12, yy - 18, menu_x + 280, yy + 18, true);
            
            draw_set_color(c_white);
            draw_text(menu_x + 16, yy, _text);
        } else {
            draw_set_color(col_text_off);
            draw_text(menu_x, yy, _text);
        }
    }
    
    var pan_w = 420;
    var pan_h = 320;
    var pan_x = _gw - pan_w - 90;
    var pan_y = title_y + 90;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(pan_x, pan_y, pan_x + pan_w, pan_y + pan_h, false);
    draw_set_color(col_border_out);
    draw_rectangle(pan_x, pan_y, pan_x + pan_w, pan_y + pan_h, true);
    draw_set_color(col_gold);
    draw_rectangle(pan_x + 3, pan_y + 3, pan_x + pan_w - 3, pan_y + pan_h - 3, true);
    
    draw_set_halign(fa_left);
    draw_set_color(col_gold);
    draw_text(pan_x + 24, pan_y + 36, _pt ? "RELATORIO DE CAMPO #04" : "FIELD REPORT #04");
    
    draw_set_color(c_ltgray);
    var desc_lore = _pt
        ? "Laboratorio industrial Gree do Brasil, Setor Sul.\n\n" +
          "Apos o colapso estrutural, a instalacao foi tomada por mutacoes biologicas agressivas e fauna adaptada a toxinas quimicas.\n\n" +
          "Equipado apenas com uma lanca de prego improvisada, o protagonista precisa cruzar o complexo industrial, caçar recursos e sobreviver ao predador alfa da floresta."
        : "Gree do Brasil industrial lab, South Sector.\n\n" +
          "After the structural collapse, the facility was overrun by aggressive biological mutations and chemical-adapted fauna.\n\n" +
          "Armed only with an improvised nail spear, our survivor must cross the industrial complex, gather resources, and survive the alpha predator.";
          
    draw_text_ext(pan_x + 24, pan_y + 74, desc_lore, 18, pan_w - 48);
}
// ==========================================
// TELA 1: SUB-MENU DE OPÇÕES EM ABAS SEPARADAS
// ==========================================
else if (menu_state == 1) {
    var pw = min(620, _gw * 0.90);
    var ph = min(420, _gh * 0.88);
    var px = (_gw - pw) / 2;
    var py = (_gh - ph) / 2;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
    
    // --- ABAS SUPERIORES ---
    var tab_w = (pw - 6) / 2;
    var tab_h = 44;
    var nomes_abas = [
        _pt ? "1. GERAL E VIDEO" : "1. GENERAL & VIDEO",
        _pt ? "2. CONTROLES" : "2. CONTROLS"
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
    
    var txt_sim    = _pt ? "LIGADO" : "ON";
    var txt_nao    = _pt ? "DESLIGADO" : "OFF";
    var txt_espera = _pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
    var val_brilho = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
    var _brilho_pct = string(round(val_brilho * 100)) + "%";
    
    // --- ABA 0: GERAL E VÍDEO ---
    if (opcao_aba == 0) {
        var labels_aba0 = [
            _pt ? "Idioma do Jogo" : "Game Language",
            _pt ? "Modo Tela Cheia" : "Fullscreen Mode",
            _pt ? "Tremor de Tela (Shake)" : "Screen Shake",
            _pt ? "Nivel de Brilho" : "Brightness Level",
            _pt ? "Voltar ao Menu" : "Back to Menu"
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
            var is_sel = (menu_index == idx);
            
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
    // --- ABA 1: CONTROLES ---
    else if (opcao_aba == 1) {
        var labels_aba1 = [
            _pt ? "Pular" : "Jump",
            _pt ? "Atacar (Lanca)" : "Attack (Spear)",
            _pt ? "Esquivar (Roll)" : "Dodge (Roll)",
            _pt ? "Usar Curativo" : "Use Bandage",
            _pt ? "Arremessar Item" : "Throw Item",
            _pt ? "Mover Esquerda" : "Move Left",
            _pt ? "Mover Direita" : "Move Right",
            _pt ? "Voltar ao Menu" : "Back to Menu"
        ];
        
        var keys_array = [global.key_jump, global.key_attack, global.key_roll, global.key_heal, global.key_throw, global.key_left, global.key_right];
        
        var row_h = 32;
        var list_y = py + 65;
        
        for (var idx = 0; idx < array_length(labels_aba1); idx++) {
            var yy = list_y + (idx * row_h);
            var rx1 = px + 28;
            var rx2 = px + pw - 28;
            var is_sel = (menu_index == idx);
            
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
                var txt_k = (aguardando_tecla && menu_index == idx) ? txt_espera : "[ " + nome_tecla(keys_array[idx]) + " ]";
                draw_text(rx2 - 14, yy, txt_k);
            }
        }
    }
}

// Rodapé de Dicas
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(col_text_off);
var dica_menu = _pt 
    ? "[W/S] Navegar    [Q/E] Trocar Aba    [ENTER / A] Confirmar    [ESC] Voltar" 
    : "[W/S] Navigate    [Q/E] Switch Tab    [ENTER / A] Confirm    [ESC] Back";
draw_text(_gw / 2, _gh - 18, dica_menu);

// Brilho Global
if (variable_global_exists("brilho")) {
    if (global.brilho < 0.5) {
        draw_set_color(c_black);
        draw_set_alpha((0.5 - global.brilho) * 1.4);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1.0);
    } else if (global.brilho > 0.5) {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha((global.brilho - 0.5) * 0.6);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1.0);
        gpu_set_blendmode(bm_normal);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);