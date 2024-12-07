; the frog project - VGA driver routines
; This is free and unencumbered software released into the public domain.

; IN:  None
; OUT: None
vga_clear:
	mov ah, 0
	mov al, 2
	int 0x10
	ret

; IN:  <si> : pointer to null-terminated string
; OUT: None
vga_println:
	.loop:
		lodsb
		or al, al
		jz .done
		mov ah, 0x0E
		int 0x10
		jmp .loop
	.done:
		mov al, 0xA
		mov ah, 0x0E
		int 0x10
		mov al, 0xD
		mov ah, 0x0E
		int 0x10
		ret
