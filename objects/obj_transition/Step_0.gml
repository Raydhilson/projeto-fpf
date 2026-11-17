if (estado == 1) {
    // Escurece a tela gradualmente
    alpha += velocidade_fade;
    if (alpha >= 1) {
        alpha = 1;
        // Quando a tela estiver 100% preta, troca de sala
        if (room_exists(destino_room)) {
            room_goto(destino_room);
        }
        estado = 2; // Começa a clarear na nova sala
    }
} 
else if (estado == 2) {
    // Clareia a tela gradualmente
    alpha -= velocidade_fade;
    if (alpha <= 0) {
        alpha = 0;
        estado = 0; // Terminou a transição, destrói o objeto para não pesar
        instance_destroy();
    }
}