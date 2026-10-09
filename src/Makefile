ASM   = nasm
CC    = gcc
LD    = ld
OBJC  = objcopy
QEMU  = qemu-system-i386

SRC  = boot.asm
BOOT = boot.o
KSRC = kernel.c
KOBJ = kernel.o
LDS  = kernel.ld
ELF  = os.elf
BIN  = os.bin
IMG  = boot.img
RES  = bar

CFLAGS     = -m32 -std=c99 -ffreestanding -fno-pic -fno-stack-protector \
             -fno-builtin -nostdlib -nostdinc -O2 -Wall -Wextra
ASMFLAGS   = -f elf32
LDFLAGS    = -m elf_i386 -T $(LDS) -nostdlib
OCFLAGS    = -O binary
QEMU_FLAGS = -m 128 -fda $(IMG) -monitor stdio -no-reboot

.PHONY: all run dump clean

all: $(IMG)

$(BOOT): $(SRC)
	@$(ASM) $(ASMFLAGS) $(SRC) -o $(BOOT)

$(KOBJ): $(KSRC)
	@$(CC) $(CFLAGS) -c $(KSRC) -o $(KOBJ)

$(ELF): $(BOOT) $(KOBJ) $(LDS)
	@$(LD) $(LDFLAGS) $(BOOT) $(KOBJ) -o $(ELF)

$(BIN): $(ELF)
	@$(OBJC) $(OCFLAGS) $(ELF) $(BIN)

$(IMG): $(BIN)
	@dd if=/dev/zero of=$(IMG) bs=1024 count=1440 status=none
	@dd if=$(BIN) of=$(IMG) bs=512 conv=notrunc status=none

run: $(IMG)
	@$(QEMU) $(QEMU_FLAGS)

dump: $(IMG)
	@( sleep 3; echo "pmemsave 0x7E00 512 $(RES)"; echo "quit" ) | $(QEMU) $(QEMU_FLAGS)

clean:
	@rm -f $(BOOT) $(KOBJ) $(ELF) $(BIN) $(IMG) $(RES)