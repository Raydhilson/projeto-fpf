// Verifica se o player existe na sala antes de tentar segui-lo
if (instance_exists(target)) {
    
    // 1. Calcula para onde a câmera DEVE ir (centralizada no player)
    var target_x = target.x - (cam_width / 2);
    var target_y = target.y - (cam_height / 2) - 20; // O -20 joga a câmera um pouco acima para focar melhor no rato
    
    // 2. Trava a câmera para não passar das bordas da sala (evita mostrar o "vazio" fora do mapa)
    target_x = clamp(target_x, 0, room_width - cam_width);
    target_y = clamp(target_y, 0, room_height - cam_height);
    
    // 3. Pega a posição atual da câmera
    var current_x = camera_get_view_x(camera);
    var current_y = camera_get_view_y(camera);
    
    // 4. A MÁGICA DA SUAVIZAÇÃO (LERP)
    var lerp_speed = 0.1;
    var final_x = lerp(current_x, target_x, lerp_speed);
    var final_y = lerp(current_y, target_y, lerp_speed);
    
    // 5. APLICA O SCREEN SHAKE (Sincronizado com o obj_game_controller)
    if (instance_exists(obj_game_controller) && obj_game_controller.shake_magnitude > 0) {
        var _mag = obj_game_controller.shake_magnitude;
        final_x += random_range(-_mag, _mag);
        final_y += random_range(-_mag, _mag);
    }
    
    // 6. Aplica a posição final na câmera do jogo
    camera_set_view_pos(camera, final_x, final_y);
}