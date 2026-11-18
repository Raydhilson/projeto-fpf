draw_self();

// Desenha o Rato Mercador Aliado alinhado no chão
if (sprite_exists(spr_player_idle)) {
    draw_sprite_ext(spr_player_idle, 0, x - 24, y, 1.15, 1.15, 0, make_color_rgb(255, 215, 110), 1.0);
}

// Painel compacto da Loja quando o player chega perto
if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 90) {
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _bx = clamp(x, 150, room_width - 150);
    var _by = y - 75;
    
    draw_set_color(make_color_rgb(14, 16, 22));
    draw_set_alpha(0.88);
    draw_rectangle(_bx - 135, _by - 26, _bx + 135, _by + 26, false);
    draw_set_alpha(1.0);
    draw_set_color(make_color_rgb(245, 195, 65));
    draw_rectangle(_bx - 135, _by - 26, _bx + 135, _by + 26, true);
    
    draw_set_color(make_color_rgb(245, 195, 65));
    draw_text(_bx, _by - 11, "[E / Quadrado] $2: +Cura e Reparo");
    draw_set_color((global.scrap >= 3) ? make_color_rgb(80, 215, 105) : c_white);
    draw_text(_bx, _by + 11, "[R / Bola] $3: +2 Molotovs e +3 Facas");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
}