##### Build full ROM image

ASM=Merlin32
ASMFLAGS=-V /usr/local/includes/merlin32
LNK=/usr/local/bin/srec_cat
ROMNAME=OJROM
EXEC=$(ROMNAME).bin


all: $(EXEC)

rom_nobasic: BIOS.bin MONITOR.bin
	$(LNK) Monitor/Monitor.bin -Binary -offset 0x1900 \
	BIOS/BIOS.bin -Binary -offset 0x3D00  \
	-Output $(EXEC) -Binary --address-length=2 

$(EXEC): BASIC.bin MONITOR.bin BIOS.bin
	$(LNK) BASIC/Basic.bin -Binary \
	Monitor/Monitor.bin -Binary -offset 0x2900 \
	BIOS/BIOS.bin -Binary -offset 0x4D00  \
	-Output $(EXEC) -Binary --address-length=2 
	$(LNK) $(EXEC) -Binary  -Output $(ROMNAME).hex -Intel --address-length=2 

BIOS.bin:
	(cd BIOS ; make)

MONITOR.bin:
	(cd Monitor ; make)

BASIC.bin:
	(cd BASIC ; make )

clean: 
	$(RM) BASIC/*.txt BASIC/*.bin BIOS/*.txt BIOS/*.bin Monitor/*.txt Monitor/*.bin *.bin *.hex

