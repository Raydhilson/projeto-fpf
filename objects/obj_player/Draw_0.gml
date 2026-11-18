if (sprite_index != -1 && sprite_exists(sprite_index)) {
    var alpha_atual = 1.0;
    
    if (state != player_state.roll && is_invulnerable && iframe_timer > 0) {
        if ((iframe_timer mod 8) < 4) alpha_atual = 0.2;
    }
    
    var frame_seguro = clamp(image_index, 0, sprite_get_number(sprite_index) - 1);
    
    draw_sprite_ext(
        sprite_index,
        frame_seguro,
        x,
        y,
        scale_x * facing, 
        scale_y,
        image_angle,
        image_blend,
        alpha_atual       
    );
}