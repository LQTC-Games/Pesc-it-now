
SECTION "Scene menu", ROM0


scene_menu_init::

    call LCDCoff
    call scene_menu_load_all_sprites_VRAM
    call sys_render_cleanOAM
    call scene_menu_draw_press_a
    call LCDCon


    Delay:
    ld bc, $FFFF   ; duración (ajusta este valor)
    .wait:
        dec bc
        ld a, b
        or c
        jr nz, .wait
ret


scene_menu_buttons:
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

scene_menu_update::
    call scene_menu_buttons
    call wait_VBLANK
ret


; Se llama con la pantalla apagada
scene_menu_load_all_sprites_VRAM:
    ld hl, Menu2
    ld bc, Menu2End - Menu2
    ld de, $8000
    call sys_render_load_sprite
    call scene_menu_pintar_menu
    
ret

scene_menu_pintar_menu:
    ld hl, $9800
    ld bc, fondoMenu2
    call sys_render_drawTilemap20x18
ret


scene_menu_draw_press_a:
    ld a, $CF   ; P
    ld hl, $9987
    ldi [hl], a

    ld a, $D1   ; R
    ldi [hl], a

    ld a, $C4   ; E
    ldi [hl], a

    ld a, $D2   ; S
    ldi [hl], a

    ld a, $D2   ; S
    ldi [hl], a


    inc hl

    ld a, $C0   ; A
    ldi [hl], a
    
ret

