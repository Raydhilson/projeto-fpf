var _shake_x = (state == enemy_state.chemical_prep) ? irandom_range(-2, 2) : 0;

if (piscar > 0) {
    gpu_set_fog(true, c_white, 0, 0); 
}

if (sprite_index != -1) {
    draw_sprite_ext(sprite_index, image_index, x + _shake_x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
} else {
    draw_set_color(image_blend);
    draw_rectangle(x - 16 + _shake_x, y - 32, x + 16 + _shake_x, y, false);
    
    draw_set_color(c_black);
    draw_rectangle(x + (8 * facing) + _shake_x, y - 24, x + (12 * facing) + _shake_x, y - 20, false);
    
    draw_set_color(c_white);
}

if (piscar > 0) {
    gpu_set_fog(false, c_white, 0, 0); 
}
