DISPCNT_ADDR = 0x4000000 //Address of the LCD screen controller.

DISPMODE_BASE = 0x400 //Base to change modes (+3 would be mode 3)

/*modes:
Mode3 -> is used for 2D graphics represented by a 16-bit value.
Each pixel takes up 2 bytes of memory.

240*160 = 38400 pixels => 76800 bytes
38400 16-bit writes (0x9600 is the hex representation of 38400)
*/

VRAM_ADDR = 0x6000000


REG_VCOUNT = 0x4000006 //Current horizontal scanline being drawn. 
//Since there are 160 lines. If VCOUNT > 160 it is in VBlank phase
//It is in DISPCNT_ADDR + 0x6, but it is probably used enough to have its own register.

//Interrupt Registers
REG_IE = 0x04000200 //Interrupt registered
REG_IF = 0x04000202 //Interrupt fired
REG_DISPSTAT = 0x04000004 //Interrupts for the display need to be registered here
REG_IME = 0x04000208 //Master interrupt controller


/*
//Funciones de la BIOS
swi 0x80000 SWI number 8 is SQRT of r0 and put result in r0
SWI number * 0x10000 or <<16

Division is SWI number 6
r0 is signed number
r1 is signed number to divide r0 by
output will be 
r0 = r0/r1
r1 = r0 MOD r1 (Remainder)
r3 = Absolute value of r0
*/
//COLORS AND PALETTE FOR 8BIT
PALETTE_ADDR = 0x5000000 //Address for the color palette

COLOR_GREEN = 0x07E0
COLOR_RED = 0x00F8
COLOR_BLUE = 0x7C00
COLOR_WHITE = 0xFFFF
COLOR_BLACK = 0x0000

.section .data
	PALETTE_DATA:
		.hword COLOR_GREEN 
		.hword COLOR_RED
		.hword COLOR_BLUE
		.hword COLOR_WHITE
		.hword COLOR_BLACK


