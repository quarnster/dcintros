
.SUFFIXES = .s .c
TARGET = 256b
CFLAGS = -Wall -ml -m4-single-only -Os -fno-builtin -fomit-frame-pointer
OBJS = \
	256b.o



all: $(TARGET).bin

clean:
	-rm -f $(TARGET).bin $(TARGET).srec $(OBJS) *.bin romdisk.*
	rm -f *~
	rm -f data.h

$(TARGET).srec: $(OBJS)
	sh-elf-ld -EL --oformat srec -Ttext 0x8c010000 $(OBJS) -o $(TARGET).srec

$(TARGET).bin: $(TARGET).srec
	sh-elf-objcopy -O binary $(TARGET).srec $(TARGET).bin
	wc -c $(TARGET).bin



.s.o:
	sh-elf-as -L -little -small $< -o $@

