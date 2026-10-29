// ==========================================
// SISTEMA DE HITSTOP (Congelamento de Tempo)
// ==========================================
if (hitstop_timer > 0) {
    hitstop_timer--;
    
    with (all) {
        if (variable_instance_exists(id, "hspd") && variable_instance_exists(id, "vspd")) {
            // Se ainda não salvou, ou se está vazio (undefined), salva os valores reais!
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
    // Restaura as velocidades
    with (all) {
        if (variable_instance_exists(id, "hspd_save") && !is_undefined(hspd_save)) {
            hspd = hspd_save;
            vspd = vspd_save;
            image_speed = image_speed_save;
            
            // Esvazia para o próximo golpe de forma segura
            hspd_save = undefined;
        }
    }
}