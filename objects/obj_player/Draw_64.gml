var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

var col_bg_panel   = make_color_rgb(18, 20, 26);
var col_header     = make_color_rgb(28, 32, 42);
var col_card       = make_color_rgb(26, 30, 40);
var col_border_out = make_color_rgb(90, 80, 65);
var col_gold       = make_color_rgb(235, 185, 60);
var col_highlight  = make_color_rgb(45, 50, 65);
var col_text_off   = make_color_rgb(150, 155, 165);
var col_hp         = make_color_rgb(210, 45, 55);
var col_scrap      = make_color_rgb(215, 130, 50);

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
// --- 1. HUD DE SOBREVIVÊNCIA (Canto Superior Esquerdo) ---
// =======================================================
var gui_x = 20;
var gui_y = 20;
var hud_w = 200;
var hud_h = (buff_fogo_timer > 0) ? 82 : 62;

draw_set_color(c_black);
draw_set_alpha(0.65);
draw_rectangle(gui_x - 8, gui_y - 8, gui_x + hud_w, gui_y + hud_h, false);
draw_set_alpha(1.0);

draw_set_color(col_border_out);
draw_rectangle(gui_x - 8, gui_y - 8, gui_x + hud_w, gui_y + hud_h, true);

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

var info_y = gui_y + 26;
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

draw_set_color(col_scrap);
draw_circle(gui_x + 6, info_y, 5, false);
draw_set_color(c_white);
draw_text(gui_x + 15, info_y, "x" + string(global.scrap));

draw_set_color(col_text_off);
draw_text(gui_x + 62, info_y, "[" + str_key_heal + "] " + string(curativo_count) + "   [" + str_key_throw + "] " + string(faca_count + molotov_count));

if (buff_fogo_timer > 0) {
    var seg_restantes = ceil(buff_fogo_timer / 60);
    var txt_buff = is_pt ? "LANCA EM CHAMAS: " : "FLAMING SPEAR: ";
    draw_set_color(c_orange);
    draw_text(gui_x, info_y + 20, txt_buff + string(seg_restantes) + "s");
}

// =======================================================
// --- 2. TELA DEDICADA DO HUB (EM TELA INTEIRA) ---
// =======================================================
if (state == player_state.menu || state == player_state.craft) {
    draw_set_font(fnt_menu);
    
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    draw_set_color(c_black);
    draw_set_alpha(0.88);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = min(680, gw * 0.90);
    var ph = min(440, gh * 0.85);
    var px = (gw - pw) / 2;
    var py = (gh - ph) / 2;
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);
    
    // Cabeçalho de Abas
    var tab_w = (pw - 6) / 3;
    var tab_h = 44;
    var nome_abas = is_pt ? ["INVENTARIO", "CRAFTING", "MAESTRIA"] : ["INVENTORY", "CRAFTING", "MASTERY"];
    
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
            draw_set_color(c_white);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i]);
        } else {
            draw_set_color(col_header);
            draw_rectangle(tx1, ty1, tx2, ty2, false);
            draw_set_color(col_text_off);
            draw_text((tx1 + tx2) / 2, (ty1 + ty2) / 2, nome_abas[i]);
        }
    }
    
    var cx1 = px + 24;
    var cy1 = py + 65;
    var cw  = pw - 48;
    
    // Aba 1: Crafting
    if (aba_atual == 1) {
        draw_set_color(col_header);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 40, false);
        draw_set_color(col_border_out);
        draw_rectangle(cx1, cy1, cx1 + cw, cy1 + 40, true);
        
        var txt_recursos = is_pt
            ? "ESTOQUE:   Sucata: " + string(global.scrap) + "   |   Carne: " + string(carne_count) + "   |   Glandula: " + string(glandula_count) + "   |   Ferrao: " + string(ferrao_count)
            : "STOCK:   Scrap: " + string(global.scrap) + "   |   Meat: " + string(carne_count) + "   |   Gland: " + string(glandula_count) + "   |   Stinger: " + string(ferrao_count);
            
        draw_set_halign(fa_center);
        draw_set_color(col_gold);
        draw_text(gw / 2, cy1 + 20, txt_recursos);
        
        var desc_receitas = is_pt
            ? ["Restaura +30 de HP", "Cria poca de fogo continua", "Dano perfurante rapido"]
            : ["Restores +30 HP", "Creates fire pool on impact", "Fast piercing projectile"];
            
        var nome_org = is_pt ? ["1 Carne", "1 Glandula", "1 Ferrao"] : ["1 Meat", "1 Gland", "1 Stinger"];
        var qtd_org_atual = [carne_count, glandula_count, ferrao_count];
        var qtd_item_inv  = [curativo_count, molotov_count, faca_count];
        
        var card_h = 60;
        var start_cy = cy1 + 55;
        
        for (var j = 0; j < array_length(craft_recipes); j++) {
            var ry1 = start_cy + (j * (card_h + 12));
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
            
            draw_set_halign(fa_left);
            draw_set_color(is_sel ? c_white : c_ltgray);
            draw_text(cx1 + 20, ry1 + 20, craft_recipes[j] + "  (x" + string(qtd_item_inv[j]) + ")");
            draw_set_color(col_text_off);
            draw_text(cx1 + 20, ry1 + 42, desc_receitas[j]);
            
            draw_set_halign(fa_right);
            var str_custo = string(custo_suc) + (is_pt ? " Sucatas + " : " Scrap + ") + nome_org[j];
            draw_set_color(pode_craftar ? make_color_rgb(70, 200, 95) : col_hp);
            draw_text(cx1 + cw - 20, ry1 + 20, str_custo);
            
            var str_status = (state == player_state.craft && craft_selected_item == j)
                ? (is_pt ? "[ FABRICANDO... ]" : "[ CRAFTING... ]")
                : (pode_craftar ? (is_pt ? "[ PRONTO ]" : "[ READY ]") : (is_pt ? "[ SEM RECURSOS ]" : "[ NO RES ]"));
            draw_text(cx1 + cw - 20, ry1 + 42, str_status);
        }
    } else {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(col_text_off);
        draw_text(gw / 2, py + (ph / 2), is_pt ? "Use Q / E para ir para a aba Crafting" : "Use Q / E to switch to Crafting tab");
    }
    
    var div_y = py + ph - 45;
    draw_set_color(col_border_out);
    draw_line(px + 20, div_y, px + pw - 20, div_y);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(col_text_off);
    var dica_hub = is_pt
        ? "[Q/E] Trocar Aba    [W/S] Selecionar    [ENTER / A] Fabricar    [I / ESC] Fechar"
        : "[Q/E] Switch Tab    [W/S] Select    [ENTER / A] Craft    [I / ESC] Close";
    draw_text(gw / 2, py + ph - 22, dica_hub);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}

// ==========================================
// DESENHO NORMAL DO PERSONAGEM (FORA DO MENU)
// ==========================================
if (state != player_state.menu && state != player_state.craft && sprite_index != -1) {
    var alpha_atual = 1.0;
    if (is_invulnerable && iframe_timer > 0) {
        if ((iframe_timer mod 8) < 4) alpha_atual = 0.2;
    }
    
    draw_sprite_ext(
        sprite_index,
        image_index,
        x,
        y,
        scale_x * facing, 
        scale_y,
        image_angle,
        image_blend,
        alpha_atual       
    );
}