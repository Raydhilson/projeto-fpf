vspd += grv; // A gravidade puxa a garrafa para baixo

// Faz a garrafa girar no ar para dar um efeito visual legal
image_angle -= sign(hspd) * 15; 

// 1. Colisão com o Chão/Parede (Quebra a garrafa)
if (place_meeting(x + hspd, y + vspd, obj_colisor)) {
    // FUTURO: Aqui vamos instanciar o objeto do Fogo no chão
    instance_destroy(); 
}

// 2. Colisão com o Inimigo (Acerto direto!)
var hit_enemy = instance_place(x + hspd, y + vspd, obj_enemy);
if (hit_enemy != noone) {
    // Acessa o inimigo que foi atingido
    with (hit_enemy) {
        // Faz o inimigo "cuspir" 3 sucatas antes de morrer
        repeat(3) {
            instance_create_layer(x, y - 16, "Instances", obj_scrap);
        }
        instance_destroy(); // Destroi o inimigo
    }
    instance_destroy(); // Quebra o molotov
}

// Atualiza a posição
x += hspd;
y += vspd;