// Escala 800x450 (16:9): deixa a fonte encorpada, nítida e proporcional aos painéis
if (display_get_gui_width() != 800) {
    display_set_gui_size(800, 450);
}

// Não desenha HUD nem Inventário se o Pause Global (ESC) estiver aberto[cite: 4, 6]
if (instance_exists(obj_game_controller) && obj_game_controller.is_paused) {
    exit;
}

var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

// Paleta com maior contraste para leitura
var col_bg_panel   = make_color_rgb(14, 16, 22);
var col_header     = make_color_rgb(24, 28, 38);
var col_card       = make_color_rgb(22, 26, 34);
var col_border_out = make_color_rgb(85, 75, 60);
var col_gold       = make_color_rgb(245, 195, 65);
var col_highlight  = make_color_rgb(42, 48, 66);
var col_text_sub   = make_color_rgb(185, 190, 205); // Cinza claro bem legível
var col_hp         = make_color_rgb(220, 50, 60);
var col_ok         = make_color_rgb(80, 215, 105);
var col_scrap      = make_color_rgb(225, 140, 55);

// Função auxiliar para desenhar texto com sombra nítida (Drop Shadow)
var _draw_txt = function(_x, _y, _str, _col) {
    draw_set_color(c_black);
    draw_text(round(_x) + 1, round(_y) + 1, _str);
    draw_set_color(_col);
    draw_text(round(_x), round(_y), _str);
};

var _nome_k = function(_k) {
    if (_k == vk_space) return "SPACE";
    if (_k == vk_shift) return "SHIFT";
    if (_k == vk_control) return "CTRL";
    if (_k == vk_enter) return "ENTER";
    if (_k == vk_left) return "LEFT";
    if (_k == vk_right) return "RIGHT";
    if (_k == vk_up) return "UP";
    if (_k == vk_down) return "DOWN";
    if (_k >= 48 && _k <= 90) return chr(_k);
    return "KEY";
};

var str_key_heal  = _nome_k(global.key_heal);
var str_key_throw = _nome_k(global.key_throw);

draw_set_font(fnt_menu);

// =======================================================
// --- 1. HUD DE SOBREVIVÊNCIA (Canto Superior Esquerdo) ---
// =======================================================
if (state != player_state.menu && state != player_state.craft) {
    var gui_x = 18;
    var gui_y = 18;
    var hud_w = 185;
    var hud_h = (buff_fogo_timer > 0) ? 68 : 50;

    draw_set_color(c_black);
    draw_set_alpha(0.75);
    draw_rectangle(gui_x - 6, gui_y - 6, gui_x + hud_w, gui_y + hud_h, false);
    draw_set_alpha(1.0);

    draw_set_color(col_border_out);
    draw_rectangle(gui_x - 6, gui_y - 6, gui_x + hud_w, gui_y + hud_h, true);

    var bar_width  = 170;
    var bar_height = 14;
    var hp_pct     = clamp(hp / hp_max, 0, 1);

    draw_set_color(make_color_rgb(35, 15, 20));
    draw_rectangle(gui_x, gui_y, gui_x + bar_width, gui_y + bar_height, false);
    draw_set_color(col_hp);
    draw_rectangle(gui_x, gui_y, gui_x + (bar_width * hp_pct), gui_y + bar_height, false);
    draw_set_color(col_gold);
    draw_rectangle(gui_x, gui_y, gui_x + bar_width, gui_y + bar_height, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    _draw_txt(gui_x + (bar_width / 2), gui_y + (bar_height / 2), string(hp) + " / " + string(hp_max), c_white);

    var info_y = gui_y + 28;
    draw_set_halign(fa_left);

    draw_set_color(col_scrap);
    draw_circle(gui_x + 5, info_y, 4, false);
    _draw_txt(gui_x + 13, info_y, "x" + string(global.scrap), c_white);

    _draw_txt(gui_x + 56, info_y, "[" + str_key_heal + "] " + string(curativo_count) + "  [" + str_key_throw + "] " + string(faca_count + molotov_count), col_text_sub);

    if (buff_fogo_timer > 0) {
        var seg_restantes = ceil(buff_fogo_timer / 60);
        var txt_buff = is_pt ? "LANCA EM CHAMAS: " : "FLAMING SPEAR: ";
        _draw_txt(gui_x, info_y + 18, txt_buff + string(seg_restantes) + "s", c_orange);
    }
}

// =======================================================
// --- 2. TELA DEDICADA DO HUB (TIPOGRAFIA REFINADA) ---
// =======================================================
if (state == player_state.menu || state == player_state.craft) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    draw_set_color(c_black);
    draw_set_alpha(0.90);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = round(gw * 0.92);
    var ph = round(gh * 0.88);
    var px = round((gw - pw) / 2);
    var py = round((gh - ph) / 2);
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    // --- ABAS SUPERIORES ---
    var tab_w = (pw - 4) / 3;
    var tab_h = 36;
    var nome_abas = is_pt 
        ? ["[Q] INVENTARIO", "CRAFTING", "MAESTRIA [E]"] 
        : ["[Q] INVENTORY", "CRAFTING", "MASTERY [E]"];
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    for (var i = 0; i < 3; i++) {
        var tx1 = px + 2 + (i * tab_w);
        var tx2 = tx1 + tab_w;
        var ty1 = py + 2;
        var ty2 = ty1 + tab_h;
        
        if (aba_atual == i) {
            draw_set_color(col_highlight);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_gold);
            draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
            _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i], c_white);
        } else {
            draw_set_color(col_header);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_border_out);
            draw_rectangle(tx1, ty1, tx2, ty2, true);
            _draw_txt((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i], col_text_sub);
        }
    }
    
    var cx1 = px + 24;
    var cy1 = py + 52;
    var cw  = pw - 48;
    
    // ---------------------------------------------------
    // ABA 0: INVENTÁRIO (DIVIDIDO EM 2 COLUNAS LIMPAS)
    // ---------------------------------------------------
    if (aba_atual == 0) {
        var col_w = (cw - 16) / 2;
        var c2_x  = cx1 + col_w + 16;
        
        // Títulos das Colunas
        draw_set_halign(fa_left);
        _draw_txt(cx1 + 4, cy1 + 8, is_pt ? "EQUIPAMENTOS TATICOS" : "TACTICAL GEAR", col_gold);
        _draw_txt(c2_x + 4, cy1 + 8, is_pt ? "MATERIAIS DE COLETA" : "CRAFTING MATERIALS", col_gold);
        
        // Coluna 1: Consumíveis
        var gear_names = is_pt ? ["Curativos Medicos", "Coqueteis Molotov", "Facas de Arremesso"] : ["Medical Bandages", "Molotov Cocktails", "Throwing Knives"];
        var gear_desc  = is_pt ? ["Cura +30 HP", "Dano de fogo em area", "Dano fisico rapido"] : ["Heals +30 HP", "Area fire damage", "Fast physical damage"];
        var gear_qtd   = [curativo_count, molotov_count, faca_count];
        
        for (var k = 0; k < 3; k++) {
            var iy = cy1 + 28 + (k * 68);
            draw_set_color(col_card);
            draw_rectangle(cx1, iy, cx1 + col_w, iy + 58, false);
            draw_set_color(col_border_out);
            draw_rectangle(cx1, iy, cx1 + col_w, iy + 58, true);
            
            draw_set_halign(fa_left);
            _draw_txt(cx1 + 14, iy + 18, gear_names[k], c_white);
            _draw_txt(cx1 + 14, iy + 40, gear_desc[k], col_text_sub);
            
            draw_set_halign(fa_right);
            _draw_txt(cx1 + col_w - 14, iy + 28, "x" + string(gear_qtd[k]), (gear_qtd[k] > 0) ? col_gold : col_hp);
        }
        
        // Coluna 2: Materiais
        var mat_names = is_pt ? ["Sucata Industrial", "Carne de Besouro", "Glandula Volatil", "Ferrao de Vespa"] : ["Industrial Scrap", "Beetle Meat", "Volatile Gland", "Wasp Stinger"];
        var mat_qtd   = [global.scrap, carne_count, glandula_count, ferrao_count];
        
        for (var m = 0; m < 4; m++) {
            var my = cy1 + 28 + (m * 50);
            draw_set_color(col_card);
            draw_rectangle(c2_x, my, c2_x + col_w, my + 42, false);
            draw_set_color(col_border_out);
            draw_rectangle(c2_x, my, c2_x + col_w, my + 42, true);
            
            draw_set_halign(fa_left);
            _draw_txt(c2_x + 14, my + 21, mat_names[m], c_white);
            
            draw_set_halign(fa_right);
            _draw_txt(c2_x + col_w - 14, my + 21, "x" + string(mat_qtd[m]), (mat_qtd[m] > 0) ? col_ok : col_text_sub);
        }
    }
    // ---------------------------------------------------
    // ABA 1: CRAFTING (CARDS ESPAÇADOS E LEGÍVEIS)
    // ---------------------------------------------------
    else if (aba_atual == 1) {
        draw_set_color(col_header);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 32, false);
        draw_set_color(col_border_out);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 32, true);
        
        var txt_recursos = is_pt
            ? "Sucata: " + string(global.scrap) + "   |   Carne: " + string(carne_count) + "   |   Glandula: " + string(glandula_count) + "   |   Ferrao: " + string(ferrao_count)
            : "Scrap: " + string(global.scrap) + "   |   Meat: " + string(carne_count) + "   |   Gland: " + string(glandula_count) + "   |   Stinger: " + string(ferrao_count);
            
        draw_set_halign(fa_center);
        _draw_txt(gw / 2, cy1 + 16, txt_recursos, col_gold);
        
        var desc_receitas = is_pt
            ? ["Restaura +30 de HP (Tecla " + str_key_heal + ")", "Cria poca de fogo continua no chao", "Projetil rapido de dano perfurante"]
            : ["Restores +30 HP (Key " + str_key_heal + ")", "Creates fire pool on impact", "Fast piercing projectile"];
            
        var nome_org = is_pt ? ["1 Carne", "1 Glandula", "1 Ferrao"] : ["1 Meat", "1 Gland", "1 Stinger"];
        var qtd_org_atual = [carne_count, glandula_count, ferrao_count];
        var qtd_item_inv  = [curativo_count, molotov_count, faca_count];
        
        var card_h = 66;
        var start_cy = cy1 + 44;
        
        for (var j = 0; j < array_length(craft_recipes); j++) {
            var ry1 = start_cy + (j * (card_h + 10));
            var ry2 = ry1 + card_h;
            var is_sel = (menu_index == j);
            
            var custo_suc = craft_cost_array[j];
            var pode_craftar = (global.scrap >= custo_suc && qtd_org_atual[j] >= 1);
            
            draw_set_color(is_sel ? col_highlight : col_card);
            draw_rectangle(cx1, ry1, cx1 + cw, ry2, false);
            
            draw_set_color(is_sel ? col_gold : col_border_out);
            draw_rectangle(cx1, ry1, cx1 + cw, ry2, true);
            if (is_sel) {
                draw_rectangle(cx1, ry1, cx1 + 6, ry2, false);
            }
            
            if (state == player_state.craft && craft_selected_item == j) {
                var pct_c = clamp(craft_timer / craft_time_max, 0, 1);
                draw_set_color(col_gold);
                draw_set_alpha(0.30);
                draw_rectangle(cx1, ry1, cx1 + (cw * pct_c), ry2, false);
                draw_set_alpha(1.0);
            }
            
            draw_set_halign(fa_left);
            _draw_txt(cx1 + 18, ry1 + 20, craft_recipes[j] + "  (Estoque: " + string(qtd_item_inv[j]) + ")", is_sel ? col_gold : c_white);
            _draw_txt(cx1 + 18, ry1 + 45, desc_receitas[j], col_text_sub);
            
            draw_set_halign(fa_right);
            var str_custo = string(custo_suc) + (is_pt ? " Sucatas + " : " Scrap + ") + nome_org[j];
            _draw_txt(cx1 + cw - 16, ry1 + 20, str_custo, pode_craftar ? col_ok : col_hp);
            
            var str_status = (state == player_state.craft && craft_selected_item == j)
                ? (is_pt ? "[ FABRICANDO... ]" : "[ CRAFTING... ]")
                : (pode_craftar ? (is_pt ? "[ ENTER: FABRICAR ]" : "[ ENTER: CRAFT ]") : (is_pt ? "[ FALTA MATERIAL ]" : "[ MISSING MATS ]"));
            _draw_txt(cx1 + cw - 16, ry1 + 45, str_status, pode_craftar ? c_white : col_text_sub);
        }
    }
    // ---------------------------------------------------
    // ABA 2: MAESTRIA DE COMBATE (COM BARRA DE XP VISUAL)
    // ---------------------------------------------------
    else if (aba_atual == 2) {
        // Card Principal da Arma + Barra de XP
        draw_set_color(col_header);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 68, false);
        draw_set_color(col_gold);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 68, true);
        
        draw_set_halign(fa_left);
        _draw_txt(cx1 + 18, cy1 + 20, is_pt ? "ARMA: LANCA DE PREGO IMPROVISADA" : "WEAPON: IMPROVISED NAIL SPEAR", col_gold);
        
        draw_set_halign(fa_right);
        _draw_txt(cx1 + cw - 18, cy1 + 20, "NIVEL " + string(arma_nivel), c_white);
        
        // Barra de Progresso de XP
        var xp_x1 = cx1 + 18;
        var xp_x2 = cx1 + cw - 18;
        var xp_y1 = cy1 + 40;
        var xp_pct = clamp(arma_xp / max(1, arma_xp_max), 0, 1);
        
        draw_set_color(c_black);
        draw_rectangle(xp_x1, xp_y1, xp_x2, xp_y1 + 16, false);
        draw_set_color(col_gold);
        draw_rectangle(xp_x1, xp_y1, xp_x1 + ((xp_x2 - xp_x1) * xp_pct), xp_y1 + 16, false);
        draw_set_color(col_border_out);
        draw_rectangle(xp_x1, xp_y1, xp_x2, xp_y1 + 16, true);
        
        draw_set_halign(fa_center);
        _draw_txt((xp_x1 + xp_x2) / 2, xp_y1 + 8, "XP: " + string(arma_xp) + " / " + string(arma_xp_max), c_white);
        
        // Lista de Atributos abaixo da barra
        var stats_labels = is_pt
            ? ["Dano Base do Golpe", "Chance de Acerto Critico", "Multiplicador de Critico", "Habilidade de Combo (2o Golpe)"]
            : ["Base Strike Damage", "Critical Hit Chance", "Critical Multiplier", "Combo Skill (2nd Strike)"];
            
        var stats_vals = [
            string(global.ataque_base) + " DMG",
            string(global.chance_critico) + "%",
            string(global.multiplicador_crit) + "x",
            (arma_nivel >= 2) ? (is_pt ? "DESBLOQUEADO" : "UNLOCKED") : (is_pt ? "Requer Nivel 2" : "Requires Lv. 2")
        ];
        
        for (var s = 0; s < array_length(stats_labels); s++) {
            var sy = cy1 + 84 + (s * 44);
            draw_set_color(col_card);
            draw_rectangle(cx1, sy, cx1 + cw, sy + 36, false);
            draw_set_color(col_border_out);
            draw_rectangle(cx1, sy, cx1 + cw, sy + 36, true);
            
            draw_set_halign(fa_left);
            _draw_txt(cx1 + 18, sy + 18, stats_labels[s], c_white);
            
            draw_set_halign(fa_right);
            var _vcol = (s == 3 && arma_nivel < 2) ? col_hp : col_ok;
            _draw_txt(cx1 + cw - 18, sy + 18, stats_vals[s], _vcol);
        }
    }
    
    // Rodapé
    var div_y = py + ph - 34;
    draw_set_color(col_border_out);
    draw_line(px + 16, div_y, px + pw - 16, div_y);
    
    draw_set_halign(fa_center);
    var dica_hub = is_pt
        ? "[Q/E] Aba   |   [W/S] Selecionar   |   [ENTER] Fabricar   |   [I / ESC] Fechar"
        : "[Q/E] Tab   |   [W/S] Select   |   [ENTER] Craft   |   [I / ESC] Close";
    _draw_txt(gw / 2, py + ph - 17, dica_hub, col_text_sub);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);