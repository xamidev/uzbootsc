; uzbootsc - Stage 2 bootloader
; This is free and unencumbered software released into the public domain.

org 0x8000
bits 16

mov si, msg_itworks
call vga_println
jmp $

msg_itworks	db	"it works!!!1", 0

%include "vga.s"
