// ==========================================
// SISTEMA DE SCREEN SHAKE (Tremor de Câmera)
// ==========================================
if (shake_magnitude > 0) {
    // Pega a posição original da câmera
    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);

    // Sorteia um número aleatório entre o negativo e positivo da magnitude
    var shake_x = random_range(-shake_magnitude, shake_magnitude);
    var shake_y = random_range(-shake_magnitude, shake_magnitude);

    // Move a câmera um pouquinho
    camera_set_view_pos(cam, cam_x + shake_x, cam_y + shake_y);

    // Diminui o tremor gradualmente
    shake_magnitude -= shake_fade;
}