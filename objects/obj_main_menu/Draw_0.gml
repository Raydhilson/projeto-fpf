var _gw = view_enabled ? camera_get_view_width(view_camera[0]) : room_width;
var _gh = view_enabled ? camera_get_view_height(view_camera[0]) : room_height;
var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");

draw_set_font(fnt_menu);

var col_bg_panel   = make_color_rgb(14, 16, 22);
var col_header     = make_color_rgb(24, 28, 38);
var col_border_out = make_color_rgb(85, 75, 60);
var col_gold       = make_color_rgb(245, 195, 65);
var col_highlight  = make_color_rgb(42, 48, 66);
var col_text_off   = make_color_rgb(175, 180, 195);
var col_ok         = make_color_rgb(80, 215, 105);

var _draw_txt = function(_x, _y, _str, _col) {
    draw_set_color(c_black);
    draw_text(round(_x) + 1, round(_y) + 1, _str);
    draw_set_color(_col);
    draw_text(round(_x), round(_y), _str);
};

draw_set_color(make_color_rgb(10, 12, 16));
draw_rectangle(0, 0, _gw, _gh, false);

// ==========================================
// TELA 0: CAPA DO JOGO (MENU PRINCIPAL LATERAL)
// ==========================================
if (menu_state == 0) {
    var title_x = round(_gw * 0.07);
    var title_y = round(_gh * 0.14);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    _draw_txt(title_x, title_y, _pt ? "TNK GAMES APRESENTA" : "TNK GAMES PRESENTS", col_text_off);
    _draw_txt(title_x, title_y + 24, _pt ? "PROJETO FPF: SOBREVIVENCIA" : "PROJECT FPF: SURVIVAL", col_gold);
    
    draw_set_color(col_border_out);
    draw_line(title_x, title_y + 56, title_x + 320, title_y + 56);
    
    var menu_x = title_x;
    var menu_y = title_y + 90;
    var item_h = 42;
    
    draw_set_valign(fa_middle);
    
    for (var i = 0; i < array_length(options); i++) {
        var _option = options[i];
        var _text = "";
        
        switch (_option) {
            case "new_game":      _text = _pt ? "NOVO JOGO" : "NEW GAME"; break;
            case "continue_game": _text = _pt ? "CARREGAR SLOTS" : "LOAD SLOTS"; break;
            case "options":       _text = _pt ? "OPCOES"    : "OPTIONS";  break;
            case "quit":          _text = _pt ? "SAIR"      : "QUIT";     break;
        }
        
        var yy = menu_y + (i * item_h);
        
        if (_option == "continue_game" && !has_save) {
            _draw_txt(menu_x, yy, _text, c_dkgray);
        } else if (i == menu_index) {
            draw_set_color(col_highlight);
            draw_rectangle(menu_x - 10, yy - 16, menu_x + 240, yy + 16, false);
            draw_set_color(col_gold);
            draw_rectangle(menu_x - 10, yy - 16, menu_x - 4, yy + 16, false);
            draw_set_color(col_border_out);
            draw_rectangle(menu_x - 10, yy - 16, menu_x + 240, yy + 16, true);
            
            _draw_txt(menu_x + 14, yy, _text, c_white);
        } else {
            _draw_txt(menu_x, yy, _text, col_text_off);
        }
    }
    
    var pan_w = min(440, round(_gw * 0.44));
    var pan_h = min(320, round(_gh * 0.58));
    var pan_x = _gw - pan_w - round(_gw * 0.07);
    var pan_y = title_y + 50;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(pan_x, pan_y, pan_x + pan_w, pan_y + pan_h, false);
    draw_set_color(col_border_out);
    draw_rectangle(pan_x, pan_y, pan_x + pan_w, pan_y + pan_h, true);
    draw_set_color(col_gold);
    draw_rectangle(pan_x + 2, pan_y + 2, pan_x + pan_w - 2, pan_y + pan_h - 2, true);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    _draw_txt(pan_x + 20, pan_y + 20, _pt ? "RELATORIO DE CAMPO #04" : "FIELD REPORT #04", col_gold);
    
    var desc_lore = _pt
        ? "Laboratorio industrial Gree do Brasil, Setor Sul.\n\n" +
          "Apos o colapso estrutural, a instalacao foi tomada por mutacoes biologicas agressivas e fauna adaptada a toxinas quimicas.\n\n" +
          "Equipado apenas com uma lanca de prego improvisada, o protagonista precisa cruzar o complexo industrial, cacar recursos e sobreviver ao predador alfa da floresta."
        : "Gree do Brasil industrial lab, South Sector.\n\n" +
          "After the structural collapse, the facility was overrun by aggressive biological mutations and chemical-adapted fauna.\n\n" +
          "Armed only with an improvised nail spear, our survivor must cross the industrial complex, gather resources, and survive the alpha predator.";
          
    draw_set_color(c_black);
    draw_text_ext(pan_x + 21, pan_y + 53, desc_lore, 18, pan_w - 40);
    draw_set_color(col_text_off);
    draw_text_ext(pan_x + 20, pan_y + 52, desc_lore, 18, pan_w - 40);
}
// ==========================================
// TELA 1: SUB-MENU DE OPÇÕES
// ==========================================
else if (menu_state == 1) {
    var pw = round(_gw * 0.92);
    var ph = round(_gh * 0.86);
    var px = round((_gw - pw) / 2);
    var py = round((_gh - ph) / 2) - 6;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    var tab_w = (pw - 4) / 2;
    var tab_h = 40;
    var nomes_abas = [
        _pt ? "[Q] 1. GERAL E VIDEO" : "[Q] 1. GENERAL & VIDEO",
        _pt ? "2. CONTROLES [E]" : "2. CONTROLS [E]"
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
    
    var txt_sim     = _pt ? "LIGADO" : "ON";
    var txt_nao     = _pt ? "DESLIGADO" : "OFF";
    var txt_espera  = _pt ? "PRESSIONE TECLA..." : "PRESS ANY KEY...";
    var val_brilho  = clamp(variable_global_exists("brilho") ? global.brilho : 0.5, 0.1, 1.0);
    var _brilho_pct = string(round(val_brilho * 100)) + "%";
    
    if (opcao_aba == 0) {
        if (!variable_global_exists("res_index")) global.res_index = 0;
        var _res_nomes = ["1280 x 720 (HD)", "1600 x 900 (HD+)", "1920 x 1080 (FHD)"];
        var _res_atual = _res_nomes[clamp(global.res_index, 0, 2)];
        
        var labels_aba0 = [
            _pt ? "Idioma do Jogo" : "Game Language",
            _pt ? "Modo Tela Cheia" : "Fullscreen Mode",
            _pt ? "Resolucao da Janela" : "Window Resolution",
            _pt ? "Tremor de Tela (Shake)" : "Screen Shake",
            _pt ? "Nivel de Brilho" : "Brightness Level",
            _pt ? "Voltar ao Menu Principal" : "Back to Main Menu"
        ];
        
        var values_aba0 = [
            "< " + global.idioma + " >",
            "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
            "< " + _res_atual + " >",
            "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
            "< " + _brilho_pct + " >",
            ""
        ];
        
        var row_h = (ph - 90) / 6;
        var list_y = py + 76;
        
        for (var idx = 0; idx < array_length(labels_aba0); idx++) {
            var yy = list_y + (idx * row_h);
            var rx1 = px + 36;
            var rx2 = px + pw - 36;
            var is_sel = (menu_index == idx);
            
            if (is_sel) {
                draw_set_color(col_highlight);
                draw_rectangle(rx1, yy - 16, rx2, yy + 16, false);
                draw_set_color(col_gold);
                draw_rectangle(rx1, yy - 16, rx1 + 5, yy + 16, false);
            }
            
            draw_set_halign(fa_left);
            _draw_txt(rx1 + 18, yy, labels_aba0[idx], is_sel ? c_white : col_text_off);
            
            draw_set_halign(fa_right);
            if (idx == 4) {
                var bar_w = 110;
                var bar_h = 10;
                var bar_x1 = rx2 - 85 - bar_w;
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
    else if (opcao_aba == 1) {
        var labels_aba1 = [
            _pt ? "Pular" : "Jump",
            _pt ? "Atacar (Lanca)" : "Attack (Spear)",
            _pt ? "Esquivar (Roll)" : "Dodge (Roll)",
            _pt ? "Usar Curativo" : "Use Bandage",
            _pt ? "Arremessar Item" : "Throw Item",
            _pt ? "Mover Esquerda" : "Move Left",
            _pt ? "Mover Direita" : "Move Right",
            _pt ? "Voltar ao Menu Principal" : "Back to Main Menu"
        ];
        
        var keys_array = [global.key_jump, global.key_attack, global.key_roll, global.key_heal, global.key_throw, global.key_left, global.key_right];
        
        var row_h = (ph - 85) / 8;
        var list_y = py + 70;
        
        for (var idx = 0; idx < array_length(labels_aba1); idx++) {
            var yy = list_y + (idx * row_h);
            var rx1 = px + 36;
            var rx2 = px + pw - 36;
            var is_sel = (menu_index == idx);
            
            if (is_sel) {
                draw_set_color(col_highlight);
                draw_rectangle(rx1, yy - 13, rx2, yy + 13, false);
                draw_set_color(aguardando_tecla ? c_orange : col_gold);
                draw_rectangle(rx1, yy - 13, rx1 + 5, yy + 13, false);
            }
            
            draw_set_halign(fa_left);
            _draw_txt(rx1 + 18, yy, labels_aba1[idx], is_sel ? c_white : col_text_off);
            
            draw_set_halign(fa_right);
            if (idx < 7) {
                var txt_k = (aguardando_tecla && menu_index == idx) ? txt_espera : "[ " + nome_tecla(keys_array[idx]) + " ]";
                _draw_txt(rx2 - 14, yy, txt_k, is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
            }
        }
    }
}
// ==========================================
// TELA 2: SELEÇÃO DE 3 SLOTS DE SAVE (ESTILO SOULS / HOLLOW KNIGHT)
// ==========================================
else if (menu_state == 2) {
    var pw = round(_gw * 0.86);
    var ph = round(_gh * 0.84);
    var px = round((_gw - pw) / 2);
    var py = round((_gh - ph) / 2) - 6;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    // Cabeçalho
    draw_set_color(col_header);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + 44, false);
    draw_set_color(col_gold);
    draw_line(px + 2, py + 44, px + pw - 2, py + 44);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var titulo_slots = (modo_slot == "new")
        ? (_pt ? "ESCOLHA UM SLOT PARA NOVO JOGO" : "SELECT A SLOT FOR NEW GAME")
        : (_pt ? "ESCOLHA UM SLOT PARA CARREGAR" : "SELECT A SAVE SLOT TO LOAD");
    _draw_txt(_gw / 2, py + 24, titulo_slots, col_gold);
    
    var card_h = 74;
    var start_y = py + 62;
    
    for (var s = 0; s < 3; s++) {
        var cy1 = start_y + (s * (card_h + 12));
        var cy2 = cy1 + card_h;
        var cx1 = px + 32;
        var cx2 = px + pw - 32;
        var is_sel = (slot_index == s);
        var info   = slots_info[s];
        
        draw_set_color(is_sel ? col_highlight : col_header);
        draw_rectangle(cx1, cy1, cx2, cy2, false);
        draw_set_color(is_sel ? col_gold : col_border_out);
        draw_rectangle(cx1, cy1, cx2, cy2, true);
        if (is_sel) {
            draw_rectangle(cx1, cy1, cx1 + 6, cy2, false);
        }
        
        draw_set_halign(fa_left);
        var txt_slot_title = "SLOT 0" + string(s + 1) + "  -  " + (info.existe ? info.sala : (_pt ? "[ VAZIO ]" : "[ EMPTY ]"));
        _draw_txt(cx1 + 20, cy1 + 22, txt_slot_title, is_sel ? col_gold : c_white);
        
        if (info.existe) {
            var txt_detalhes = "HP: " + string(info.hp) + "/100   |   " + (_pt ? "Lanca Nv. " : "Spear Lv. ") + string(info.nivel) + "   |   " + (_pt ? "Sucata: x" : "Scrap: x") + string(info.sucata);
            _draw_txt(cx1 + 20, cy1 + 50, txt_detalhes, col_text_off);
            
            draw_set_halign(fa_right);
            var acao_txt = (modo_slot == "new")
                ? (_pt ? "[ENTER: SOBRESCREVER]   [X/DEL: APAGAR]" : "[ENTER: OVERWRITE]   [X/DEL: DELETE]")
                : (_pt ? "[ENTER: CONTINUAR]   [X/DEL: APAGAR]" : "[ENTER: CONTINUE]   [X/DEL: DELETE]");
            _draw_txt(cx2 - 18, cy1 + 36, acao_txt, is_sel ? col_ok : col_text_off);
        } else {
            _draw_txt(cx1 + 20, cy1 + 50, _pt ? "Nenhum progresso registrado neste slot." : "No progress recorded in this slot.", c_dkgray);
            draw_set_halign(fa_right);
            _draw_txt(cx2 - 18, cy1 + 36, _pt ? "[ENTER: INICIAR JORNADA]" : "[ENTER: START JOURNEY]", is_sel ? col_gold : col_text_off);
        }
    }
    
    // Botão Voltar (Índice 3)
    var by = start_y + (3 * (card_h + 12)) + 12;
    draw_set_halign(fa_center);
    if (slot_index == 3) {
        draw_set_color(col_highlight);
        draw_rectangle(_gw / 2 - 140, by - 16, _gw / 2 + 140, by + 16, false);
        draw_set_color(col_gold);
        draw_rectangle(_gw / 2 - 140, by - 16, _gw / 2 + 140, by + 16, true);
        _draw_txt(_gw / 2, by, _pt ? "VOLTAR AO MENU PRINCIPAL" : "BACK TO MAIN MENU", c_white);
    } else {
        _draw_txt(_gw / 2, by, _pt ? "VOLTAR AO MENU PRINCIPAL" : "BACK TO MAIN MENU", col_text_off);
    }
}

// Rodapé de Dicas
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var dica_menu = (menu_state == 2)
    ? (_pt ? "[W/S] Escolher Slot   |   [ENTER] Confirmar   |   [DEL / X] Apagar Slot   |   [ESC] Voltar" : "[W/S] Select Slot   |   [ENTER] Confirm   |   [DEL / X] Delete Slot   |   [ESC] Back")
    : (_pt ? "[W/S] Navegar   |   [Q/E] Aba   |   [A/D ou ENTER] Alterar   |   [ESC] Voltar" : "[W/S] Navigate   |   [Q/E] Tab   |   [A/D or ENTER] Change   |   [ESC] Back");
_draw_txt(_gw / 2, _gh - 16, dica_menu, col_text_off);

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