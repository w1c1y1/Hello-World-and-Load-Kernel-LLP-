ASM = nasm
QEMU = qemu-system-i386

SRC = boot.asm
BIN = boot.bin
PAYLOAD = kernel_code.txt
IMG = boot.img

QEMU_FLAGS = -cpu pentium2 -m 1g -fda $(IMG) -monitor stdio -device VGA
BUILD_FLAGS = -fbin $(SRC) -o $(BIN)

all: clean run

$(BIN): $(SRC)
		$(ASM) $(BUILD_FLAGS)

$(IMG): $(BIN) $(PAYLOAD)
		dd if=/dev/zero of=$(IMG) bs=1024 count=1440
		dd if=$(BIN) of=$(IMG) conv=notrunc
		dd if=$(PAYLOAD) of=$(IMG) conv=notrunc seek=1

run: $(IMG)
	 $(QEMU) $(QEMU_FLAGS)
	
clean:
	rm -f $(BIN) $(IMG)