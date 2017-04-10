; ==================================================
; Prekidi.asm
;    - Cuvanje starih vektora prekida
;    - Postavljanje novih vektora prekida
;      koji ukazuju na nase prekidne rurine
;
; ==================================================

ALARM_POSITION_1 equ 60
ALARM_POSITION_2 equ 220
KBD equ 060h
SPACE equ 39h
COUNTDOWN_STATE equ 0
RINGING_STATE equ 1
FINISHED_STATE equ 2
NORMAL_COLOR equ 7ah
BLINKING_COLOR equ 0fah

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

snooze_handle:
	pusha
	cmp [cs:alarm_state], byte RINGING_STATE
	jne .exit_snooze

	in al, KBD
	cmp al, SPACE
	jne .exit_snooze
	inc byte [cs:arg_time_m]
	mov [cs:alarm_state], byte COUNTDOWN_STATE
	cmp [cs:arg_time_m], byte 60
	jne .skip_carry_snooze
	inc byte [cs:arg_time_h]
	mov [cs:arg_time_m], byte 0

	.skip_carry_snooze:
	; hehe


.exit_snooze:
	popa
	push word [cs:old_09h_seg]
	push word [cs:old_09h_off]
	retf


; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
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

; Vratiti stari vektor prekida 0x1C
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


timer_int:
	mov ax, [cs:INdos_seg]
	mov es, ax
	mov bx, [cs:INdos_off]
	cmp [es:bx], byte 0
	jne _exit

	cmp [cs:alarm_state], byte FINISHED_STATE
	je _exit

    push cs
    pop ds


	cmp [alarm_state], byte COUNTDOWN_STATE
	jne _alarm_branch

	mov [counter], byte 183



	pusha
    mov ah, 2Ch
    int 21h

	cmp [arg_time_h], ch
	jne .not_equal

	cmp [arg_time_m], cl
	jne .not_equal

	cmp [arg_time_s], dh
	jne .not_equal

	mov [alarm_state], byte RINGING_STATE



.not_equal:


    mov al, [arg_time_h]
    sub al, ch
    mov [diff_time_h], al

    mov al, [arg_time_m]
    cmp al, cl
    jge .skip_carry_m
    dec byte [diff_time_h]
    add al, 60


.skip_carry_m:
    sub al, cl
    mov [diff_time_m], al

    mov al, [arg_time_s]
    cmp al, dh
    jge .skip_carry_s
    dec byte [diff_time_m]
    add al, 60

.skip_carry_s:
    sub al, dh
    mov [diff_time_s], al

    mov si, printing_string
    mov ah, 0
    mov al, [arg_time_h]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah
    inc si

    mov [si], byte ':'

    inc si

    mov ah, 0
    mov al, [arg_time_m]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah
    inc si

    mov [si], byte ':'

    inc si

    mov ah, 0
    mov al, [arg_time_s]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah

    mov si, printing_string
    mov bx, ALARM_POSITION_1
	mov cl, NORMAL_COLOR

    call _print_to_video_seg


	mov si, printing_string
    mov ah, 0
    mov al, [diff_time_h]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah
    inc si

    mov [si], byte ':'

    inc si

    mov ah, 0
    mov al, [diff_time_m]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah
    inc si

    mov [si], byte ':'

    inc si

    mov ah, 0
    mov al, [diff_time_s]
    mov bl, 10
    div bl

    add ax, 3030h

    mov [si], al
    inc si
    mov [si], ah

    mov si, printing_string
    mov bx, ALARM_POSITION_2
	mov cl, NORMAL_COLOR

    call _print_to_video_seg



    popa
_exit:
	iret

_alarm_branch:
	mov bx, ALARM_POSITION_1
	mov si, alarm_message
	mov cl, BLINKING_COLOR

	call _print_to_video_seg

	mov bx, ALARM_POSITION_2
	mov si, alarm_message
	mov cl, BLINKING_COLOR
	call _print_to_video_seg

	dec byte [counter]
	cmp byte [counter], 0
	je i_ran_out_of_exit_labels

	iret


i_ran_out_of_exit_labels:
	mov [alarm_state], byte FINISHED_STATE
	mov si, spacez
	mov bx, ALARM_POSITION_1
	xor cl, cl
	call _print_to_video_seg

	mov si, spacez
	mov bx, ALARM_POSITION_2
	xor cl, cl
	call _print_to_video_seg
	; jmp _stop_prog

	iret


_print_to_video_seg:
    mov ax, 0B800h
    mov es, ax
.repeat:
    mov al, [si]
	; mov ah, 0eh
	; int 10h
    cmp al, 0
    je .exit_print
    mov [es:bx], al
    inc bx
    mov [es:bx], cl
    inc bx
    inc si
    jmp .repeat

.exit_print:
    ret

MyInt2F:
	cmp 	[cs:alarm_state], byte FINISHED_STATE
	je idemo_dalje
    cmp     ah, [cs:function_id]   ;Is this call for us?
    je      ItsUs

idemo_dalje:
	push word [cs:old_2fh_seg]
	push word [cs:old_2fh_off]
	retf

ItsUs:
	cmp al, 0
	jne idemo_dalje
	mov al, 0FFh
	mov di, string_id_2f
	mov dx, cs
	mov es, dx
	iret



segment .data

old_int_seg: dw 0
old_int_off: dw 0
old_09h_seg: dw 0
old_09h_off: dw 0
old_2fh_seg: dw 0
old_2fh_off: dw 0
diff_time_h: db 0 ; razlika sata
diff_time_m: db 0 ; razlika minuta
diff_time_s: db 0 ; razlika sekunde
alarm_message: db 'ALARM!!1', 0
printing_string: times 9 db 0
counter: db 183
alarm_state: db 0
spacez: db '        ',0
function_id: db 0
string_id_2f: db 'MI SMO!1'
