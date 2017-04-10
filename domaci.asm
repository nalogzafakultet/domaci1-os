org 100h

segment .code

_main:
        cld
        mov     cx, 0080h                   ; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
        mov     di, 81h                     ; Pocetak komandne linije u PSP.
        mov     al, ' '                     ; String uvek pocinje praznim mestom (razmak izmedju komande i parametra)
repe    scasb                               ; Trazimo prvo mesto koje nije prazno (tada DI pokazuje na lokaciju iza njega)
        dec di
        mov dx, di
        mov si, start_str
        mov cx, 6
repe    cmpsb
        je _start_prog

        mov di, dx
        mov si, stop_str
        mov cx, 5
repe    cmpsb
        je _stop_prog

print_error:
        mov dx, error_string
        mov ah, 09h
        int 21h
        ret






_start_prog:
    ; mov ah, 0eh
    ; mov al, 'A'
    ; int 10h
    ; ret



    ; ---------------
    ; PARSIRANJE sata
    ; ---------------
    inc di
    mov al, [di]
    sub al, 30h
    mov bl, 10
    mul bl

    inc di
    add al, [di]
    sub al, 30h
    cmp al, 23
    jg print_error

    mov [arg_time_h], al


    inc di
    cmp byte [di], ':'
    jne print_error


    ; ---------------
    ; PARSIRANJE minuta
    ; ---------------



    inc di

    mov al, [di]
    sub al, 30h
    mov bl, 10
    mul bl

    inc di
    add al, [di]
    sub al, 30h
    cmp al, 59
    jg print_error
    mov [arg_time_m], al

    inc di
    cmp byte [di], ':'
    jne print_error

    ; ---------------
    ; PARSIRANJE sekunde
    ; ---------------

    inc di

    mov al, [di]
    sub al, 30h
    mov bl, 10
    mul bl

    inc di
    add al, [di]
    sub al, 30h
    cmp al, 59
    jg print_error
    mov [arg_time_s], al

    call _novi_1C
    call _novi_09

    ret

_stop_prog:
    mov ah, 0eh
    mov al, 'B'
    int 10h
    ret




%include "inter.asm"


segment .data

start_str: db '-start'
stop_str: db  '-stop'
error_string: db 'Nisu dobro podeseni argumenti komandne linije$'
arg_time_h: db 0 ; dati sati alarma
arg_time_m: db 0 ; dati minuti alarma
arg_time_s: db 0 ; date sekunde alarma
