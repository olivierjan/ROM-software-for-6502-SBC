##### Build full ROM image

rom_nobasic: BIOS/BIOS.bin Monitor/Monitor.bin
	srec_cat Monitor/Monitor.bin -Binary -offset 0x1900 BIOS/BIOS.bin -Binary -offset 0x3D00  -Output OJROM.bin -Binary --address-length=2 

rom: BIOS/BIOS.bin Monitor/Monitor.bin BASIC/Basic.bin
	srec_cat BASIC/Basic.bin -Binary Monitor/Monitor.bin -Binary -offset 0x2900 BIOS/BIOS.bin -Binary -offset 0x4D00  -Output OJROM.bin -Binary --address-length=2 
	srec_cat OJROM.bin -Binary -offset 0xD900  -Output OJROM.hex -Intel --address-length=2 

BIOS/BIOS.bin:
	(cd BIOS ; make)

Monitor/Monitor.bin:
	(cd Monitor ; make)

BASIC/Basic.bin:
	(cd BASIC ; make )

clean: 
	$(RM) BASIC/*.txt BASIC/*.bin BIOS/*.txt BIOS/*.bin Monitor/*.txt Monitor/*.bin *.bin *.hex

