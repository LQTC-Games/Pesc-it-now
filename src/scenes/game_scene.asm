include "../include/include.inc"


SECTION "Scene game", ROM0

scene_game_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_game_load_all_sprites_VRAM
    call scene_game_draw_background    
    call LCDCon
    call man_entity_init

    ; Inicializar la semilla de aleatorio
    call init_random_7
ret

scene_game_buttons:
    ld a, [flancoAscendente]
    .checkB:
        bit 1, a      ; Comprueba el Botón B (Bit 1)
        jr z, .anyKey
        
        ld a, 1       ; 1 = Escena de Menú
        ld [do_change], a 
        
    .anyKey:
ret

scene_game_update::
    call sys_render_update
    call scene_game_buttons
    call man_entity_update
ret


; scene_game_load_all_sprites_VRAM:
;     ld hl, Mapa
;     ld bc, MapaEnd - Mapa
;     ld de, $8000
;     call sys_render_load_sprite
; ret

scene_game_draw_background::
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_game_load_all_sprites_VRAM::
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
    call load_spikeRight_sprites_VRAM
    call load_spikeLeft_sprites_VRAM
    call load_mazorcaDead_sprites_VRAM
ret












