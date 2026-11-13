if (instance_exists(obj_player)) {
    
    // 1. Calcula o Ponto Médio entre todos os jogadores vivos na sala
    var soma_x = 0;
    var soma_y = 0;
    var total_p = instance_number(obj_player);
    
    for (var i = 0; i < total_p; i++) {
        var p = instance_find(obj_player, i);
        soma_x += p.x;
        soma_y += p.y;
    }
    
    var media_x = soma_x / total_p;
    var media_y = soma_y / total_p;
    
    var target_x = media_x - (cam_width / 2);
    var target_y = media_y - (cam_height / 2) - 20;
    
    // 2. Trava a câmera nas bordas da sala
    target_x = clamp(target_x, 0, max(0, room_width - cam_width));
    target_y = clamp(target_y, 0, max(0, room_height - cam_height));
    
    // 3. Pega a posição atual da câmera
    var current_x = camera_get_view_x(camera);
    var current_y = camera_get_view_y(camera);
    
    // 4. Suavização (LERP)
    var lerp_speed = 0.1;
    var final_x = lerp(current_x, target_x, lerp_speed);
    var final_y = lerp(current_y, target_y, lerp_speed);
    
    // 5. Aplica o Screen Shake
    if (instance_exists(obj_game_controller) && obj_game_controller.shake_magnitude > 0 && global.tremer_tela) {
        var _mag = obj_game_controller.shake_magnitude;
        final_x += random_range(-_mag, _mag);
        final_y += random_range(-_mag, _mag);
    }
    // =====================================================================
// 5.1 TRAVA DE BORDA DE TELA NO CO-OP (IMPEDE SAIR DA CÂMERA)
// =====================================================================
if (instance_number(obj_player) > 1 && instance_exists(obj_camera)) {
    var _cam_x = camera_get_view_x(obj_camera.camera);
    var _cam_w = obj_camera.cam_width;
    var _margem = 14; // Distância mínima da borda da tela em pixels
    
    // Se o jogador tentar passar da borda esquerda ou direita da visão atual, trava!
    var _novo_x = clamp(x, _cam_x + _margem, _cam_x + _cam_w - _margem);
    if (!place_meeting(_novo_x, y, obj_colisor)) {
        x = _novo_x;
    }
}
    // 6. Aplica a posição final arredondada
    camera_set_view_pos(camera, round(final_x), round(final_y));
}