// Se o jogo estiver pausado, não roda a lógica de hitstop
if (is_paused) exit;

// ==========================================
// SISTEMA DE HITSTOP (Congelamento de Tempo)
// ==========================================
if (hitstop_timer > 0) {
    hitstop_timer--;
    
    with (all) {
        if (variable_instance_exists(id, "hspd") && variable_instance_exists(id, "vspd")) {
            if (!variable_instance_exists(id, "hspd_save") || is_undefined(hspd_save)) {
                hspd_save = hspd;
                vspd_save = vspd;
                image_speed_save = image_speed;
            }
            hspd = 0;
            vspd = 0;
            image_speed = 0;
        }
    }
} else {
    // Restaura as velocidades assim que o hitstop acaba
    with (all) {
        if (variable_instance_exists(id, "hspd_save") && !is_undefined(hspd_save)) {
            hspd = hspd_save;
            vspd = vspd_save;
            image_speed = image_speed_save;
            hspd_save = undefined;
        }
    }
}