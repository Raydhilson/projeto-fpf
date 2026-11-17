if (!variable_instance_exists(id, "escala_base")) escala_base = 1.15;

// ==========================================
// 1. SEGURANÇA DE CONTROLES (FALLBACK)
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
if (!variable_global_exists("key_menu"))      global.key_menu      = ord("I");
if (!variable_global_exists("key_confirm"))   global.key_confirm   = vk_enter;
if (!variable_global_exists("key_tab_left"))  global.key_tab_left  = ord("Q");
if (!variable_global_exists("key_tab_right")) global.key_tab_right = ord("E");
if (!variable_global_exists("idioma"))        global.idioma        = "PT";

// ==========================================
// 2. ECONOMIA, CONSUMÍVEIS E MATERIAIS
// ==========================================
if (!variable_global_exists("scrap")) global.scrap = 0;
curativo_count = 0; 
molotov_count  = 0;
faca_count     = 0;

carne_count    = 0; 
glandula_count = 0; 
ferrao_count   = 0; 

global.ataque_base        = 10;  
global.chance_critico     = 15;  
global.multiplicador_crit = 2.0; 

// ==========================================
// 3. SISTEMA DE CRAFTING E ABAS
// ==========================================
craft_timer = 0;
craft_time_max = 90; 
craft_cost = 5;      
craft_recipes = ["Curativo", "Molotov", "Faca de Arremesso"];
craft_cost_array = [3, 5, 8];
craft_selected_item = -1; 
menu_index = 0; 

aba_atual = 1; // Inicia direto na aba de Crafting

// ==========================================
// 4. MOVIMENTO E FÍSICA
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
slash_frame = 0;

// ==========================================
// 5. SOBREVIVÊNCIA E I-FRAMES
// ==========================================
hp_max = 100;
hp = hp_max;
is_invulnerable = false;
iframe_timer = 0;

// ==========================================
// 6. MAESTRIA E BUFFS
// ==========================================
arma_xp = 0;
arma_xp_max = 10;       
arma_nivel = 1;         
combo_count = 0;        
ataque_buffer = false;  
buff_fogo_timer = 0;    

// ==========================================
// 7. MÁQUINA DE ESTADOS (FSM)
// ==========================================
enum player_state {
    idle,
    run,
    air,
    attack,
    roll,
    wall_slide,
    craft,
    menu
}

state = player_state.idle;

// Restaurar Save se houver (Incluindo Facas e Escala de XP Máximo)
if (variable_global_exists("carregando_save") && global.carregando_save == true) {
    x              = global.load_x;
    y              = global.load_y;
    hp             = global.load_hp;
    curativo_count = global.load_curativos;
    molotov_count  = global.load_molotovs;
    faca_count     = variable_global_exists("load_facas") ? global.load_facas : 0;
    arma_nivel     = global.load_arma_nivel;
    arma_xp        = global.load_arma_xp;
    arma_xp_max    = (arma_nivel >= 2) ? 20 : 10;
    carne_count    = global.load_carne;
    glandula_count = global.load_glandula;
    ferrao_count   = global.load_ferrao;
    global.carregando_save = false; 
}