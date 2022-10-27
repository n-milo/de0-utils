# Example program using button and timer interrupts


	.text		# start a code segment (and we will also have data in it)

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# Define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

# mask/edge registers for pushbutton parallel port

	.equ	BUTTON_MASK, 0x10000058
	.equ	BUTTON_EDGE, 0x1000005C

# pattern corresponding to the bit assigned to button1 in the registers above

	.equ	BUTTON1, 0b0010

# data register for LED parallel port

	.equ	LEDS, 0x10000010
	
.equ JTAG_UART_BASE,    0x10001000  # base address for the JTAG UART interface
.equ DATA_OFFSET,       0           # data regsiter is at base+0
.equ STATUS_OFFSET,     4           # status register is at base+4
.equ WSPACE_MASK,       0xFFFF      # WSPACE is held in the top 16 bits of the control register

	.equ TIMER_STATUS,	0x10002000
	.equ TIMER_CONTROL,	0x10002004
	.equ TIMER_START_LO,	0x10002008
	.equ TIMER_START_HI,	0x1000200C

#-----------------------------------------------------------------------------
# Define two branch instructions in specific locations at the start of memory
#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			#   (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------
# The actual program code (incl. service routine) can be placed immediately
# after the second branch above, or another .org directive could be used
# to place the program code at a desired address (e.g., 0x0080). It does not
# matter because the _start symbol defines where execution begins, and the
# branch at that location simply forces execution to continue where desired.
#-----------------------------------------------------------------------------

main:
	movia sp, 0x007FFFFC		# initialize stack pointer

	call Init		# call hw/sw initialization subroutine
	
	movia	r3, TIMER_START_HI
	movi	r2, 0x017D
	stwio	r2, 0(r3)
	
	movia	r3, TIMER_START_LO
	movi	r2, 0x7840
	stwio	r2, 0(r3)
	
	movia	r3, TIMER_CONTROL
	movi	r2, 0b0111
	stwio	r2, 0(r3)
	

main_loop:

	ldw		r2, COUNT(r0)
	addi	r2, r2, 1
	stw		r2, COUNT(r0)

	br main_loop

#-----------------------------------------------------------------------------
# This subroutine should encompass preparation of I/O registers as well as
# special processor registers for recognition and processing of interrupt
# requests. Initialization of data variables in memory can also be done here.
#-----------------------------------------------------------------------------

Init:				# make it modular -- save/restore registers
	subi	sp, sp, 8
	stw		r2, 0(sp)
	stw		r3, 4(sp)

	movia	r2, BUTTON_MASK
	movi	r3, BUTTON1
	stwio	r3, 0(r2)
	
	movi	r3, 0b011
	wrctl	ienable, r3
	movi 	r3, 1
	wrctl	status, r3
	
	ldw		r2, 0(sp)
	ldw		r3, 4(sp)
	addi	sp, sp, 8
	ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below. Therefore,
# the actual code for this routine can be anywhere in memory for convenience.
# This template involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
# Programs with software-generated interrupts must check for hardware sources
# to conditionally adjust the ea register (no adjustment for s/w interrupts).
#-----------------------------------------------------------------------------

isr:
	subi	sp, sp, 12	# body of interrupt service routine
	stw		ra, 8(sp)
	stw		r2, 4(sp)			#   (use the proper approach for checking
	stw		r3, 0(sp)				#    the different interrupt sources)
	
	subi	ea, ea, 4	# ea adjustment required for h/w interrupts

	rdctl	r2, ipending
	
	andi	r3, r2, 2
	beq		r3, r0, not_button_isr
	call	button_isr
not_button_isr:

	andi	r3, r2, 1
	beq		r3, r0, not_timer_isr
	call	timer_isr
not_timer_isr:
	

	ldw		ra, 8(sp)
	ldw		r2, 4(sp)
	ldw		r3, 0(sp)
	addi	sp, sp, 12
	
	eret			# interrupt service routines end _differently_
				#   than subroutines; execution must return to
				#   to point in main program where interrupt
				#   request invoked service routine
				
button_isr:
	subi	sp, sp, 8
	stw		r2, 4(sp)
	stw		r3, 0(sp)
	
	movia	r3, LEDS
	ldwio	r2, 0(r3)
	xori	r2, r2, 1
	stwio	r2, 0(r3)
	
	movi	r2, 2
	movia	r3, BUTTON_EDGE
	stwio	r2, 0(r3)
	
	ldw		r2, 4(sp)
	ldw		r3, 0(sp)
	addi	sp, sp, 8
	ret
	
	
	
	
timer_isr:
	subi	sp, sp, 12
	stw		ra, 8(sp)
	stw		r2, 4(sp)
	stw		r3, 0(sp)
	
	movia	r3, TIMER_STATUS
	stwio	r0, 0(r3)
	
	movia	r3, LEDS
	ldwio	r2, 0(r3)
	xori	r2, r2, 0b11111000
	stwio	r2, 0(r3)
	
	andi	r2, r2, 0b10000000
	call	TickOrTock
	
	ldw		ra, 8(sp)
	ldw		r2, 4(sp)
	ldw		r3, 0(sp)
	addi	sp, sp, 12
	ret

	

PrintChar:
    subi    sp, sp, 8
    stw     r3, 4(sp)
    stw     r4, 0(sp)
    movia   r3, JTAG_UART_BASE
pc_loop:
    ldwio   r4, STATUS_OFFSET(r3)
    andhi   r4, r4, WSPACE_MASK
    beq     r4, r0, pc_loop
    stwio   r2, DATA_OFFSET(r3)
    ldw     r4, 0(sp)
    ldw     r3, 4(sp)
    addi    sp, sp, 8
    ret
	
PrintString:
	subi	sp, sp, 12
	stw		ra, 8(sp)
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	
	mov		r4, r2
ps_loop:
	ldb		r2, 0(r4)
	beq		r2, r0, ps_end_loop
	call	PrintChar
	addi	r4, r4, 1
	br		ps_loop
ps_end_loop:
	ldw		ra, 8(sp)
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 12
	ret
	
	
TickOrTock:
	subi	sp, sp, 12
	stw		ra, 8(sp)
	stw		r2, 4(sp)
	stw		r3, 0(sp)
	
	mov		r3, r2
	
	movi	r2, 't'
	call	PrintChar
	
tot_if:
	bne		r3, r0, tot_else
tot_then:
	movi	r2, 'i'
	br		tot_endif
tot_else:
	movi	r2, 'o'
tot_endif:

	call	PrintChar
	
	movi	r2, 'c'
	call	PrintChar
	movi	r2, 'k'
	call	PrintChar
	movi	r2, '\n'
	call	PrintChar
	
	ldw		r3, 0(sp)
	ldw		r2, 4(sp)
	ldw		ra, 8(sp)
	addi	sp, sp, 12
	ret
	
	
	
#-----------------------------------------------------------------------------
# Definitions for program data, incl. anything shared between main/isr code
#-----------------------------------------------------------------------------

	.org	0x1000		# start should be fine for most small programs
				
COUNT: .word 0
TEXT: .asciz "hello"
TICK_OR_TOCK: .asciz "t ck\b\b\b"

	.end
