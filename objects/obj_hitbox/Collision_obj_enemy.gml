if (other.piscar <= 0) {
    other.hp -= dano;
    other.piscar = 10; 
    
    // Knockback
    other.hspd = sign(image_xscale) * 6; 
    other.vspd = -4;                     
    
    // HITSTOP E SCREEN SHAKE
 // HITSTOP E SCREEN SHAKE (SUAVE E SECO)
    if (instance_exists(obj_game_controller)) {
        obj_game_controller.hitstop_timer = 4;      // 3 frames (só o suficiente para sentir o peso)
        obj_game_controller.shake_magnitude = 1.5;  // Tremor máximo de 1.5 pixels
    }
    
    show_debug_message("BATEU! Vida do Inimigo: " + string(other.hp));
}