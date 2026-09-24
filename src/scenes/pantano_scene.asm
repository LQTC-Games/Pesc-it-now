include "../include/include.inc"


SECTION "Scene pantano", ROM0

scene_pantano_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_pantano_load_all_sprites_VRAM
    call scene_pantano_draw_background    
    call LCDCon
ret 

scene_pantano_buttons:
    ld a, [flancoAscendente]
    
    bit 1, a      ; Bit 1 = Botón B
    jr z, .anyKey
    
    ld a, 2       ; 2 = Volver al Menú de Selección
    ld [do_change], a
    
    .anyKey:
ret

scene_pantano_update::
    call sys_render_update
    call scene_pantano_buttons
    call man_entity_update
ret


scene_pantano_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_pantano_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
ret
