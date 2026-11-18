if (!variable_instance_exists(id, "target") || !instance_exists(target)) {
    target = instance_exists(obj_player) ? obj_player : noone;
}
if (!variable_instance_exists(id, "cam_w")) cam_w = 683;
if (!variable_instance_exists(id, "cam_h")) cam_h = 384;

if (instance_exists(target)) {
    // 1. ZOOM DINÂMICO: Pertinho no intervalo (683x384) | Afastado na Wave (840x472)
    var _em_combate = (instance_exists(obj_game_controller) && variable_instance_exists(obj_game_controller, "aguardando_ok_wave") && !obj_game_controller.aguardando_ok_wave && obj_game_controller.wave_atual > 0);
    var _target_w = _em_combate ? 840 : 683;
    var _target_h = _em_combate ? 472 : 384;
    
    cam_w = lerp(cam_w, _target_w, 0.06);
    cam_h = lerp(cam_h, _target_h, 0.06);
    camera_set_view_size(view_camera[0], round(cam_w), round(cam_h));

    // 2. SEGUE O PLAYER SUAVEMENTE
    var target_x = target.x - (cam_w / 2);
    var target_y = target.y - (cam_h / 2) - 24;

    x = lerp(x, target_x, 0.12);
    y = lerp(y, target_y, 0.12);

    x = clamp(x, 0, max(0, room_width - cam_w));
    y = clamp(y, 0, max(0, room_height - cam_h));

    // 3. SCREEN SHAKE
    var shake_x = 0;
    var shake_y = 0;

    if (instance_exists(obj_game_controller)) {
        var mag = obj_game_controller.shake_magnitude;
        if (mag > 0) {
            if (!variable_global_exists("tremer_tela") || global.tremer_tela == true) {
                shake_x = random_range(-mag, mag);
                shake_y = random_range(-mag, mag);
            }
            obj_game_controller.shake_magnitude -= obj_game_controller.shake_fade;
            if (obj_game_controller.shake_magnitude < 0) obj_game_controller.shake_magnitude = 0;
        }
    }

    camera_set_view_pos(view_camera[0], round(x + shake_x), round(y + shake_y));
}