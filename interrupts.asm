segment .code

_install_1c:
  cli

  ; cuvanje starog interrupta
  xor ax, ax
  mov es, ax
  mov bx, [es:01ch*4]
  mov [old_int_off], bx
  mov bx, [es:01ch*4+2]
  mov [old_int_seg], bx

  ; postavljanje novog handlera za 1c

  mov dx, new_1c
  mov [es:01ch*4], dx
  mov ax, cs
  mov [es:01ch*4], ax

  sti
  ret

_uninstall_1c:

  cli
  xor ax, ax
  mov es, ax
  mov ax, old_int_off
  mov [es:01ch*4], ax
  mov dx, old_int_seg
  mov [es:01ch*4+2], dx
  sti
  ret


new_1c:




old 1c_seg: dw 0
old 1c_off: dw 0
