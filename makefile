EMU=qemu-system-i386
ASM=nasm
ASM_SOURCES=boot.asm

all:
	$(ASM) $(ASM_SOURCES) -f bin -o boot.bin

run:
	$(EMU) -fda boot.bin

clean:
	rm -rf *.o *.bin *.out
