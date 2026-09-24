include "../include/include.inc"
include "../include/hardware.inc"
;;------------------------------
;;WRAM SECTION------------------

SECTION "Entity Array", WRAM0
;;DATA
    RSRESET
    DEF Entity_Comp RB 1    ; [Byte 0]
    DEF Entity_ID RB 1      ; [Byte 1] 
    DEF Entity_OAMID RB 1   ; [Byte 2]
    DEF Entity_PosY RB 1    ; [Byte 3] 
    DEF Entity_PosX RB 1    ; [Byte 4] 
    DEF Sprite_num RB 1     ; [Byte 5]
    DEF Entity_Attr RB 1    ; [Byte 6]
    DEF Size RB 1           ; [Byte 7] 
    DEF Price RB 1          ; [Byte 8]
;;Space for entities
    entity_array:: DS ENTITY_ARRAY_SIZE

SECTION "Entity Manager", ROM0

;;-------------------------------
;;ENTITY MANAGER-----------------
;;Struct player-------------------------------------------
;; AQUI IRIAN LOS STRUCTS PREDEFINIDOS SI QUEREMOS

struct_player:
    DB 1             ; [Byte 1] Entity_ID
    DB 1             ; [Byte 2] Entity_OAMID
    DB SPAWN_Y       ; [Byte 3] Entity_PosY
    DB SPAWN_X       ; [Byte 4] Entity_PosX
    DB SPRITE_PLAYER ; [Byte 5] Sprite_num
    DB DEFAULT_ATR   ; [Byte 6] Entity_Attr
    DB 1             ; [Byte 7] Size
    DB 0             ; [Byte 8] Price
    

;;

;;--------------------------------------------------------
;; Inicializa el array de entidades.
;; - Limpia entity_array (sets all to 0’s)
;; WARNING: Solo funciona con arrays menores de 256 bytes
;; DESTROYS: AF, B, HL
;;
man_entity_init::
    ld a, 0
    ld hl, entity_array
    ld b, ENTITY_ARRAY_SIZE
    .loop
        ld [hl+], a
        dec b
        jr nz, .loop
    
    call man_entity_create_player
ret

;;-------------------------------------------------------
;; Encuentra el primer hueco libre
;; WARNING: Se pasa si el array esta lleno. (Asegurarse de que hay uno vacio antes)
;; DESTROYS: AF, HL, DE
;; OUTPUT:
;; - HL -> Primer hueco libre
;; - DE = SIZEOF_E
;;
man_entity_find_first_free_slot:
    ld de, SIZEOF_E
    ld hl, entity_array
    .loop
        ld a, [hl]
        cp 0
        jp z, .end
        add hl, de
        jp .loop
    .end
ret

;;-------------------------------------------------------
;; Reserva espacio en el array para una nueva entidad
;; - Reserva un espacio para una nueva entidad.
;; - Marca su byte 0 con DEFAULT_CMP para reservarla
;; WARNING: Se pasa si el array esta lleno. (Asegurarse de que hay uno vacio antes)
;; DESTROYS: AF, DE, HL
;; OUTPUT:
;; - HL -> Hueco +1 reservado para la entidad
;; - DE = SIZEOF_E
;;
man_entity_alloc:
    call man_entity_find_first_free_slot
    ld a, DEFAULT_CMP
    ld [hl+], a
ret

;;-------------------------------------------------------
;; Libera una entidad en entity_array, dejándola
;; disponible para nuevas entidades
;; - Marca la entidad como libre
;; WARNING: Asume que HL es un puntero a una entidad válida
;; INPUT:
;; - HL -> Entidad a liberar
;;
man_entity_free:
    ld [hl], $00
ret

;;-------------------------------------------------------
;; Comprueba si la entidad dada es del tipo dado
;; WARNING: Asume que HL es un puntero a una entidad válida
;; INPUT:
;; - HL -> Entidad a comprobar
;; - B  -> Tipo a comparar
;;MODIFIES: AF
;; OUTPUT:
;; - Flag Z -> Activado (1) si la entidad es de tipo B
man_entity_is_type_b:
    inc hl
    ld a, [hl]
    dec hl
    cp b
ret

;;-------------------------------------------------------
;; Comprueba si la entidad dada es del tipo dado
;; WARNING: Asume que B es un tipo valido
;; INPUT:
;; - B  -> Tipo a encontrar
;;MODIFIES: AF, DE, HL
;; OUTPUT:
;; - HL -> Puntero a la entidad encontrada (hl -> $0000 si no hay ninguno)
   man_entity_first_by_type:
    ld hl, entity_array
    ld de, SIZEOF_E
    ld c, MAX_ENTITIES
    .loop
        ld a, [hl]
        cp 0
        jr z, .next
        call man_entity_is_type_b
        ret z
        .next
            add hl, de
            dec c
            jr nz, .loop
    ld hl, 0
ret

;;-------------------------------------------------------
;; Hace una operacion en todas las entidades válidas (reservadas)
;; del entity_array:
;; - Itera por todas las entidades
;; - Por cada entidad válida, llama a la función
;;   pasada por parámetro (la operación).
;; - Al llamar a la función (operacion), HL
;;   debe ser la dirección de la entidad válida siendo
;;   iterada.
;; DESTROYS: AF, BC, DE, HL
;; INPUT:
;; - DE -> Puntero a la función (operación) a
;;   realizar en todas las entidades válidas una a una.
;;   Esta función espera en HL una dirección valida
;;   a una entidad.
;;  OUTPUT:
;;  - HL -> direccion de memoria de la entidad válida
;;
man_entity_for_each::
   ld hl, entity_array
   ld a, 0
   .loop
        push af
        push de
        push hl
        ld a, [hl]
        cp 0
        jr z, .back
        ld bc, .back
        push bc
        push de
        ret
        .back
        pop hl
        pop de
        pop af
        add SIZEOF_E
        ld bc, SIZEOF_E
        add hl, bc
        cp ENTITY_ARRAY_SIZE
      jp nz, .loop
ret

;;-------------------------------------------------------
;; Hace la operacion pasada por parámetro en las entidades válidas del tipo
;; también pasado por parámetro de entity_array.
;; DESTROYS: AF, BC, DE, HL
;; INPUT:
;; - DE -> Puntero a la función (operación) a
;;   realizar en todas las entidades válidas una a una.
;;   Esta función espera en HL una dirección valida
;;   a una entidad.
;; - B -> Tipo de la entidad a iterar
;;
man_entity_for_each_by_type::
   ;;Recorreria todas las entidades y devolveria las que correspondan al type pasado por input
   ld hl, entity_array
   ld a, 0
   .loop
        push af
        push bc
        push de
        push hl
        ld a, [hl]
        cp 0
        jr z, .back
        call man_entity_is_type_b
        jr nz, .back
        ld bc, .back
        push bc
        push de
        ret
        .back
        pop hl
        pop de
        pop bc
        pop af
        add SIZEOF_E
        push bc
        ld bc, SIZEOF_E
        add hl, bc
        cp ENTITY_ARRAY_SIZE
        pop bc
      jp nz, .loop
ret

;;-------------------------------------------------------
;; Llama a entity update single por cada una de las entidades activas
;; DESTROYS: AF, BC, DE, HL
;;
man_entity_update::
    ld de, man_entity_update_single
    call man_entity_for_each
ret

;;-------------------------------------------------------
;; Actualiza los valores de la entidad pasada en HL
;; DESTROYS: AF, DE, HL
;; INPUT:
;; - HL -> dirección de una entidad válida del entity_sarray
;;
man_entity_update_single::
    inc hl                  ;;Colocamos HL en Entity_Type
    ld a, [hl]              ;;Guardamos el tipo en A
ret



;;-------------------------------------------------------
;; Crea en la primera posicion libre del entity_array, la entidad spike
;; WARNING: No lo coloca en la OAM, se debe hacer fuera
;; DESTROYS: AF, HL, BC, DE
;; OUTPUT: -HL -> posición de memoria de la entidad creada
;;
;;
man_entity_create_player::
    call man_entity_alloc
    dec hl

    push hl

    inc hl

    ld de, struct_player

    ld b, SIZEOF_E - 1
    .loop
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
        jr nz, .loop

    pop hl
ret