// 1. Verificação de proximidade com o jogador
if (instance_exists(obj_player)) {
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (dist <= magnet_radius) {
        is_magnetized = true;
    }
}

// 2. Comportamento magnético
if (is_magnetized && instance_exists(obj_player)) {
    // Alvo no centro do rato (peito/cintura)
    var target_x = obj_player.x;
    var target_y = obj_player.y - 12;
    
    var dir = point_direction(x, y, target_x, target_y);
    magnet_spd = min(magnet_spd + magnet_accel, 9); // Ganha velocidade gradativa até o limite
    
    x += lengthdir_x(magnet_spd, dir);
    y += lengthdir_y(magnet_spd, dir);
    
    // Coleta por contato
    if (point_distance(x, y, target_x, target_y) < 10) {
        global.scrap += value;
        instance_destroy();
    }
} else {
    // 3. Física de gravidade e ressalto com o cenário
    vspd += grv;
    
    // Colisão Horizontal
    if (place_meeting(x + hspd, y, obj_colisor)) {
        while (!place_meeting(x + sign(hspd), y, obj_colisor)) {
            x += sign(hspd);
        }
        hspd = -hspd * bounce;
    }
    x += hspd;
    
    // Colisão Vertical (Quique)
    if (place_meeting(x, y + vspd, obj_colisor)) {
        while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
            y += sign(vspd);
        }
        
        if (bounces_left > 0) {
            vspd = -vspd * bounce;
            bounces_left--;
        } else {
            vspd = 0;
            hspd = lerp(hspd, 0, 0.15); // Atrito até parar
        }
    }
    y += vspd;
} // <-- Faltava esta chave aqui!