# Build the BIOS part using Merlin32

Basic.bin: Basic.s
	Merlin32 -V /usr/local/includes/merlin32 Basic.s
	#srec_cat Init.bin -Binary Serial.bin -Binary -offset 0x0f00 Vectors.bin -Binary -offset 0x0ffa -Output BIOS.bin -Binary --address-length=2 


clean: 
	rm *.txt *.bin *.hex *.c
