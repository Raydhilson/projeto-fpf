// Calcula as bordas exatas do bloco (mesmo esticado na Room!)
var x1 = bbox_left;
var y1 = bbox_top;
var x2 = bbox_right;
var y2 = bbox_bottom;

// 1. Corpo de terra/concreto escuro da ruína
draw_set_color(make_color_rgb(35, 30, 40));
draw_rectangle(x1, y1, x2, y2, false);

// 2. Borda interna sutil para dar volume de plataforma
draw_set_color(make_color_rgb(55, 48, 65));
draw_rectangle(x1 + 1, y1 + 1, x2 - 1, y2 - 1, true);

// 3. Camada de musgo/grama da floresta no topo (4 pixels de altura)
draw_set_color(make_color_rgb(45, 115, 60));
draw_rectangle(x1, y1, x2, min(y1 + 4, y2), false);

draw_set_color(c_white);