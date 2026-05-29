[BITS 16]
[ORG 0]

.hello_world:
  mov ax, 0x07C0
  mov ds, ax
  mov es, ax  
  mov ax, 0x0500
  mov ss, ax
  mov sp, 0x07C0
  mov bx, msg
  .printing:
    mov al, byte [bx]
    cmp al, 0
    je loop
    mov ah, 0x0E
    int 0x10
    inc bx
    jmp .printing


msg: db "Hello, World!", 0x0A, 0x0D, 0


loop:
  jmp loop

times 510-($-$$) db 0
dw 0xAA55

