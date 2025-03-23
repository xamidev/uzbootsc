ASM = nasm
ASMFLAGS = -f bin -o

EMU = qemu-system-x86_64
EMUFLAGS = -monitor stdio -drive format=raw,file=


all: boot uz disk

boot:
	$(ASM) boot.s $(ASMFLAGS) boot.bin

uz:
	$(ASM) uz.s $(ASMFLAGS) uz.bin

disk:
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=uz.bin of=disk.img bs=512 seek=1 conv=notrunc

run:
	$(EMU) $(EMUFLAGS)disk.img

clean:
	rm *.bin *.img
