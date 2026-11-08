if (coletavel_timer > 0) coletavel_timer--;

// Física simples de queda
vspd += grv;
if (place_meeting(x + hspd, y, obj_colisor)) {
    hspd = 0;
}
x += hspd;

if (place_meeting(x, y + vspd, obj_colisor)) {
    while (!place_meeting(x, y + sign(vspd), obj_colisor)) {
        y += sign(vspd);
    }
    vspd = 0;
    hspd = lerp(hspd, 0, 0.2); // Freia no chão
}
y += vspd;

// Coleta pelo Player
if (coletavel_timer <= 0 && instance_exists(obj_player)) {
    if (place_meeting(x, y, obj_player)) {
        switch (tipo_item) {
            case 0: obj_player.carne_count++;    break; // Alimento (Besouro)
            case 1: obj_player.glandula_count++; break; // Glândula (Besouro)
            case 2: obj_player.ferrao_count++;   break; // Ferrão (Vespa)
        }
        instance_destroy();
    }
}