var gw = display_get_gui_width();
var gh = display_get_gui_height();

// ==========================================
// 1. EFEITO GLOBAL DE BRILHO NA TELA (Roda sempre)
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
// 2. MENU DE PAUSA ESTILIZADO (UI EM PAINÉIS E ABAS)
// ==========================================
if (is_paused) {
    draw_set_font(fnt_menu);
    var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    
    // Paleta de Cores Dark Fantasy / Indie UI
    var col_bg_panel   = make_color_rgb(18, 20, 26);
    var col_header     = make_color_rgb(28, 32, 42);
    var col_border_out = make_color_rgb(90, 80, 65);
    var col_gold       = make_color_rgb(235, 185, 60);
    var col_highlight  = make_color_rgb(45, 50, 65);
    var col_text_off   = make_color_rgb(150, 155, 165);
    
    // Fundo escuro translúcido sobre o jogo
    draw_set_color(c_black);
    draw_set_alpha(0.80);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    // ----------------------------------------------------
    // TELA 0: PAUSA PRINCIPAL (CAIXA CENTRAL COMPACTA)
    // ----------------------------------------------------
    if (pause_state == 0) {
        var pw = min(380, gw * 0.80);
        var ph = min(240, gh * 0.70);
        var px = (gw - pw) / 2;
        var py = (gh - ph) / 2;
        
        // Sombra e Corpo do Painel
        draw_set_color(c_black);
        draw_set_alpha(0.6);
        draw_rectangle(px + 6, py + 6, px + pw + 6, py + ph + 6, false);
        draw_set_alpha(1.0);
        
        draw_set_color(col_bg_panel);
        draw_rectangle(px, py, px + pw, py + ph, false);
        
        // Faixa do Cabeçalho
        draw_set_color(col_header);
        draw_rectangle(px, py, px + pw, py + 44, false);
        
        // Bordas Duplas Elegantes
        draw_set_color(col_border_out);
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_color(col_gold);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
        draw_line(px + 3, py + 44, px + pw - 3, py + 44);
        
        // Título
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(col_gold);
        draw_text(gw / 2, py + 22, is_pt ? "JOGO EM PAUSA" : "GAME PAUSED");
        
        // Botões da Pausa
        pause_opcoes[0] = is_pt ? "CONTINUAR" : "RESUME";
        pause_opcoes[1] = is_pt ? "OPCOES E CONTROLES" : "OPTIONS & CONTROLS";
        pause_opcoes[2] = is_pt ? "SALVAR E SAIR" : "SAVE & QUIT";
        
        var start_y = py + 85;
        var row_h   = 44;
        
        for (var i = 0; i < array_length(pause_opcoes); i++) {
            var yy = start_y + (i * row_h);
            var bx1 = px + 24;
            var bx2 = px + pw - 24;
            
            if (pause_index == i) {
                draw_set_color(col_highlight);
                draw_rectangle(bx1, yy - 16, bx2, yy + 16, false);
                
                draw_set_color(col_gold);
                draw_rectangle(bx1, yy - 16, bx1 + 5, yy + 16, false);
                draw_rectangle(bx1, yy - 16, bx2, yy + 16, true);
                
                draw_set_color(c_white);
                draw_text(gw / 2, yy, pause_opcoes[i]);
            } else {
                draw_set_color(col_text_off);
                draw_text(gw / 2, yy, pause_opcoes[i]);
            }
        }
    }
    
    // ----------------------------------------------------
    // TELA 1: OPÇÕES DIVIDIDAS POR ABAS (VÍDEO vs CONTROLES)
    // ----------------------------------------------------
    else if (pause_state == 1) {
        var pw = min(540, gw * 0.90);
        var ph = min(340, gh * 0.86);
        var px = (gw - pw) / 2;
        var py = (gh - ph) / 2;
        
        // Sombra e Corpo do Painel
        draw_set_color(c_black);
        draw_set_alpha(0.6);
        draw_rectangle(px + 6, py + 6, px + pw + 6, py + ph + 6, false);
        draw_set_alpha(1.0);
        
        draw_set_color(col_bg_panel);
        draw_rectangle(px, py, px + pw, py + ph, false);
        draw_set_color(col_border_out);
        draw_rectangle(px, py, px + pw, py + ph, true);
        draw_set_color(col_gold);
        draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
        
        // Índices 0 a 4 = Aba 0 (Geral & Vídeo) | Índices 5 a 11 = Aba 1 (Controles)
        var aba_ativa = (pause_index >= 5 && pause_index <= 11) ? 1 : 0;
        
        // --- CABEÇALHO DE ABAS ---
        var tab_w = (pw - 6) / 2;
        var tab_h = 38;
        var nomes_abas = [
            is_pt ? "1. GERAL E VIDEO" : "1. GENERAL & VIDEO",
            is_pt ? "2. CONTROLES (TECLAS)" : "2. CONTROLS (KEYS)"
        ];
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        for (var t = 0; t < 2; t++) {
            var tx1 = px + 3 + (t * tab_w);
            var tx2 = tx1 + tab_w;
            var ty1 = py + 3;
            var ty2 = ty1 + tab_h;
            
            if (aba_ativa == t) {
                draw_set_color(col_highlight);
                draw_rectangle(tx1, ty1, tx2, ty2, false);
                draw_set_color(col_gold);
                draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
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
        var _res_atual  = global.resolucoes[global.res_index].label;
        
        var labels = [
            is_pt ? "Idioma do Jogo" : "Game Language",
            is_pt ? "Modo Tela Cheia" : "Fullscreen Mode",
            is_pt ? "Resolucao da Tela" : "Screen Resolution",
            is_pt ? "Tremor de Tela (Shake)" : "Screen Shake",
            is_pt ? "Nivel de Brilho" : "Brightness Level",
            is_pt ? "Pular" : "Jump",
            is_pt ? "Atacar (Lanca)" : "Attack (Spear)",
            is_pt ? "Esquivar (Roll)" : "Dodge (Roll)",
            is_pt ? "Usar Curativo" : "Use Bandage",
            is_pt ? "Arremessar Item" : "Throw Item",
            is_pt ? "Mover para Esquerda" : "Move Left",
            is_pt ? "Mover para Direita" : "Move Right"
        ];
        
        var values = [
            "< " + global.idioma + " >",
            "< " + (window_get_fullscreen() ? txt_sim : txt_nao) + " >",
            "< " + _res_atual + " >",
            "< " + (global.tremer_tela ? txt_sim : txt_nao) + " >",
            "< " + _brilho_pct + " >",
            (aguardando_tecla && pause_index == 5)  ? txt_espera : "[ " + nome_tecla(global.key_jump) + " ]",
            (aguardando_tecla && pause_index == 6)  ? txt_espera : "[ " + nome_tecla(global.key_attack) + " ]",
            (aguardando_tecla && pause_index == 7)  ? txt_espera : "[ " + nome_tecla(global.key_roll) + " ]",
            (aguardando_tecla && pause_index == 8)  ? txt_espera : "[ " + nome_tecla(global.key_heal) + " ]",
            (aguardando_tecla && pause_index == 9)  ? txt_espera : "[ " + nome_tecla(global.key_throw) + " ]",
            (aguardando_tecla && pause_index == 10) ? txt_espera : "[ " + nome_tecla(global.key_left) + " ]",
            (aguardando_tecla && pause_index == 11) ? txt_espera : "[ " + nome_tecla(global.key_right) + " ]"
        ];
        
        // Define quais índices desenhar na aba atual
        var idx_ini = (aba_ativa == 0) ? 0 : 5;
        var idx_fim = (aba_ativa == 0) ? 4 : 11;
        var row_h   = (aba_ativa == 0) ? 32 : 26;
        var list_y  = py + 64;
        
        for (var idx = idx_ini; idx <= idx_fim; idx++) {
            var line_num = idx - idx_ini;
            var yy  = list_y + (line_num * row_h);
            var rx1 = px + 22;
            var rx2 = px + pw - 22;
            var is_sel = (pause_index == idx);
            
            if (is_sel) {
                draw_set_color(col_highlight);
                draw_rectangle(rx1, yy - (row_h * 0.42), rx2, yy + (row_h * 0.42), false);
                draw_set_color(aguardando_tecla ? c_orange : col_gold);
                draw_rectangle(rx1, yy - (row_h * 0.42), rx1 + 4, yy + (row_h * 0.42), false);
            }
            
            // Coluna da Esquerda: Nome da Configuração
            draw_set_halign(fa_left);
            draw_set_color(is_sel ? c_white : col_text_off);
            draw_text(rx1 + 14, yy, labels[idx]);
            
            // Coluna da Direita: Valor ou Barra de Brilho
            draw_set_halign(fa_right);
            draw_set_color(is_sel ? (aguardando_tecla ? c_orange : col_gold) : c_ltgray);
            
            if (idx == 4) {
                var bar_w = 80;
                var bar_h = 8;
                var bar_x1 = rx2 - 75 - bar_w;
                var bar_y1 = yy - (bar_h / 2);
                draw_set_color(c_dkgray);
                draw_rectangle(bar_x1, bar_y1, bar_x1 + bar_w, bar_y1 + bar_h, false);
                draw_set_color(is_sel ? col_gold : c_gray);
                draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_w * val_brilho), bar_y1 + bar_h, false);
                draw_text(rx2 - 12, yy, values[idx]);
            } else {
                draw_text(rx2 - 12, yy, values[idx]);
            }
        }
        
        // --- LINHA DIVISÓRIA E BOTÕES DE AÇÃO NA BASE (12 e 13) ---
        var div_y = py + ph - 52;
        draw_set_color(col_border_out);
        draw_line(px + 16, div_y, px + pw - 16, div_y);
        
        var btn_y = py + ph - 26;
        var b1_x  = px + (pw * 0.28);
        var b2_x  = px + (pw * 0.74);
        
        draw_set_halign(fa_center);
        
        // Botão 12: Restaurar Padrões
        var txt_reset = is_pt ? "RESTAURAR PADROES" : "RESET DEFAULTS";
        if (pause_index == 12) {
            draw_set_color(col_highlight);
            draw_rectangle(b1_x - 110, btn_y - 14, b1_x + 110, btn_y + 14, false);
            draw_set_color(col_gold);
            draw_rectangle(b1_x - 110, btn_y - 14, b1_x + 110, btn_y + 14, true);
            draw_text(b1_x, btn_y, txt_reset);
        } else {
            draw_set_color(col_text_off);
            draw_text(b1_x, btn_y, txt_reset);
        }
        
        // Botão 13: Voltar e Salvar
        var txt_back = is_pt ? "VOLTAR E SALVAR" : "BACK & SAVE";
        if (pause_index == 13) {
            draw_set_color(col_highlight);
            draw_rectangle(b2_x - 100, btn_y - 14, b2_x + 100, btn_y + 14, false);
            draw_set_color(col_gold);
            draw_rectangle(b2_x - 100, btn_y - 14, b2_x + 100, btn_y + 14, true);
            draw_text(b2_x, btn_y, txt_back);
        } else {
            draw_set_color(col_text_off);
            draw_text(b2_x, btn_y, txt_back);
        }
    }
    
    // ----------------------------------------------------
    // RODAPÉ FIXO DE COMANDOS (UX DE CONSOLE / STEAM)
    // ----------------------------------------------------
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text_off);
    var dica_rodape = is_pt 
        ? "[W/S] Navegar    [ENTER / A] Confirmar    [A/D] Ajustar    [ESC / B] Voltar" 
        : "[W/S] Navigate    [ENTER / A] Confirm    [A/D] Adjust    [ESC / B] Back";
    draw_text(gw / 2, gh - 18, dica_rodape);
    
    // Restaura padrões de desenho
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}