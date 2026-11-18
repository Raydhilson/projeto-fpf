if (!variable_instance_exists(id, "escala_base")) escala_base = 1.15;

// ==========================================
// 1. SEGURANÇA DE CONTROLES (TECLADO + GAMEPAD)
// ==========================================
if (!variable_global_exists("slot_atual"))    global.slot_atual    = 1;
if (!variable_global_exists("key_right"))     global.key_right     = vk_right;
if (!variable_global_exists("key_left"))      global.key_left      = vk_left;
if (!variable_global_exists("key_up"))        global.key_up        = vk_up;
if (!variable_global_exists("key_down"))      global.key_down      = vk_down;
if (!variable_global_exists("key_jump"))      global.key_jump      = vk_space;
if (!variable_global_exists("key_attack"))    global.key_attack    = ord("J");
if (!variable_global_exists("key_roll"))      global.key_roll      = ord("K");
if (!variable_global_exists("key_heal"))      global.key_heal      = ord("H");
if (!variable_global_exists("key_throw"))     global.key_throw     = ord("F");
if (!variable_global_exists("key_spin"))      global.key_spin      = ord("L");
if (!variable_global_exists("key_menu"))      global.key_menu      = ord("I");
if (!variable_global_exists("key_confirm"))   global.key_confirm   = vk_enter;
if (!variable_global_exists("idioma"))        global.idioma        = "PT";

// ==========================================
// 2. ECONOMIA (SUCATA COMO MOEDA) E INVENTÁRIO
// ==========================================
if (!variable_global_exists("scrap")) global.scrap = 5; // Começa com 5 sucatas
curativo_count = 1; 
molotov_count  = 1;
faca_count     = 2;

global.ataque_base        = 10;  
global.chance_critico     = 15;  
global.multiplicador_crit = 2.0; 

// ==========================================
// 3. MOVIMENTO E FÍSICA
// ==========================================
hspd = 0;
vspd = 0;
walk_sp = 4;
grv = 0.4;
jump_spd = -9;
max_vspd = 10;        

accel = 0.22;        
fric = 0.15;         

coyote_time_max = 7; 
coyote_timer = 0;
jump_buffer_max = 7; 
jump_buffer_timer = 0;

wall_jump_vspd = -8; 
wall_jump_hspd = 6;  

scale_x = escala_base;        
scale_y = escala_base;
image_xscale = escala_base;
image_yscale = escala_base;

facing = 1;          
roll_sp = 6.5;        
action_timer = 0;    

// ==========================================
// 4. SOBREVIVÊNCIA, COMBATE E HABILIDADE [L]
// ==========================================
hp_max = 100;
hp = hp_max;
is_invulnerable = false;
iframe_timer = 0;

combo_count = 0;        
ataque_buffer = false;  
buff_fogo_timer = 0;    

spin_cooldown = 0;
spin_cooldown_max = 300;
spin_dano_bonus = 0;
vampirismo_hp = 0;

// ==========================================
// 5. MÁQUINA DE ESTADOS (SEM CRAFT)
// ==========================================
enum player_state {
    idle,
    run,
    air,
    attack,
    roll,
    wall_slide,
    menu
}

state = player_state.idle;