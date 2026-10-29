// Física de arremesso e gravidade
vspd = random_range(-4, -2.5); // Salto para cima
hspd = random_range(-2.5, 2.5); // Espalha para os lados
grv = 0.25;
bounce = 0.5;                   // Coeficiente de ressalto (perde metade da força ao quicar)
bounces_left = 2;               // Quantidade de quiques antes de parar no chão

// Sistema de Magnetismo
magnet_radius = 64;             // Distância em pixels para começar a puxar
magnet_spd = 0;                 // Velocidade inicial de atração
magnet_accel = 0.5;             // Aceleração em direção ao rato
is_magnetized = false;

value = 1;                      // Quantidade de sucata por unidade