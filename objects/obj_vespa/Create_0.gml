hp = 2;
hspd = 0;
vspd = 0;
vel_voo = 2;

// Estados da Vespa
enum vespa_state {
    patrulha,
    perseguicao,
    rasante
}
state = vespa_state.patrulha;

vision_range = 180;
rasante_timer = 0;
alvo_x = x;
alvo_y = y;

piscar = 0;