// Draw_0.gml do obj_espinho
var x1 = bbox_left; var y1 = bbox_top; var x2 = bbox_right; var y2 = bbox_bottom;
draw_set_color(c_crimson);
for (var xx = x1; xx < x2; xx += 8) {
    draw_triangle(xx, y2, min(xx + 8, x2), y2, xx + 4, y1, false);
}
draw_set_color(c_white);