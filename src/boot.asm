[BITS 16]
[ORG 0x7C00]

.hello_world: 
  xor ax, ax
  mov ds, ax
  mov es, ax  
  mov ax, 0x50
  mov ss, ax
  mov sp, 0x7C0
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

