// Se estiver pausado, não desconta o tremor
if (is_paused) exit;

// ==========================================
// REDUÇÃO DO SCREEN SHAKE (A câmera lê esse valor no End Step dela)
// ==========================================
if (shake_magnitude > 0) {
    shake_magnitude -= shake_fade;
    if (shake_magnitude < 0) {
        shake_magnitude = 0;
    }
}