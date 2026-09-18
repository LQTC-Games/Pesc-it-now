INCLUDE "hardware.inc"

SECTION "Entry point", ROM0[$150]

main::
  
  ld a, %11_10_01_00
  ldh [rBGP], a
  ;call gameng_init
  ;call gameng_run
  di     ;; Disable Interrupts
  halt   ;; Halt the CPU (stop procesing here)

  

