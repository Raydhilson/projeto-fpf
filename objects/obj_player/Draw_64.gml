if (display_get_gui_width() != 1024) {
    display_set_gui_size(1024, 576);
}

if (instance_exists(obj_game_controller)) {
    if (obj_game_controller.is_paused || obj_game_controller.is_dead || obj_game_controller.escolhendo_carta) {
        exit;
    }
}

var is_pt = (!variable_global_exists("idioma") || global.idioma == "PT");

var col_bg_panel   = make_color_rgb(14, 16, 22);
var col_header     = make_color_rgb(24, 28, 38);
var col_card       = make_color_rgb(22, 26, 34);
var col_border_out = make_color_rgb(85, 75, 60);
var col_gold       = make_color_rgb(245, 195, 65);
var col_text_sub   = make_color_rgb(185, 190, 205);
var col_hp         = make_color_rgb(220, 50, 60);
var col_ok         = make_color_rgb(80, 215, 105);
var col_scrap      = make_color_rgb(225, 140, 55);

var _draw_txt = function(_x, _y, _str, _col) {
    draw_set_color(c_black);
    draw_text(round(_x) + 1, round(_y) + 1, _str);
    draw_set_color(_col);
    draw_text(round(_x), round(_y), _str);
};

var _nome_k = function(_k) {
    if (_k == vk_space) return "SPC";
    if (_k == vk_shift) return "SHF";
    if (_k == vk_control) return "CTL";
    if (_k == vk_enter) return "ENT";
    if (_k >= 48 && _k <= 90) return chr(_k);
    return "KEY";
};

var str_key_heal  = _nome_k(global.key_heal);
var str_key_throw = _nome_k(global.key_throw);

draw_set_font(fnt_menu);

// =======================================================
// --- 1. HUD DE SOBREVIVÊNCIA (Canto Superior Esquerdo - 230px de largura!) ---
// =======================================================
if (state != player_state.menu) {
    var gui_x = 16;
    var gui_y = 12;
    var hud_w = 230;
    var hud_h = (buff_fogo_timer > 0) ? 88 : 68;

    draw_set_color(make_color_rgb(14, 16, 22));
    draw_set_alpha(0.85);
    draw_rectangle(gui_x, gui_y, gui_x + hud_w, gui_y + hud_h, false);
    draw_set_alpha(1.0);

    draw_set_color(col_border_out);
    draw_rectangle(gui_x, gui_y, gui_x + hud_w, gui_y + hud_h, true);

    var bar_x      = gui_x + 12;
    var bar_y      = gui_y + 8;
    var bar_width  = hud_w - 24;
    var bar_height = 16;
    var hp_pct     = clamp(hp / hp_max, 0, 1);

    draw_set_color(make_color_rgb(35, 15, 20));
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    draw_set_color(col_hp);
    draw_rectangle(bar_x, bar_y, bar_x + (bar_width * hp_pct), bar_y + bar_height, false);
    draw_set_color(col_gold);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    _draw_txt(bar_x + (bar_width / 2), bar_y + (bar_height / 2), "HP: " + string(hp) + " / " + string(hp_max), c_white);

    var info_y = gui_y + 36;
    draw_set_halign(fa_left);

    // Moeda Sucata + Itens
    draw_set_color(col_scrap);
    draw_circle(bar_x + 5, info_y, 4, false);
    _draw_txt(bar_x + 14, info_y, "$" + string(global.scrap), col_gold);

    _draw_txt(bar_x + 68, info_y, "[" + str_key_heal + "]:" + string(curativo_count) + "  [" + str_key_throw + "]:" + string(molotov_count + faca_count), col_text_sub);

    // Cooldown do Golpe Giratório (Texto curto que nunca vaza da caixa!)
    var _txt_spin = (spin_cooldown <= 0) 
        ? (is_pt ? "[L] GIRO: PRONTO" : "[L] SPIN: READY") 
        : (is_pt ? "[L] GIRO: " : "[L] SPIN: ") + string(ceil(spin_cooldown / 60)) + "s";
    _draw_txt(bar_x, info_y + 18, _txt_spin, (spin_cooldown <= 0) ? col_ok : col_text_sub);

    if (buff_fogo_timer > 0) {
        var seg_restantes = ceil(buff_fogo_timer / 60);
        _draw_txt(bar_x, info_y + 36, (is_pt ? "FOGO: " : "FIRE: ") + string(seg_restantes) + "s", c_orange);
    }
}

// =======================================================
// --- 2. TELA ÚNICA DE INVENTÁRIO (TECLA I / SELECT) ---
// =======================================================
if (state == player_state.menu) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    
    draw_set_color(c_black);
    draw_set_alpha(0.90);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1.0);
    
    var pw = 840;
    var ph = 430;
    var px = round((gw - pw) / 2);
    var py = round((gh - ph) / 2);
    
    draw_set_color(col_bg_panel);
    draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(col_border_out);
    draw_rectangle(px, py, px + pw, py + ph, true);
    draw_set_color(col_gold);
    draw_rectangle(px + 2, py + 2, px + pw - 2, py + ph - 2, true);
    
    draw_set_color(col_header);
    draw_rectangle(px + 3, py + 3, px + pw - 3, py + 44, false);
    draw_set_color(col_gold);
    draw_line(px + 2, py + 44, px + pw - 2, py + 44);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    _draw_txt(gw / 2, py + 24, is_pt ? "INVENTARIO E ATRIBUTOS" : "INVENTORY & STATS", col_gold);
    
    var cx1 = px + 28;
    var cy1 = py + 62;
    var cw  = pw - 56;
    var col_w = (cw - 24) / 2;
    var c2_x  = cx1 + col_w + 24;
    
    draw_set_halign(fa_left);
    _draw_txt(cx1 + 4, cy1 + 8, is_pt ? "ITENS DE COMBATE" : "COMBAT ITEMS", col_gold);
    
    var gear_names = is_pt ? ["Kit de Cura", "Molotov Explosivo", "Facas de Arremesso"] : ["Healing Kit", "Explosive Molotov", "Throwing Knives"];
    var gear_desc  = is_pt ? ["Cura +35 HP [" + str_key_heal + "]", "Fogo em area [" + str_key_throw + "]", "Dano rapido [" + str_key_throw + "]"] : ["Heals +35 HP", "Area fire", "Fast throw"];
    var gear_qtd   = [curativo_count, molotov_count, faca_count];
    
    for (var k = 0; k < 3; k++) {
        var iy = cy1 + 30 + (k * 76);
        draw_set_color(col_card);
        draw_rectangle(cx1, iy, cx1 + col_w, iy + 64, false);
        draw_set_color(col_border_out);
        draw_rectangle(cx1, iy, cx1 + col_w, iy + 64, true);
        
        draw_set_halign(fa_left);
        _draw_txt(cx1 + 16, iy + 20, gear_names[k], c_white);
        _draw_txt(cx1 + 16, iy + 44, gear_desc[k], col_text_sub);
        
        draw_set_halign(fa_right);
        _draw_txt(cx1 + col_w - 16, iy + 32, "x" + string(gear_qtd[k]), (gear_qtd[k] > 0) ? col_ok : col_hp);
    }
    
    draw_set_halign(fa_left);
    _draw_txt(c2_x + 4, cy1 + 8, is_pt ? "MOEDA E ATRIBUTOS" : "CURRENCY & STATS", col_gold);
    
    var stat_names = is_pt 
        ? ["Sucata (Moeda)", "Dano da Lanca", "Critico", "Giro 360 [L / LB]"] 
        : ["Scrap (Coin)", "Spear Damage", "Critical", "360 Spin [L / LB]"];
    var stat_vals  = [
        "$" + string(global.scrap),
        string(global.ataque_base) + " DMG",
        string(global.chance_critico) + "% (" + string(global.multiplicador_crit) + "x)",
        string(spin_cooldown_max / 60) + "s CD"
    ];
    
    for (var m = 0; m < 4; m++) {
        var my = cy1 + 30 + (m * 56);
        draw_set_color(col_card);
        draw_rectangle(c2_x, my, c2_x + col_w, my + 46, false);
        draw_set_color((m == 0) ? col_gold : col_border_out);
        draw_rectangle(c2_x, my, c2_x + col_w, my + 46, true);
        
        draw_set_halign(fa_left);
        _draw_txt(c2_x + 16, my + 23, stat_names[m], c_white);
        
        draw_set_halign(fa_right);
        _draw_txt(c2_x + col_w - 16, my + 23, stat_vals[m], (m == 0) ? col_gold : col_ok);
    }
    
    var div_y = py + ph - 38;
    draw_set_color(col_border_out);
    draw_line(px + 16, div_y, px + pw - 16, div_y);
    
    draw_set_halign(fa_center);
    _draw_txt(gw / 2, py + ph - 19, is_pt ? "Compre Cura e Explosivos no Rato Mercador   |   [I / ESC / B] Fechar" : "Buy Healing & Explosives at Rat Merchant   |   [I / ESC / B] Close", col_text_sub);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);