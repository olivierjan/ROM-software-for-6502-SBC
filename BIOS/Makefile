# Build the BIOS part using Merlin32
ASM=Merlin32
ASMFLAGS=-V /usr/local/includes/merlin32
LNK=/usr/local/bin/srec_cat


BIOS: Init.s Serial.s Vectors.s
	$(ASM) $(ASMFLAGS) BIOS.S
	$(LNK) Init.bin -Binary Serial.bin -Binary -offset 0x0100 Vectors.bin -Binary -offset 0x02fa -Output BIOS.bin -Binary --address-length=2 


clean: 
	rm *.txt *.bin *.hex *.c
