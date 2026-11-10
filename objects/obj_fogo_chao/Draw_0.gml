// Desenha labaredas animadas via código
for (var i = -20; i <= 20; i += 8) {
    var alt = 8 + sin((current_time / 60) + i) * 6;
    draw_set_color(c_orange);
    draw_triangle(x + i - 5, y, x + i + 5, y, x + i, y - alt - 4, false);
    draw_set_color(c_yellow);
    draw_triangle(x + i - 3, y, x + i + 3, y, x + i, y - (alt * 0.6), false);
}
draw_set_color(c_white);