// Se você atribuir uma sprite no futuro, ele desenha a sprite automaticamente
if (sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
} else {
    // Marcador visual temporário: porca metálica de 4px
    draw_set_color(make_color_rgb(180, 100, 40)); // Ferrugem/Bronze
    draw_circle(x, y, 4, false);
    draw_set_color(c_yellow);                     // Ponto de luz central
    draw_point(x - 1, y - 1);
    draw_set_color(c_white);
}