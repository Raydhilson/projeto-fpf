if (piscar > 0) piscar--;

// Se a barricada quebrar, aciona a derrota por Portão Destruído
if (hp <= 0 && instance_exists(obj_game_controller)) {
    if (!obj_game_controller.is_dead) {
        obj_game_controller.portao_hp = 0;
        obj_game_controller.is_dead = true;
        obj_game_controller.motivo_derrota = 2; // 2 = Portão Destruído
        obj_game_controller.death_index = 0;
        obj_game_controller.death_alpha = 0;
        tocar_sfx("snd_centipede_roar", 0.8, 0.9);
        instance_deactivate_all(true);
        instance_activate_object(obj_game_controller);
    }
}