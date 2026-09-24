include "../include/include.inc"


SECTION "Scene lago", ROM0

scene_lago_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_lago_load_all_sprites_VRAM
    call scene_lago_draw_background    
    call LCDCon
    call man_entity_init

    ; Inicializar la semilla de aleatorio
    call init_random_7
ret 

scene_lago_buttons:
    ld a, [flancoAscendente]
    
    bit 1, a      ; Bit 1 = Botón B
    jr z, .anyKey
    
    ld a, 2       ; 2 = Volver al Menú de Selección
    ld [do_change], a
    
    .anyKey:
ret

scene_lago_update::
    call sys_render_update
    call scene_lago_buttons
    call man_entity_update
ret


scene_lago_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_lago_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
ret












