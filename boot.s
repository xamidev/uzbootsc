; uzbootsc - Stage 1 bootloader
; This is free and unencumbered software released into the public domain.

org 0x7C00
bits 16

section .text

mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

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
	jmp $

times 510-($-$$) db 0
dw 0AA55h
