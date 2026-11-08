if (sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
} else {
    // Fogueira provisória caso ainda não tenha sprite
    draw_set_color(make_color_rgb(120, 70, 30));
    draw_rectangle(x - 10, y - 4, x + 10, y, false);
    draw_set_color(choose(c_orange, c_yellow, c_red));
    draw_triangle(x - 8, y - 4, x + 8, y - 4, x, y - 22 + irandom_range(-2, 2), false);
    draw_set_color(c_white);
}

if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) <= 40) {
    draw_set_font(fnt_menu);
    draw_set_halign(fa_center);
    var _pt = (!variable_global_exists("idioma") || global.idioma == "PT");
    
    if (salvo_timer > 0) {
        draw_set_color(c_lime);
        draw_text(x, y - 42, _pt ? "JOGO SALVO & VIDA RECUPERADA!" : "GAME SAVED & HP RESTORED!");
    } else {
        draw_set_color(c_yellow);
        draw_text(x, y - 42, _pt ? "[E / ENTER] DESCANSAR" : "[E / ENTER] REST & SAVE");
    }
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}