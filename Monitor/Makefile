# Uncomment one of the following lines to set your platform
PLATFORM=APPLE1
#PLATFORM=APPLE2
#PLATFORM=OSI
#PLATFORM=KIM1




jmon.bin:	jmon.s disasm.s miniasm.s trace.s info.s memtest4.s
	/usr/local/bin/Merlin32 -V /usr/local/includes/merlin32 jmon.s
	
clean:
	$(RM) *.txt *.bin

