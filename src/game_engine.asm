SECTION "Actual scene", WRAM0
    loaded_high_score: ds 1
    act_scene:: DS 1 ;; 0 -> escena menú
                    ;; 1 -> escena gameplay

    do_change:: DS 1 ;;Cuando sea 0 no cambiará
                    ;;cuando sea 1 cambiará a la escena del menu
                    ;;cuando sea 2 cambiará a la escena del juego



SECTION "ENGINE GAME", ROM0

engine_game_check_inputs_scene_menu:

    call utils_read_buttons

    .checkB
        ld a, [flancoAscendente]
        bit 0, a
        jr z, .checkA

    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

        ld a, 2
        ld [do_change], a

    .anyKey


ret

;;-------------------------------------------------------
;; Comprueba en la escena actual que este y dependiendo de 
;; cual sea llama a su update correspondiente
;; DESTROYS: AF
gameng_current_scene_update::
    ld a, [act_scene]
    
    cp 0
    jr nz, .chk_1
    call scene_menu_principal_update
    jr .exit
    
    .chk_1
    cp 1
    jr nz, .chk_2
    call scene_menu_seleccion_update
    jr .exit
    
    .chk_2
    cp 2
    jr nz, .chk_3
    call scene_menu_compra_update
    jr .exit
    
    .chk_3
    cp 3
    jr nz, .chk_4
    call scene_coleccion_update
    jr .exit
    
    .chk_4
    cp 4
    jr nz, .chk_5
    call scene_lago_update
    jr .exit
    
    .chk_5
    cp 5
    jr nz, .chk_6
    call scene_pantano_update
    jr .exit
    
    .chk_6
    cp 6
    jr nz, .exit
    call scene_oceano_update

    .exit:
ret


;;-------------------------------------------------------
;; Realiza los cambios de escena inicializando la escena a la que se vaya a transicionar
;; DESTROYS: AF, [act_scene], [do_change]
gameng_change_scene::
    ld a, [do_change]
    cp 0
    jp z, .exit

    cp 1
    jr nz, .not_1
    ld a, 0
    ld [do_change], a
    ld a, 0
    ld [act_scene], a
    call scene_menu_principal_init
    jr .exit
    .not_1:

    cp 2
    jr nz, .not_2
    ld a, 0
    ld [do_change], a
    ld a, 1
    ld [act_scene], a
    call scene_menu_seleccion_init
    jr .exit
    .not_2:

    cp 3
    jr nz, .not_3
    ld a, 0
    ld [do_change], a
    ld a, 2
    ld [act_scene], a
    call scene_menu_compra_init
    jr .exit
    .not_3:

    cp 4
    jr nz, .not_4
    ld a, 0
    ld [do_change], a
    ld a, 3
    ld [act_scene], a
    call scene_coleccion_init
    jr .exit
    .not_4:

    cp 5
    jr nz, .not_5
    ld a, 0
    ld [do_change], a
    ld a, 4
    ld [act_scene], a
    call scene_lago_init
    jr .exit
    .not_5:

    cp 6
    jr nz, .not_6
    ld a, 0
    ld [do_change], a
    ld a, 5
    ld [act_scene], a
    call scene_pantano_init
    jr .exit
    .not_6:

    cp 7
    jr nz, .exit
    ld a, 0
    ld [do_change], a
    ld a, 6
    ld [act_scene], a
    call scene_oceano_init

    .exit:
ret

gameng_init::
    call sys_render_setUp

    ld a, 0
    ld [act_scene], a   ;;inicializo [act_scene] a 0 (menu)
    ld [do_change], a   ;;inicializo [do_change] a 0 (no cambiar a nada)
ret

gameng_run::
    call scene_menu_principal_init
    ; call scene_game_initc
    .gameloop
        call utils_read_buttons
        call gameng_current_scene_update
        call gameng_change_scene
    jr .gameloop
ret


    