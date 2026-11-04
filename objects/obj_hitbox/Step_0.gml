// Pausa a contagem da hitbox durante o Hitstop para não sumir antes da hora
if (instance_exists(obj_game_controller) && obj_game_controller.hitstop_timer > 0) {
    exit;
}

duracao--;

if (duracao <= 0) {
    instance_destroy();
}