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




timer_int:
	pusha

	; Posto imamo ucitano vreme iz 28h, ako se desio prekid, samo cemo ucitati u
	; vreme koje cemo koristiti pri izracunavanju vremena razlike, i vreme ispisa.
	mov ch, [cs:system_time_h]
	mov cl, [cs:system_time_m]
	mov dh, [cs:system_time_s]
	mov ax, [cs:INdos_seg]
	mov es, ax
	mov bx, [cs:INdos_off]
	cmp [es:bx], byte 0
	; u slucaju da je u toku sistemski poziv,
	; preskacemo 21h i citamo stare vrednosti ucitane u memoriji
	jne _skip_21h

  mov ah, 2Ch
  int 21h

_skip_21h:
	cmp [cs:alarm_state], byte FINISHED_STATE
	je _exit

	push cs
	pop ds


	cmp [alarm_state], byte COUNTDOWN_STATE
	jne _alarm_branch

	mov [counter], byte 183

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




_exit:
		popa
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

	popa
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
	popa
	iret




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


My28h:
	cmp [cs:alarm_state], byte FINISHED_STATE
	je skip_28h
	pusha

	mov ah, 2ch
	int 21h
	mov [cs:system_time_h], ch
	mov [cs:system_time_m], cl
	mov [cs:system_time_s], dh


	popa
skip_28h:
	push word [cs:old_28h_seg]
	push word [cs:old_28h_off]
	retf

%include "prints.asm"

segment .data

system_time_h: db 0
system_time_m: db 0
system_time_s: db 0
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
