if (sprite_index != -1 && sprite_exists(sprite_index)) {
    draw_self();
} else {
    // Corpo da garrafa
    draw_set_color(c_green);
    draw_rectangle(x - 3, y - 8, x + 3, y + 6, false);
    
    // Pano em chamas
    draw_set_color(c_orange);
    draw_rectangle(x - 2, y - 14, x + 2, y - 8, false);
    
    draw_set_color(c_white);
}