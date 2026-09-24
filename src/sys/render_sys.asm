include "../include/hardware.inc"
include "../include/include.inc"

SECTION "WRAM OAM", WRAM0, ALIGN[8]
    copiaOAM::
    DS 160

SECTION "RENDER SYSTEM", WRAM0
    decenas:: DS 2
    unidades:: DS 2
SECTION "DMA Routine", ROM0
    routineDMA:
        ld a, HIGH(copiaOAM) ; Obtiene el byte alto de la dirección
        ldh [$FF46], a ; Inicia una transferencia DMA inmediatamente tras la instrucción
        ld a, 40; Espera un total de 40x4 = 160 ciclos
        .espera
        dec a; 1 ciclo
        jr nz, .espera ; 3 ciclos
        ret
    routineDMAend:

    copiaroutineDMA::
        ld hl, routineDMA;Origen de datos
        ld b, routineDMAend - routineDMA ;Cantidad de bytes a copiar
        ld c, LOW(OAMDMA);Byte bajo de la dirección de destino
        .loop
            ld a, [hl+]
            ldh [c], a
            inc c
            dec b
        jr nz, .loop
    ret

SECTION "OAM DMA", HRAM
    OAMDMA::
    DS routineDMAend - routineDMA


SECTION "Render System", ROM0

sys_render_limpiar_pantalla:
    ld hl, $9800
    ld a, $90
    ld b, 32
    ld c, 32

    .total
        .pintar
            ld [hl], a
            inc hl
            dec b
        jr nz, .pintar
        dec c
    jr nz, .total
ret

sys_render_ActivarSpritesYPaleta:
    ld a, [$FF40]
    or %00000110
    ld [$FF40], a

    ld a, %11100100
    ld [$FF48], a

    ld a, %11100100
    ld [$FF47], a
ret

sys_render_cleanOAM::
    ld hl, $FE00    ; Dirección de la OAM
    ld b, 160       ; En la OAM caben 40 sprites * 4 bytes
    ld a, 0

    .limpiar
        ld [hl], a
        inc hl
        dec b
    jr nz, .limpiar

ret

; CARGAR SPRITES EN VRAM
; INPUT: HL (Etiqueta comienzo), BC (Longitud, final - comienzo), DE (Dirección VRAM)
sys_render_load_sprite::
    .loop
        ld a, [hl]
        ld [de], a
        inc hl
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .loop
ret

;;------------------------------------------------------
;; Función que pinta cualquier escena que sea de 20x18
;; INPUT: HL -> Direccion inicio pantalla ($9800 para arriba izquierda)
;;        BC -> Direccion inicio timemap
;; DESTROYS: AF, HL, DE, BC
sys_render_drawTilemap20x18::
    ld d, 18
    .row
        ld e, 20
        .column
            ld a, [bc]
            ld [hl], a
            inc hl
            inc bc
            dec e
        jr nz, .column
        
        push bc
        ld bc, 12
        add hl, bc
        pop bc
        dec d
    jr nz, .row
ret

;;------------------------------------------------------
;; Función que pinta cualquier escena que sea de 4x8
;; INPUT: HL -> Direccion inicio pantalla ($98A5 primer num, $98AB segundo num)
;;        DE -> Direccion inicio timemap
;; DESTROYS: AF, HL, DE, BC
sys_render_drawTilemap4x8::
    ld b, 8
    .row
        ld c, 4
        .column
            ld a, [de]
            ld [hl], a
            inc hl
            inc de
            dec c
        jr nz, .column
        
        push de
        ld de, 28
        add hl, de
        pop de
        dec b
    jr nz, .row
ret

;; ---------------------------
;; Iniciamos todo lo que tenga ue ver con el pintado en pintalla
;;

sys_render_setUp::
    call LCDCoff

    call sys_render_limpiar_pantalla
    call sys_render_ActivarSpritesYPaleta
    call sys_render_cleanOAM

    call LCDCon

    call copiaroutineDMA
ret

;;------------------------------------------------------
;; Limpia toda la WOAM
;; MODIFIES: AF, BC, HL
;;
sys_render_clear_WOAM::
    ld hl, copiaOAM
    ld a, 0
    ld b, 160
    .loop   
        ld [hl+], a
        dec b
        jr nz, .loop
ret

;;------------------------------------------------------
;; Actualiza las posiciones de la WOAM de todas las entidades activas
;; MODIFIES: AF, BC, DE, HL
;;
sys_render_load_OAM:
    ld de, sys_render_entity
    call man_entity_for_each
ret

;; ---------------------------
;; Actualizamos todas las entidades del entity array y se copian en la OAM DMA
;;
sys_render_update::
    call sys_render_clear_WOAM
    call sys_render_load_OAM;;Repintar las entidades (Cambiar posiciones, tiles o atributos en la OAM)
    
    call wait_VBLANK;;Esperar a VBLANK start
    
    ld a, HIGH(copiaOAM)
    call OAMDMA
ret

;; --------------------------------------------------
;; Pinta la entidad contenida en hl en la OAM
;; INPUT: HL -> direccion de la entidad (Aponta al Byte 0: Entity_Comp)
sys_render_entity::
    inc hl
    inc hl          ;; HL -> Byte 2: Entity_OAMID
    ld a, [hl+]     ;; A = Entity_OAMID, HL avanza al Byte 3: Entity_PosY
    push hl         ;; Guardamos el puntero de Entity_PosY para usarlo en el segundo sprite

    ;; ¡Se ha eliminado el 'dec a' de aquí porque tu OAM_ID empieza en 0!
    sla a
    sla a
    sla a           ;; A = A * 8
    ld de, copiaOAM
    ld e, a         ;; DE -> Posición inicial en la OAM DMA

;; --- PRIMERA MITAD DEL SPRITE (Izquierda) ---
    ;; PosY
    ld a, [hl+]     ;; A = Entity_PosY (Byte 3), HL avanza al Byte 4: PosX
    ld [de], a      ;; OAM[0] = PosY
    inc de

    ;; PosX
    ld a, [hl+]     ;; A = Entity_PosX (Byte 4), HL avanza al Byte 5: Sprite_num
    ld [de], a      ;; OAM[1] = PosX
    inc de

    ;; Tile y Atributo
    ld a, [hl+]     ;; A = Sprite_num (Byte 5), HL avanza al Byte 6: Entity_Attr
    ld [de], a      ;; OAM[2] = Sprite_num
    inc de

    ld a, [hl]      ;; A = Entity_Attr (Byte 6)
    ld [de], a      ;; OAM[3] = Entity_Attr

;; --- SEGUNDA MITAD DEL SPRITE (Derecha) ---
    inc de          ;; DE -> Posición Y del próximo sprite en la OAM
    pop hl          ;; HL vuelve a apuntar al Byte 3: Entity_PosY

    ;; PosY
    ld a, [hl+]     ;; A = Entity_PosY (Byte 3), HL avanza al Byte 4: PosX
    ld [de], a      ;; OAM[4] = PosY
    inc de

    ;; PosX desplazado
    ld a, [hl+]     ;; A = Entity_PosX (Byte 4), HL avanza al Byte 5: Sprite_num
    add a, 8        ;; Desplazamos 8 píxeles a la derecha para la segunda mitad del cuerpo
    ld [de], a      ;; OAM[5] = PosX + 8
    inc de

    ;; Tile desplazado y Atributo
    ld a, [hl+]     ;; A = Sprite_num (Byte 5), HL avanza al Byte 6: Entity_Attr
    add a, 2        ;; Selecciona el tile correspondiente a la mitad derecha
    ld [de], a      ;; OAM[6] = Sprite_num + 2
    inc de

    ld a, [hl]      ;; A = Entity_Attr (Byte 6)
    ld [de], a      ;; OAM[7] = Entity_Attr
ret

load_background_sprites_VRAM::
    ld hl, Mapa
    ld bc, MapaEnd - Mapa
    ld de, $8000
    call sys_render_load_sprite
ret

load_mazorca_sprites_VRAM::
    ld hl, MazorcaFront
    ld bc, MazorcaSide2FEnd - MazorcaFront
    ld de, $8200
    call sys_render_load_sprite
ret




