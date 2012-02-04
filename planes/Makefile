
.SUFFIXES = .s .c
TARGET = planes
OBJS = \
	$(TARGET).o



all: $(TARGET).bin

clean:
	-rm -f $(TARGET).bin $(TARGET).elf $(OBJS) *.bin romdisk.*
	rm -f *~
	rm -f data.h

$(TARGET).elf: $(OBJS)
	sh-elf-ld -EL --oformat elf32-shl -Ttext 0x8c010000 $(OBJS) -o $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	sh-elf-objcopy -S -R .stack -O binary $(TARGET).elf $(TARGET).bin
	wc -c $(TARGET).bin



.s.o:
	sh-elf-as -small -little -small --warn $< -o $@

