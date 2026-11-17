// ==========================================
// CONFIGURAÇÕES INICIAIS DO ITEM DROPADO
// ==========================================
// Nota: Se não definido ao criar, assume Carne (0) por padrão
if (!variable_instance_exists(id, "tipo_item")) {
    tipo_item = 0; 
}

hspd = random_range(-2.5, 2.5);
vspd = random_range(-4.5, -2.5);
grv  = 0.3;

coletavel_timer = 20; // Frames de segurança para não coletar instantaneamente ao nascer