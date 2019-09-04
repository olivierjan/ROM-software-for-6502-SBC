##### Build full ROM image

ASM=Merlin32
ASMFLAGS=-V /usr/local/includes/merlin32
LNK=/usr/local/bin/srec_cat
ROMNAME=JAVA1
EXEC=$(ROMNAME).bin


all: $(EXEC)

$(EXEC): ROM.s
	$(ASM) $(ASMFLAGS) ROM.s
	$(LNK) $(EXEC) -Binary  -Output $(ROMNAME).hex -Intel --address-length=2 


clean: 
	$(RM) *.txt *.bin *.hex

