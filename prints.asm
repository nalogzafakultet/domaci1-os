segment .code

_print_to_video_seg:
    mov ax, 0B800h
    mov es, ax
.repeat:
    mov al, [si]
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
