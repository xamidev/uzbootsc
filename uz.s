; uzbootsc - Stage 2 bootloader
; This is free and unencumbered software released into the public domain.

; todo: improve calls w/ stack

; **************
; *** macros ***
; **************

%define ENDL 0xA, 0xD

%macro strcmp 2	
	mov si, %1
	mov di, %2
	call str_cmp
%endmacro

%macro println 1
	mov si, %1
	call vga_println
%endmacro	

; loaded at this addr by stage1
org 0x8000
bits 16

; greetings
call vga_clear
println msg_itworks

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
	strcmp buffer, cmd_help
	jc .help

	; command: reboot
	strcmp buffer, cmd_reboot
	jc .reboot

	; command: what
	strcmp buffer, cmd_what
	jc .what
	
	println msg_badcmd	
	jmp shell_loop

; ****************
; *** commands ***
; ****************

.help:
	println msg_help	
	jmp shell_loop

.reboot:
	int 19h
	; we shouldnt reach this
	println err_reboot
	jmp shell_loop

.what:
	println msg_what
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
