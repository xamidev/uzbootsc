; uzbootsc - Stage 2 bootloader
; This is free and unencumbered software released into the public domain.

; todo: macros (to make code smaller) for regular calls
; todo: improve calls w/ stack
; todo: declare macros for ENDL 


; **************
; *** macros ***
; **************

%define ENDL 0xA, 0xD

; loaded at this addr by stage1
org 0x8000
bits 16

; greetings
call vga_clear
mov si, msg_itworks
call vga_println

; everything gets back here
shell_loop:
	mov si, msg_prompt
	call vga_print
	
	mov di, buffer
	call str_get

	; ignore blank lines
	mov si, buffer
	cmp byte [si], 0
	je shell_loop

	; command: help
	mov si, buffer
	mov di, cmd_help
	call str_cmp
	jc .help

	; command: reboot
	mov si, buffer
	mov di, cmd_reboot
	call str_cmp
	jc .reboot

	; command: what
	mov si, buffer
	mov di, cmd_what
	call str_cmp
	jc .what
	
	mov si, msg_badcmd
	call vga_println
	jmp shell_loop

; ****************
; *** commands ***
; ****************

.help:
	mov si, msg_help
	call vga_println
	jmp shell_loop

.reboot:
	int 19h
	; we shouldnt reach this
	mov si, err_reboot
	call vga_println
	jmp shell_loop

.what:
	mov si, msg_what
	call vga_println	
	jmp shell_loop
		

; **************
; *** string ***
; **************

str_get:
	xor cl, cl
.loop:
	mov ah, 0
	int 0x16

	cmp al, 0x08
	je .backspace
	
	; enter?
	cmp al, 0x0D
	je .done

	; 3F = 63 chars = limit
	cmp cl, 0x3F
	je .loop

	mov ah, 0x0E
	int 0x10

	stosb
	inc cl
	jmp .loop

.backspace:
	cmp cl, 0
	je .loop

	; decrement counters + print blank char
	dec di
	mov byte [di], 0
	dec cl

	mov ah, 0x0E
	mov al, 0x08
	int 0x10

	mov al, ' '
	int 0x10

	mov al, 0x08
	int 0x10
	
	jmp .loop

.done:
	mov al, 0
	stosb

	; newline
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	
	mov al, 0x0A
	int 0x10

	ret

; carry flag set if equal
str_cmp:

.loop:
	; grab byte from both and compare until zero
	mov al, [si]
	mov bl, [di]
	cmp al, bl
	jne .noteq

	cmp al, 0
	je .done

	inc di
	inc si
	jmp .loop

.noteq:
	clc
	ret

.done:
	stc
	ret

; ***********
; *** vga ***
; ***********

vga_clear:
	mov ah, 0
	mov al, 3
	int 0x10
	ret

; IN:  <si> : pointer to null-terminated string
vga_print:
	.loop:
		lodsb
		or al, al
		jz .done
		mov ah, 0x0E
		int 0x10
		jmp .loop
	.done:
		ret

; IN:  <si> : pointer to null-terminated string
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

; dumb shit
vga_print_hex:
	push ax
	push cx
	push dx
	
	mov cx, 4
.hex_loop:
	rol bx, 4
	mov al, bl
	and al, 0x0F
	cmp al, 10
	jl .hex_digit
	add al, 'A' - 10
	jmp .print_digit
.hex_digit:
	add al, '0'
.print_digit:
	mov ah, 0x0E
	int 10h
	loop .hex_loop

	pop dx
	pop cx
	pop ax
	ret

; ****************
; *** messages ***
; ****************

msg_itworks	db	"uzbootsc version 1 - addr 0x8000", 0
msg_prompt	db	">", 0
msg_help	db	"help reboot what", 0
msg_badcmd	db	"Unknown command", 0
msg_what	db	"[UZLESS BOOTSECTOR]", ENDL, ENDL, "I. Why?", ENDL, ENDL, "yes", 0
err_reboot	db	"Error during reboot sequence", 0

cmd_help	db	"help", 0
cmd_reboot	db	"reboot", 0
cmd_what	db	"what", 0

buffer		times 64 db 0
