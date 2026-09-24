include "../include/include.inc"


SECTION "Scene coleccion", ROM0

scene_coleccion_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_coleccion_load_all_sprites_VRAM
    call scene_coleccion_draw_background    
    call LCDCon
    
ret 

scene_coleccion_buttons:
    ld a, [flancoAscendente]
    
    bit 1, a      ; Bit 1 = Botón B
    jr z, .anyKey
    
    ld a, 2       ; 2 = Volver al Menú de Selección
    ld [do_change], a
    
    .anyKey:
ret

scene_coleccion_update::
    call sys_render_update
    call scene_coleccion_buttons
    call man_entity_update
ret


scene_coleccion_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_coleccion_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
ret
