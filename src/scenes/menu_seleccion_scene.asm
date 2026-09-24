include "../include/include.inc"


SECTION "Scene menu_seleccion", ROM0

scene_menu_seleccion_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_menu_seleccion_load_all_sprites_VRAM
    call scene_menu_seleccion_draw_background    
    call LCDCon
ret 

scene_menu_seleccion_buttons:
    ld a, [flancoAscendente]

    .checkB:
        bit 1, a      ; Bit 1 = Botón B -> Volver al Menú Principal
        jr z, .checkA
        ld a, 1       ; do_change = 1
        ld [do_change], a
        ret

    .checkA:
        bit 0, a      ; Bit 0 = Botón A -> Ir al Lago
        jr z, .checkUp
        ld a, 5       ; do_change = 5
        ld [do_change], a
        ret

    .checkUp:
        bit 6, a      ; Bit 6 = Arriba -> Ir al Pantano
        jr z, .checkDown
        ld a, 6       ; do_change = 6
        ld [do_change], a
        ret

    .checkDown:
        bit 7, a      ; Bit 7 = Abajo -> Ir al Océano
        jr z, .checkRight
        ld a, 7       ; do_change = 7
        ld [do_change], a
        ret

    .checkRight:
        bit 4, a      ; Bit 4 = Derecha -> Ir a Menú Compra
        jr z, .checkLeft
        ld a, 3       ; do_change = 3
        ld [do_change], a
        ret
        
    .checkLeft:
        bit 5, a      ; Bit 5 = Izquierda -> Ir a Colección
        jr z, .anyKey
        ld a, 4       ; do_change = 4
        ld [do_change], a

    .anyKey:
ret

scene_menu_seleccion_update::
    call sys_render_update
    call scene_menu_seleccion_buttons
    call man_entity_update
ret


scene_menu_seleccion_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_menu_seleccion_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
ret
