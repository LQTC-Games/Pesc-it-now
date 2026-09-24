
SECTION "Scene menu_principal", ROM0


scene_menu_principal_init::

    call LCDCoff
    call scene_menu_principal_load_all_sprites_VRAM
    call sys_render_cleanOAM
    call LCDCon


    Delay:
    ld bc, $FFFF   ; duración (ajusta este valor)
    .wait:
        dec bc
        ld a, b
        or c
        jr nz, .wait
ret


scene_menu_principal_buttons:
    ld a, [flancoAscendente]
    
    bit 0, a      ; Bit 0 = Botón A
    jr z, .anyKey
    
    ld a, 2       ; 2 = Escena Menú Selección
    ld [do_change], a
    
    .anyKey:
ret

scene_menu_principal_update::
    call scene_menu_principal_buttons
    call wait_VBLANK
ret


; Se llama con la pantalla apagada
scene_menu_principal_load_all_sprites_VRAM:
    ld hl, Menu_principal2
    ld bc, Menu_principal2End - Menu_principal2
    ld de, $8000
    call sys_render_load_sprite
    call scene_menu_principal_pintar_menu_principal
    
ret

scene_menu_principal_pintar_menu_principal:
    ld hl, $9800
    ld bc, fondoMenu_principal2
    call sys_render_drawTilemap20x18
ret



