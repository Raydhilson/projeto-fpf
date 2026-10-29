// Checa se a lança colidiu com o boneco e armazena o ID do ataque
var _hitbox = instance_place(x, y, obj_ataque);

// Se a colisão for verdadeira (diferente de 'noone'/vazio)
if (_hitbox != noone) {

    // 1 e 2. DADO DO CRÍTICO E VARIÁVEIS
    var _dado_critico = irandom_range(1, 100);
    var _dano_final = global.ataque_base;
    var _foi_critico = false;

    // 3. VALIDAÇÃO DO CRÍTICO
    if (_dado_critico <= global.chance_critico) {
        _dano_final = global.ataque_base * global.multiplicador_crit;
        _foi_critico = true;
    }

    // 4. APLICANDO O DANO (Removemos o 'other', pois o código já está dentro do dummy)
    hp -= _dano_final;

    // 5. GAME FEEL
    if (_foi_critico == true) {
        global.hitstop_timer = 15;
        // scr_tremor_camera(5, 10); // Descomente quando o script da câmera for criado
        // instance_create_layer(x, y, "Efeitos", obj_faisca_critica);
    } else {
        global.hitstop_timer = 4;
    }

    // Destrói a hitbox do ataque para o boneco não receber o dano 60x no mesmo golpe
    instance_destroy(_hitbox);
}

// CONTROLE DO FLASH DE DANO
if (tempo_piscar > 0) {
    tempo_piscar -= 1;       // Vai diminuindo o cronômetro até chegar a zero
    image_blend = c_red;     // Pinta o sprite inteiro de vermelho
} else {
    image_blend = c_white;   // c_white devolve a cor original do seu desenho
}