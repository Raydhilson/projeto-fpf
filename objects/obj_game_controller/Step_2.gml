if (variable_global_exists("tremer_tela") && !global.tremer_tela) {
    shake_magnitude = 0;
}

// Se estiver pausado, não desconta o tremor
if (is_paused) exit;

// ==========================================
// REDUÇÃO DO SCREEN SHAKE
// ==========================================
if (shake_magnitude > 0) {
    shake_magnitude -= shake_fade;
    if (shake_magnitude < 0) {
        shake_magnitude = 0;
    }
}