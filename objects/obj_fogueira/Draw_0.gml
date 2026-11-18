draw_self();

// Desenha o Portão Visual do Laboratório na coordenada portao_x!
if (instance_exists(obj_game_controller)) {
    var _px = obj_game_controller.portao_x;
    draw_set_color((obj_game_controller.portao_piscar > 0) ? c_red : make_color_rgb(65, 185, 245));
    draw_rectangle(_px - 12, y - 110, _px + 12, y + 16, false);
    draw_set_color(c_white);
    draw_rectangle(_px - 12, y - 110, _px + 12, y + 16, true);
}

// Desenha o Rato Mercador Aliado
if (sprite_exists(spr_player_idle)) {
    draw_sprite_ext(spr_player_idle, 0, x - 28, y, 1.15, 1.15, 0, make_color_rgb(255, 215, 110), 1.0);
}

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 105) {
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _txt1 = "RATO MERCADOR (LOJA DE SUCATA)";
    var _txt2 = "[E] 3 Sucatas: +50 HP Portao e +35 HP Rato  |  [R] 5 Sucatas: +4 Dano Lanca";
    
    draw_set_color(c_black);
    draw_text(x + 1, y - 69, _txt1);
    draw_text(x + 1, y - 51, _txt2);
    
    draw_set_color(make_color_rgb(245, 195, 65));
    draw_text(x, y - 70, _txt1);
    draw_set_color((global.scrap >= 3) ? make_color_rgb(80, 215, 105) : c_white);
    draw_text(x, y - 52, _txt2);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}