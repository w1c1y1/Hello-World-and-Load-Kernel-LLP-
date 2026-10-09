[BITS 16]

%ifndef PAYLOAD_SIZE
  %define PAYLOAD_SIZE 512
%endif
%define CODE_OFFSET 0x7C00    ; defining magic consts
%define HEADS 2
%define SECTORS_PER_TRACK 18
%define SECTOR_SIZE 512
%define KERNEL_OFFSET 0x7E00
%define READ_SECTORS 0x2
%define SECTORS_TO_READ ((PAYLOAD_SIZE + SECTOR_SIZE - 1) / SECTOR_SIZE)
%define CODE 0x08
%define DATA 0x10

section .boot
[GLOBAL booting]
booting:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax  
  mov ss, ax
  mov sp, CODE_OFFSET

  mov cl, 2                  ; start sector = 2
  xor ch, ch                 ; start cylinder = 0
  xor dh, dh                 ; start head = 0
  mov bx, KERNEL_OFFSET      ; points to data we read
  mov si, SECTORS_TO_READ    ; counts how much sectors were read
  

reading_loop:
  cmp si, 0                  ; if all read, then exit 
  je go_to_C
  mov ah, 0x2      ; number of read from drive command
  mov al, 1                  ; read one sector at time
  int 0x13                   ; reading service
  jc disk_reading_error
  dec si                     ; sector read
  mov di, es                ; move es to ax for change
  add di, 0x20              ; move ax to 64kb further
  mov es, di                ; rewrite es


move_sector:
  inc cl                     ; increment sector
  cmp cl, 19                 ; if less than 18 + 1, just pass
  jl reading_loop
  mov cl, 1

  inc dh                     ; increment head
  cmp dh, HEADS              ; if less, pass
  jl reading_loop
  mov dh, 0

  inc ch                     ; go to next cylinder
  jmp reading_loop

go_to_C:
  lgdt [gdt_descriptor]
  cld
  mov eax, CR0
  or eax, 1
  mov CR0, eax
  jmp CODE:next
  [BITS 32]
  next:
    mov ax, DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

  [EXTERN kernel_entry]
  call CODE:kernel_entry

  [GLOBAL endless_loop]
  endless_loop:
      jmp $


align 8
gdt:
  db 0, 0, 0, 0, 0, 0, 0, 0; null

  db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00; code

  db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00; data


gdt_descriptor:
  dw gdt_descriptor - gdt - 1
  dd gdt

[BITS 16]
infinite_loop:
  jmp infinite_loop

disk_reading_error:
  mov bx, error_msg
  jmp printing

printing:
  mov al, byte [bx]
  cmp al, 0
  je infinite_loop
  mov ah, 0x0E
  int 0x10
  inc bx
  jmp printing

error_msg: db "Reading error!!", 0x0A, 0x0D, 0
msg: db "Hello, World!", 0x0A, 0x0D, 0

times 510-($-$$) db 0
dw 0xAA55

