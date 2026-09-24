[BITS 16]
[ORG 0x7C00]

%define CODE_OFFSET 0x7C00    ; defining magic consts
%define HEADS 2
%define SECTORS_PER_TRACK 18
%define SECTORS_TO_READ 26
%define SECTOR_SIZE 512
%define KERNEL_OFFSET 0x7E00
%define READ_SECTORS 0x2


.segment_placing:
  cli
  xor ax, ax
  mov ds, ax
  mov es, ax  
  mov ss, ax
  mov sp, CODE_OFFSET
  sti

.start_sector_placing:       ; int 0x13 args to default 
  mov cl, 2
  xor ch, ch
  xor dh, dh
  mov bx, KERNEL_OFFSET      ; points to data we read
  mov si, SECTORS_TO_READ    ; counts how much sectors were read
  

.reading_loop:
  cmp si, 0                  ; if all read, then exit 
  je infinite_loop
  mov ah, READ_SECTORS       ; number of read from drive command
  mov al, 1                  ; read one sector at time
  int 0x13                   ; reading service
  jc disk_reading_error
  dec si                     ; sector read
  add bx, SECTOR_SIZE        ; move to next sector
  jnc .no_segment_overflow   ; if bx > 64kb => overflow and we need to move ES on 0x1000 = 64kb
    push ax                  ; save ax
    mov ax, es               ; move es to ax for change
    add ax, 0x1000           ; move ax to 64kb further
    mov es, ax               ; rewrite es
    pop ax                   ; bring back the old ax value
  .no_segment_overflow:
    call move_sector        ; if all good, move to the next sector
    jmp .reading_loop        ; and read again


move_sector:
  inc cl                     ; increment sector
  cmp cl, SECTORS_PER_TRACK + 1        ; if less than 18 + 1, just pass
  jne .pass
  mov cl, 1

  inc dh                     ; increment track
  cmp dh, HEADS              ; if less, pass
  jne .pass
  mov dh, 0

  inc ch                     ; go to next track
  .pass:
    ret


disk_reading_error:
  mov bx, error_msg
  jmp printing

infinite_loop:
  jmp infinite_loop



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

