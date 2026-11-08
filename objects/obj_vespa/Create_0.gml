hp = 2;
hspd = 0;
vspd = 0;
vel_voo = 2;

enum vespa_state {
    patrulha,
    perseguicao,
    preparando,
    rasante,
    recuperando
}
state = vespa_state.patrulha;

vision_range = 180;
state_timer = 0;
alvo_x = x;
alvo_y = y;

piscar = 0;