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

    ; -----------
    ; CHECK 2Fh
    ; -----------

    mov [free_function_id], byte 0
    mov cx, 0FFh
search_loop:
    mov ah, cl
    push cx
    mov al, 0
    int 2fh
    pop cx


    cmp al, 0
    je TryNext
    mov si, string_id_2f
    push cx
    mov cx, 8
    repe cmpsb
    pop cx
    je AlreadyThur
    loop search_loop
    jmp Not_Install3d

    ret

_stop_prog:
    ; mov al, '$'
    ; mov ah, 0eh
    ; int 10h
    mov cx, 0FFh
.search_loop:
    mov ah, cl
    push cx
    mov al, 0
    int 2fh
    pop cx
    cmp al, 0
    je .try_next
    mov si, string_id_2f
    push cx
    mov cx, 8
    repe cmpsb
    pop cx
    je .already_there
.try_next:
    loop .search_loop
    jmp .not_installed

.not_installed:
    mov dx, uninstalling_string
    mov ah, 09h
    int 21h
    ret

.already_there:
    push ds
    push es
    pop ds

    call _stari_2f
    call _stari_1C
    call _stari_09
    pop ds
    ret


TryNext:
    mov [free_function_id], cl
    loop search_loop
    jmp Not_Install3d

AlreadyThur:
    mov dx, tsr_already_installed_string
    mov ah, 09h
    int 21h
    ret

Not_Install3d:
    cmp [free_function_id], byte 0
    jne GoodID
    mov dx, too_many_tsrs
    mov ah, 09h
    int 21h
    ret

GoodID:
    mov ah, [free_function_id]
    mov [function_id], ah
    call _novi_2f
    call _novi_1C
    call _novi_09
    mov ah, 31h
    mov dx, 0FFh
    int 21h


%include "inter.asm"


segment .data


arg_time_h: db 0 ; dati sati alarma
arg_time_m: db 0 ; dati minuti alarma
arg_time_s: db 0 ; date sekunde alarma
free_function_id: db 0
tsr_already_installed_string: db 'Jedna instanca TSR-a je vec pokrenuta.$'
too_many_tsrs: db 'Preveliki broj instanci TSR-ova je pokrenut, gospodine Milojkovicu.$'
uninstalling_string: db 'Ne mozemo uninstallirati TSR, jer ga nema.$'
start_str: db '-start'
stop_str: db  '-stop'
error_string: db 'Nisu dobro podeseni argumenti komandne linije$'
