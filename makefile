<<<<<<< HEAD
EMU=qemu-system-i386
ASM=nasm
ASM_SOURCES=boot.asm

all:
	$(ASM) $(ASM_SOURCES) -f bin -o boot.bin

run:
	$(EMU) -fda boot.bin

clean:
	rm -rf *.o *.bin *.out
=======
ASM = nasm
ASMFLAGS = -f bin -o

EMU = qemu-system-x86_64
EMUFLAGS = -monitor stdio -drive format=raw,file=


all: boot stage2 disk

boot:
	$(ASM) boot.s $(ASMFLAGS) boot.bin

stage2:
	$(ASM) stage2.s $(ASMFLAGS) stage2.bin

disk:
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=stage2.bin of=disk.img bs=512 seek=1 conv=notrunc

run:
	$(EMU) $(EMUFLAGS)disk.img

clean:
	rm *.bin *.img
>>>>>>> b862f57 (add stuff)
