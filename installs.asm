segment .code

_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_09h_off], bx
	mov bx, [es:09h*4+2]
	mov [old_09h_seg], bx

	; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, snooze_handle
	mov [es:09h*4], dx
	mov ax, cs
	mov [es:09h*4+2], ax
	sti
	ret


; Vratiti stari vektor prekida 0x09
_stari_09:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_09h_seg]
	mov [es:09h*4+2], ax
	mov dx, [old_09h_off]
	mov [es:09h*4], dx
	sti
	ret


_novi_1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_int_off], bx
	mov bx, [es:1Ch*4+2]
	mov [old_int_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, timer_int
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x1C
	sti
	ret

_stari_1C:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [old_int_off]
	mov [es:1Ch*4], dx
	sti
	ret



_novi_2f:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:2fh*4]
	mov [old_2fh_off], bx
	mov bx, [es:2fh*4+2]
	mov [old_2fh_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, MyInt2F
	mov [es:2fh*4], dx
	mov ax, cs
	mov [es:2fh*4+2], ax
	sti
	ret

_stari_2f:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_2fh_seg]
	mov [es:2fh*4+2], ax
	mov dx, [old_2fh_off]
	mov [es:2fh*4], dx
	sti
	ret

_novi_28:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:28h*4]
	mov [old_28h_off], bx
	mov bx, [es:28h*4+2]
	mov [old_28h_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, My28h
	mov [es:2fh*4], dx
	mov ax, cs
	mov [es:2fh*4+2], ax
	sti
	ret

_stari_28:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_28h_seg]
	mov [es:28h*4+2], ax
	mov dx, [old_28h_off]
	mov [es:28h*4], dx
	sti
	ret



  segment .data

  old_int_seg: dw 0
  old_int_off: dw 0
  old_09h_seg: dw 0
  old_09h_off: dw 0
  old_2fh_seg: dw 0
  old_2fh_off: dw 0
  old_28h_seg: dw 0
  old_28h_off: dw 0
