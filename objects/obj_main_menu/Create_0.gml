menu_index = 0;

// Array de opções padronizado
options = ["new_game", "continue_game", "options", "quit"]; 

// Mantivemos a chamada da sua função "save_existe", já que ela está em português no seu scr_save_system
has_save = save_existe(1);

// Se não tiver save, o cursor pula o "Continuar" e vai direto pro "Novo Jogo"
if (!has_save) {
    menu_index = 0; 
} else {
    menu_index = 1; 
}