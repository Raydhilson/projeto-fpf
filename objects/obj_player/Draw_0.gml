if (sprite_index != -1 && sprite_exists(sprite_index)) {
    var alpha_atual = 1.0;
    
    // Só pisca se estiver invulnerável fora do roll E se não for apenas a sobrinha final do roll
    if (state != player_state.roll && is_invulnerable && iframe_timer > 0) {
        if ((iframe_timer mod 8) < 4) alpha_atual = 0.2;
    }
    
    // Garante que o image_index nunca tente desenhar um sub-frame inválido
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