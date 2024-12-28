; uzbootsc - Stage 1 bootloader
; This is free and unencumbered software released into the public domain.

%macro println 1
	mov si, %1
	call vga_println
%endmacro

org 0x7C00
bits 16

section .text

mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

start:
	call vga_clear
	println msg_welcome
	println msg_loading

stage2_loader:
	; load next sectors at 0x8000
	mov ah, 0x02
	mov al, 0x01
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, 0x80
	mov bx, 0x8000
	int 0x13

	jc stage2_error
	jmp 0x0000:0x8000

stage2_error:
	println msg_error
	jmp $

%include "vga.s"

msg_welcome	db	'uzbootsc', 0
msg_loading	db	'loading stage2...', 0
msg_error	db 	'error while loading stage2. halting system!', 0

times 510-($-$$) db 0
dw 0AA55h
