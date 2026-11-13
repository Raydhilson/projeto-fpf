// =======================================================
// --- 0. VERIFICAÇÃO DE IDIOMA E PALETA DE CORES UI ---
// =======================================================
var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

var col_bg_panel   = make_color_rgb(18, 20, 26);
var col_header     = make_color_rgb(28, 32, 42);
var col_card       = make_color_rgb(26, 30, 40);
var col_border_out = make_color_rgb(90, 80, 65);
var col_gold       = make_color_rgb(235, 185, 60);
var col_highlight  = make_color_rgb(45, 50, 65);
var col_text_off   = make_color_rgb(150, 155, 165);
var col_hp         = make_color_rgb(210, 45, 55);
var col_stam       = make_color_rgb(70, 200, 95);
var col_scrap      = make_color_rgb(215, 130, 50);

// Converte a tecla com segurança para exibir nos atalhos
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

var str_key_heal   = _nome_k(global.key_heal);
var str_key_throw  = _nome_k(global.key_throw);
var str_key_attack = _nome_k(global.key_attack);
var str_key_menu   = _nome_k(global.key_menu);
var str_tab_l      = _nome_k(global.key_tab_left);
var str_tab_r      = _nome_k(global.key_tab_right);

// =======================================================
// --- 1. HUD DE SOBREVIVÊNCIA (P1 na Esquerda | P2 na Direita) ---
// =======================================================
var hud_w = 200;
var hud_h = (buff_fogo_timer > 0) ? 98 : 76;
var gui_x = (player_id == 0) ? 20 : (display_get_gui_width() - hud_w - 20);
var gui_y = 20;

// Painel de Fundo da HUD (Resolve o texto encavalando no fundo!)
draw_set_color(c_black);
draw_set_alpha(0.65);
draw_rectangle(gui_x - 8, gui_y - 8, gui_x + hud_w, gui_y + hud_h, false);
draw_set_alpha(1.0);

draw_set_color(col_border_out);
draw_rectangle(gui_x - 8, gui_y - 8, gui_x + hud_w, gui_y + hud_h, true);

// 1.1 Barra de HP
var bar_width  = 160;
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
draw_set_color(c_white);
draw_text(gui_x + (bar_width / 2), gui_y + (bar_height / 2), string(hp) + " / " + string(hp_max));

// 1.2 Barra de Estamina
var stam_y      = gui_y + 20;
var stam_height = 9;
var stam_pct    = clamp(stamina_current / stamina_max, 0, 1);

draw_set_color(make_color_rgb(15, 30, 20));
draw_rectangle(gui_x, stam_y, gui_x + bar_width, stam_y + stam_height, false);
draw_set_color(stamina_exhausted ? c_orange : col_stam);
draw_rectangle(gui_x, stam_y, gui_x + (bar_width * stam_pct), stam_y + stam_height, false);
draw_set_color(col_border_out);
draw_rectangle(gui_x, stam_y, gui_x + bar_width, stam_y + stam_height, true);

// 1.3 Linha de Recursos Rápidos (Sucata, Curativos e Arremessáveis)
var info_y = stam_y + 22;
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

// Ícone de Sucata + Contador
draw_set_color(col_scrap);
draw_circle(gui_x + 6, info_y, 5, false);
draw_set_color(c_white);
draw_text(gui_x + 15, info_y, "x" + string(global.scrap));

// Atalhos Rápidos de Combate na HUD
draw_set_color(col_text_off);
draw_text(gui_x + 62, info_y, "[" + str_key_heal + "] " + string(curativo_count) + "   [" + str_key_throw + "] " + string(faca_count + molotov_count));

// 1.4 Indicador de Buff de Fogo do Besouro
if (buff_fogo_timer > 0) {
    var seg_restantes = ceil(buff_fogo_timer / 60);
    var txt_buff = is_pt ? "LANCA EM CHAMAS: " : "FLAMING SPEAR: ";
    draw_set_color(c_orange);
    draw_text(gui_x, info_y + 20, txt_buff + string(seg_restantes) + "s");
}

// =======================================================
// --- 2. HUB DO PERSONAGEM (Menu em Painéis e Cards) ---
// =======================================================
if (state == player_state.menu) {
    draw_set_font(fnt_menu);
    
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    if (is_pt) {
        nome_abas     = ["INVENTARIO", "CRAFTING", "MAESTRIA"];
        craft_recipes = ["Curativo", "Molotov", "Faca de Arremesso"];
    } else {
        nome_abas     = ["INVENTORY", "CRAFTING", "MASTERY"];
        craft_recipes = ["Bandage", "Molotov", "Throwing Knife"];
    }
    
    // Fundo Escurecido Translúcido
    draw_set_color(c_black);
    draw_set_alpha(0.82);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    // Dimensões da Janela Principal do Hub
    var pw = min(580, gw * 0.92);
    var ph = min(340, gh * 0.86);
    var px = (gw - pw) / 2;
    var py = (gh - ph) / 2;
    
    // Sombra e Fundo do Painel
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
    
    // --- 2.1 CABEÇALHO DE ABAS (3 Abas Superiores) ---
    var tab_w = (pw - 6) / 3;
    var tab_h = 40;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    for (var i = 0; i < 3; i++) {
        var tx1 = px + 3 + (i * tab_w);
        var tx2 = tx1 + tab_w;
        var ty1 = py + 3;
        var ty2 = ty1 + tab_h;
        
        if (aba_atual == i) {
            draw_set_color(col_highlight);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_gold);
            draw_rectangle(tx1, ty2 - 3, tx2, ty2, false);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i]);
        } else {
            draw_set_color(col_header);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_text_off);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i]);
        }
        
        // Linha divisória vertical entre abas
        if (i > 0) {
            draw_set_color(col_border_out);
            draw_line(tx1, ty1 + 6, tx1, ty2 - 6);
        }
    }
    
    // Dicas laterais de troca de aba ([Q/LB] e [E/RB])
    draw_set_color(col_gold);
    draw_set_halign(fa_left);
    draw_text(px + 10, py + 22, "[" + str_tab_l + "]");
    draw_set_halign(fa_right);
    draw_text(px + pw - 10, py + 22, "[" + str_tab_r + "]");
    
    // Área interna de conteúdo
    var cx1 = px + 20;
    var cy1 = py + 56;
    var cw  = pw - 40;
    
    // ===================================================
    // ABA 0: INVENTÁRIO (DIVIDIDO EM 2 COLUNAS DE CARDS)
    // ===================================================
    if (aba_atual == 0) {
        var col_w = (cw - 16) / 2;
        var c1_x  = cx1;
        var c2_x  = cx1 + col_w + 16;
        var box_h = ph - 115;
        
        // Card Esquerdo: Equipamentos & Status
        draw_set_color(col_card);
        draw_rectangle(c1_x, cy1, c1_x + col_w, cy1 + box_h, false);
        draw_set_color(col_border_out);
        draw_rectangle(c1_x, cy1, c1_x + col_w, cy1 + box_h, true);
        
        draw_set_halign(fa_center);
        draw_set_color(col_gold);
        draw_text(c1_x + (col_w / 2), cy1 + 18, is_pt ? "EQUIPAMENTO E BOLSA" : "GEAR & POUCH");
        draw_line(c1_x + 12, cy1 + 32, c1_x + col_w - 12, cy1 + 32);
        
        var inv_left_labels = [
            is_pt ? "Vida (HP)" : "Health (HP)",
            is_pt ? "Sucata" : "Scrap",
            (is_pt ? "Curativos [" : "Bandages [") + str_key_heal + "]",
            (is_pt ? "Molotovs [" : "Molotovs [") + str_key_throw + "]",
            (is_pt ? "Facas [" : "Knives [") + str_key_throw + "]"
        ];
        var inv_left_vals = [
            string(hp) + "/" + string(hp_max),
            string(global.scrap),
            "x" + string(curativo_count),
            "x" + string(molotov_count),
            "x" + string(faca_count)
        ];
        
        for (var k = 0; k < 5; k++) {
            var ry = cy1 + 52 + (k * 32);
            draw_set_halign(fa_left);
            draw_set_color(c_ltgray);
            draw_text(c1_x + 14, ry, inv_left_labels[k]);
            
            draw_set_halign(fa_right);
            draw_set_color(k == 1 ? col_scrap : col_gold);
            draw_text(c1_x + col_w - 14, ry, inv_left_vals[k]);
        }
        
        // Card Direito: Materiais Orgânicos (Drops dos Insetos)
        draw_set_color(col_card);
        draw_rectangle(c2_x, cy1, c2_x + col_w, cy1 + box_h, false);
        draw_set_color(col_border_out);
        draw_rectangle(c2_x, cy1, c2_x + col_w, cy1 + box_h, true);
        
        draw_set_halign(fa_center);
        draw_set_color(col_gold);
        draw_text(c2_x + (col_w / 2), cy1 + 18, is_pt ? "MATERIAIS ORGANICOS" : "ORGANIC MATERIALS");
        draw_line(c2_x + 12, cy1 + 32, c2_x + col_w - 12, cy1 + 32);
        
        var mat_labels = [
            is_pt ? "Carne de Inseto" : "Insect Meat",
            is_pt ? "Glandula Quimica" : "Chemical Gland",
            is_pt ? "Ferrao de Vespa" : "Wasp Stinger"
        ];
        var mat_sub = [
            is_pt ? "Usado em: Curativo" : "Used in: Bandage",
            is_pt ? "Usado em: Molotov" : "Used in: Molotov",
            is_pt ? "Usado em: Faca" : "Used in: Knife"
        ];
        var mat_vals = [carne_count, glandula_count, ferrao_count];
        
        for (var m = 0; m < 3; m++) {
            var my = cy1 + 58 + (m * 52);
            draw_set_halign(fa_left);
            draw_set_color(c_white);
            draw_text(c2_x + 14, my - 7, mat_labels[m]);
            draw_set_color(col_text_off);
            draw_text(c2_x + 14, my + 11, mat_sub[m]);
            
            draw_set_halign(fa_right);
            draw_set_color(mat_vals[m] > 0 ? col_stam : c_dkgray);
            draw_text(c2_x + col_w - 14, my, "x" + string(mat_vals[m]));
        }
    }
    
    // ===================================================
    // ABA 1: CRAFTING (BANCADA COM VALIDAÇÃO DE CUSTOS)
    // ===================================================
    else if (aba_atual == 1) {
        // Faixa Superior com Resumo dos Materiais Disponíveis
        draw_set_color(col_header);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 34, false);
        draw_set_color(col_border_out);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 34, true);
        
        var txt_recursos = is_pt
            ? "ESTOQUE:   Sucata: " + string(global.scrap) + "   |   Carne: " + string(carne_count) + "   |   Glandula: " + string(glandula_count) + "   |   Ferrao: " + string(ferrao_count)
            : "STOCK:   Scrap: " + string(global.scrap) + "   |   Meat: " + string(carne_count) + "   |   Gland: " + string(glandula_count) + "   |   Stinger: " + string(ferrao_count);
            
        draw_set_halign(fa_center);
        draw_set_color(col_gold);
        draw_text(gw / 2, cy1 + 17, txt_recursos);
        
        // Descrições e Requisitos de cada Receita
        var desc_receitas = is_pt
            ? ["Restaura +30 de HP", "Cria poca de fogo continua", "Dano perfurante rapido"]
            : ["Restores +30 HP", "Creates fire pool on impact", "Fast piercing projectile"];
            
        var nome_org = is_pt
            ? ["1 Carne", "1 Glandula", "1 Ferrao"]
            : ["1 Meat", "1 Gland", "1 Stinger"];
            
        var qtd_org_atual = [carne_count, glandula_count, ferrao_count];
        var qtd_item_inv  = [curativo_count, molotov_count, faca_count];
        
        var card_h = 54;
        var start_cy = cy1 + 48;
        
        for (var j = 0; j < array_length(craft_recipes); j++) {
            var ry1 = start_cy + (j * (card_h + 10));
            var ry2 = ry1 + card_h;
            var is_sel = (menu_index == j);
            
            var custo_suc = craft_cost_array[j];
            var pode_craftar = (global.scrap >= custo_suc && qtd_org_atual[j] >= 1);
            
            // Fundo do Card da Receita
            draw_set_color(is_sel ? col_highlight : col_card);
            draw_rectangle(cx1, ry1, cx1 + cw, ry2, false);
            
            // Borda e Marcador Lateral
            draw_set_color(is_sel ? col_gold : col_border_out);
            draw_rectangle(cx1, ry1, cx1 + cw, ry2, true);
            if (is_sel) {
                draw_rectangle(cx1, ry1, cx1 + 6, ry2, false);
            }
            
            // Esquerda: Nome do Item + Efeito
            draw_set_halign(fa_left);
            draw_set_color(is_sel ? c_white : c_ltgray);
            draw_text(cx1 + 18, ry1 + 17, craft_recipes[j] + "  (x" + string(qtd_item_inv[j]) + ")");
            draw_set_color(col_text_off);
            draw_text(cx1 + 18, ry1 + 37, desc_receitas[j]);
            
            // Direita: Custo e Disponibilidade (Verde se tem recursos, Vermelho se falta!)
            draw_set_halign(fa_right);
            var str_custo = string(custo_suc) + (is_pt ? " Sucatas + " : " Scrap + ") + nome_org[j];
            draw_set_color(pode_craftar ? col_stam : col_hp);
            draw_text(cx1 + cw - 16, ry1 + 17, str_custo);
            
            var str_status = pode_craftar 
                ? (is_pt ? "[ PRONTO PARA CRIAR ]" : "[ READY TO CRAFT ]")
                : (is_pt ? "[ RECURSOS INSUFICIENTES ]" : "[ MISSING RESOURCES ]");
            draw_text(cx1 + cw - 16, ry1 + 37, str_status);
        }
    }
    
    // ===================================================
    // ABA 2: MAESTRIA (BARRA DE XP E CARDS DE PERKS)
    // ===================================================
    else if (aba_atual == 2) {
        // Cabeçalho da Arma + Barra de Progresso de XP
        draw_set_color(col_header);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 54, false);
        draw_set_color(col_border_out);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 54, true);
        
        draw_set_halign(fa_left);
        draw_set_color(col_gold);
        var titulo_arma = is_pt ? "ARMA: LANCA DE PREGO" : "WEAPON: NAIL SPEAR";
        draw_text(cx1 + 16, cy1 + 16, titulo_arma + "   (NV. " + string(arma_nivel) + ")");
        
        // Barra de XP
        var xpb_w = 200;
        var xpb_h = 12;
        var xpb_x = cx1 + cw - xpb_w - 16;
        var xpb_y = cy1 + 10;
        var xp_pct = clamp(arma_xp / max(1, arma_xp_max), 0, 1);
        
        draw_set_color(c_black);
        draw_rectangle(xpb_x, xpb_y, xpb_x + xpb_w, xpb_y + xpb_h, false);
        draw_set_color(col_gold);
        draw_rectangle(xpb_x, xpb_y, xpb_x + (xpb_w * xp_pct), xpb_y + xpb_h, false);
        draw_set_color(col_border_out);
        draw_rectangle(xpb_x, xpb_y, xpb_x + xpb_w, xpb_y + xpb_h, true);
        
        draw_set_halign(fa_right);
        draw_set_color(col_text_off);
        draw_text(cx1 + cw - 16, cy1 + 36, "XP: " + string(arma_xp) + " / " + string(arma_xp_max));
        
        draw_set_halign(fa_left);
        var crit_atual = (arma_nivel >= 3) ? (global.chance_critico * 2) : global.chance_critico;
        draw_text(cx1 + 16, cy1 + 36, (is_pt ? "Dano Base: " : "Base Dmg: ") + string(global.ataque_base) + "  |  Crit: " + string(crit_atual) + "%");
        
        // Cards dos 3 Níveis de Maestria
        var perk_titles = is_pt
            ? ["NIVEL 1: Estocada Rapida", "NIVEL 2: Avanco Duplo", "NIVEL 3: Predador Alfa"]
            : ["LEVEL 1: Quick Thrust", "LEVEL 2: Double Strike", "LEVEL 3: Alpha Predator"];
            
        var perk_descs = is_pt
            ? ["Ataque base veloz com cancelamento de esquiva.", "Aperte [" + str_key_attack + "] duas vezes para desferir um 2o golpe pesado.", "Dobra a chance de Acerto Critico da lanca (2.0x Dano)."]
            : ["Fast base thrust with dodge cancel window.", "Press [" + str_key_attack + "] twice to unleash a heavy 2nd combo hit.", "Doubles Nail Spear critical strike chance (2.0x Dmg)."];
            
        var p_start_y = cy1 + 68;
        var p_card_h  = 48;
        
        for (var p = 0; p < 3; p++) {
            var nv_req = p + 1;
            var desbloqueado = (arma_nivel >= nv_req);
            var py1 = p_start_y + (p * (p_card_h + 8));
            var py2 = py1 + p_card_h;
            
            draw_set_color(desbloqueado ? col_highlight : col_card);
            draw_rectangle(cx1, py1, cx1 + cw, py2, false);
            
            draw_set_color(desbloqueado ? col_gold : col_border_out);
            draw_rectangle(cx1, py1, cx1 + cw, py2, true);
            if (desbloqueado) {
                draw_rectangle(cx1, py1, cx1 + 5, py2, false);
            }
            
            draw_set_halign(fa_left);
            draw_set_color(desbloqueado ? col_gold : c_dkgray);
            draw_text(cx1 + 16, py1 + 15, perk_titles[p]);
            
            draw_set_color(desbloqueado ? c_white : col_text_off);
            draw_text(cx1 + 16, py1 + 34, perk_descs[p]);
            
            draw_set_halign(fa_right);
            draw_set_color(desbloqueado ? col_stam : c_dkgray);
            var txt_st = desbloqueado ? (is_pt ? "[ ATIVO ]" : "[ ACTIVE ]") : (is_pt ? "[ BLOQUEADO ]" : "[ LOCKED ]");
            draw_text(cx1 + cw - 16, py1 + 24, txt_st);
        }
    }
    
    // --- 2.3 RODAPÉ DE COMANDOS DO HUB ---
    var div_y = py + ph - 34;
    draw_set_color(col_border_out);
    draw_line(px + 16, div_y, px + pw - 16, div_y);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text_off);
    var dica_hub = is_pt
        ? "[" + str_tab_l + "/" + str_tab_r + " ou LB/RB] Trocar Aba    [W/S] Selecionar    [ENTER / A] Fabricar    [" + str_key_menu + " / SELECT] Fechar"
        : "[" + str_tab_l + "/" + str_tab_r + " or LB/RB] Switch Tab    [W/S] Select    [ENTER / A] Craft    [" + str_key_menu + " / SELECT] Close";
    draw_text(gw / 2, py + ph - 17, dica_hub);
    
    // Reseta o alinhamento e a fonte
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}