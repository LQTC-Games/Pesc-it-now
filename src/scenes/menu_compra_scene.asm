include "../include/include.inc"


SECTION "Scene menu_compra", ROM0

scene_menu_compra_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_menu_compra_load_all_sprites_VRAM
    call scene_menu_compra_draw_background    
    call LCDCon
    
ret 

scene_menu_compra_buttons:
    ld a, [flancoAscendente]
    
    bit 1, a      ; Bit 1 = Botón B
    jr z, .anyKey
    
    ld a, 2       ; 2 = Volver al Menú de Selección
    ld [do_change], a
    
    .anyKey:
ret

scene_menu_compra_update::
    call sys_render_update
    call scene_menu_compra_buttons
    call man_entity_update
ret


scene_menu_compra_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_menu_compra_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
ret
