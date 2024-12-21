.include "C:/devkitPro/examples/gba/mything/source/addresses.inc" //Contains addresses 
.include "C:/devkitPro/examples/gba/mything/source/trigonometry.inc" //Contains trigonometry stuff

.arm
.text
.global main

//#Registers to maintain:
//# r4 -> Page flip display buffer VRAM addr

main:
//#Sets R4 and R5
setup_displayRegister:
	//#Display Control Register Address
	mov r4, #DISPCNT_ADDR 
	mov r5, #DISPMODE_BASE
	add r5, #4 //# +4 for display mode 4
	str r5, [r4]
	ldr r4, = 0x6000000 //#Page flip addr 
	
//#Uses R0, R1, R2 and R3.
setup_colorPalette:
	//#Load and setup the color palette
	mov r0, #PALETTE_ADDR
	ldr r1, =PALETTE_DATA
	mov r2, #5 //#Number of palette entries
		setup_colorPalette_copyPalette:
			ldrh r3, [r1], #2 //Load the color and cycle to the next one
			strh r3, [r0], #2 //Store the code in the palette memory
			subs r2, r2, #1
			bne setup_colorPalette_copyPalette
			
setup_Interruption:
	//Enable interruptions in CPU
	ldr r0, =REG_IME
	mov r1, #0x1
	str r1, [r0]
	
	ldr r0, =REG_IE
			 //FEDCBA9876543210
	ldr r1, =0b0000000000000001
	str r1, [r0]
	
	//BIOS interrupt function
	ldr r0, =0x3007FFC 
	ldr r1, =Interrupt_handler
	str r1, [r0]
	
	//Enable VBlank interrupt
	ldr r0, =REG_DISPSTAT
	mov r1, #8
	str r1, [r0]
	
infin:
	b infin
		
		
Interrupt_handler:
	push {r4, lr} //Push return address
	//Clear VBlank interruption
	ldr r0, =REG_IF
	ldr r1, =0b0000000000000001
	strh r1, [r0]

	mov r1, #DISPCNT_ADDR 
	ldr r0, [r1] //#Load value of DISPCNT
	eor r0, r0, #0x1000 //Toogle the 12th bit
	str r0, [r1] //#Store value back in DISPCNT
	eor r4, r4, #0xA00000 //#Toogle the 'A'
	bl Graphics_draw
	

	endISR:	
		pop {r4, lr}
		subs pc, lr, #4 //Return from interrupt
		
		
Graphics_draw:
	bl Graphics_background	

	mov r0, #80
	mov r1, #100
	mov r2, #50
	mov r3, #50
	bl Line	
	
	mov r0, #50
	mov r1, #50
	mov r2, #100
	mov r3, #70
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #100
	mov r3, #30
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #70
	mov r3, #2
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #30
	mov r3, #2
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #10
	mov r3, #30
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #10
	mov r3, #70
	bl Line
	
	mov r0, #50
	mov r1, #50
	mov r2, #30
	mov r3, #100
	bl Line
	
	subs r9, r2, r0 //(x2-x1)
	rsbmi r11, r9, #0
	subs r10, r3, r1 //(y2-y1)
	rsbmi r12, r10, #0
	

	bx lr

//#Draws the background before drawing anything else
//#REGISTERS: Constant r4, Temp r0, r1, r2
Graphics_background:
	mov r0, r4 //#Load address of the buffer VRAM
	mov r1, #4 @Color index //#Load background colour
	ldr r2, =0x9600 //#Amount of write operations for screen
	
	Graphics_background_loop:
		strb r1, [r0], #1 //#Almacena el valor del color en la VRAM
		subs r2, r2, #1 //#Compare with 0 after substracting
		bne Graphics_background_loop
	bx lr
	

//We need a function to actually draw a pixel in a position!
// r0(X), r1(Y), r2(Color Index)
Pixel:
	 //( (Y * M4_WIDTH) + X) / 2
	 ldr r3, =240
	 mul r1, r3
	 add r1, r0
	 //lsr r1, r1, #1
	 
	 mov r3, r4 //Load VRAM addr
	 add r3, r1
	 
	 //if X is even or odd
	 and r0, r0, #1
	 cmp r0, #0
	 beq PixelLeft
	
	PixelRight:
		sub r3, #1
		ldrh r1, [r3]
		and r1, r1, #0x00FF
		lsl r2, r2, #8
		orr r1, r2, r1
		b PixelEnd
	PixelLeft:
		ldrh r1, [r3]
		and r1, r1, #0xFF00
		orr r1, r2, r1
	PixelEnd:
	strh r1, [r3]
bx lr	


//Parameters
//r0 -> X1
//r1 -> Y1
//r2 -> X2
//r3 -> Y2

//Bresenham Line Generation Algorithm
Line:
	push {r5-r12}

	subs r11, r2, r0 //(x2-x1)
	rsbmi r11, r11, #0
	subs r12, r3, r1 //(y2-y1)
	rsbmi r12, r12, #0
	
	cmp r12, r11 //if abs(y1 - y0) < abs(x1 - x0)
	bge Line_High
	b Line_Low
	
	pop {r5-r12}
	bx lr

Line_High:
	cmp r1, r3
	movgt r5, r2 //a1 (Reverse)
	movgt r6, r3 //b1
	movgt r7, r0 //a2
	movgt r8, r1 //b2
	
	movle r5, r0 //a1 (Dont reverse)
	movle r6, r1 //b1
	movle r7, r2 //a2
	movle r8, r3 //b2
	
	sub r9, r7, r5 //(x2-x1) 							dx = x1-x0
	sub r10, r8, r6 //(y2-y1) 							y1 - y0
	
	cmp r9, #0										//  if dx < 0
	movlt r12, #-1									//  xi = -1
	rsbmi r9, r9, #0								//  dx = -dx
	movge r12, #1
	
	lsl r11, r9, #1 //(2*dx)
	sub r11, r11, r10 //(2*dx) - dy					// D = (2 * dx) - dy
	
	Line_HighLoop:
		mov r0, r5
		mov r1, r6
		mov r2, #2
		push {lr}
		bl Pixel
		pop {lr}

		cmp r11, #0									// if D > 0
		addgt r5, r5, r12							// x = x + xi
		subgt r1, r9, r10							// D = D + (2*(dx-dy))
		lslgt r1, r1, #1							
		addgt r11, r11, r1
		
		lslle r1, r9, #1							// else
		addle r11, r11, r1							// D = D + 2*dx
	
		cmp r6, r8 //is y1 == y2
		add r6, #1 //y++							// for y from y0 to y1
		ble Line_HighLoop
		
	pop {r5-r12}
	bx lr
	
Line_Low:
	cmp r0, r2
	movgt r5, r2 //a1 (Reverse)
	movgt r6, r3 //b1
	movgt r7, r0 //a2
	movgt r8, r1 //b2
	
	movle r5, r0 //a1 (Dont reverse)
	movle r6, r1 //b1
	movle r7, r2 //a2
	movle r8, r3 //b2
	
	sub r9, r7, r5 //dx = x1-x0
	sub r10, r8, r6 //dy = y1-y0
	
	cmp r10, #0	//if dy  0 
	movlt r12, #-1 //yi = -1
	rsblt r10, r10, #0 //dy = -dy
	movge r12, #1 //else yi = 1
	
	lsl r11, r10, #1 //(2*dy)
	sub r11, r11, r9 // D = (2 * dy) - dx
	
	Line_LowLoop:
		mov r0, r5
		mov r1, r6
		mov r2, #2
		push {lr}
		bl Pixel
		pop {lr}
		
		add r5, #1
		
		cmp r11, #0 //if D > 0
		addgt r6, r6, r12 //y = y + y1
		subgt r1, r10, r9 //(dy - dx)
		lslgt r1, r1, #1 // 2*(dy-dx)
		addgt r11, r11, r1 //D = D + (2*(dy-dx))
		//else
		//lslle r1, r10, #1
		addle r11, r11, r10, lsl #1
		
		cmp r5, r7
		ble Line_LowLoop
	
pop {r5-r12}
bx lr
