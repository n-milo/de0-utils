# "Hello world!", PrintChar and PrintString functionality

.equ JTAG_UART_BASE,    0x10001000  # base address for the JTAG UART interface
.equ DATA_OFFSET,       0           # data regsiter is at base+0
.equ STATUS_OFFSET,     4           # status register is at base+4
.equ WSPACE_MASK,       0xFFFF      # WSPACE is held in the top 16 bits of the control register

.global _start



PrintChar:                          # PrintChar(ch): prints ch to the JTAG UART
	subi    sp, sp, 8               # init stack
	stw     r3, 4(sp)
	stw     r4, 0(sp)
	movia   r3, JTAG_UART_BASE      # r3 will hold the base address, for convenience
pc_loop:
	ldwio   r4, STATUS_OFFSET(r3)   # read the control register into r4
	andhi   r4, r4, WSPACE_MASK     # mask it to find the WSPACE value
	beq     r4, r0, pc_loop         # if WSPACE is 0, the data is not ready yet, jump and try again later
	stwio   r2, DATA_OFFSET(r3)     # otherwise, it is ready, write r2 to the data register
	ldw     r4, 0(sp)               # restore stack
	ldw     r3, 4(sp)
	addi    sp, sp, 8
	ret



PrintString:                        # PrintString(str): prints a null-terminated string to the JTAG UART
	subi    sp, sp, 8               # init stack
	stw     ra, 4(sp)
	stw     r3, 0(sp)
	mov     r3, r2                  # put the string pointer into r3 so we can use r2 to call PrintChar
ps_loop:
	ldb     r2, 0(r3)               # loads the char into r2--use ldb because it may be unaligned
	beq     r2, r0, ps_end          # if the char is 0, break out of the loop
	call    PrintChar               # print r2
	addi    r3, r3, 1               # increment the char pointer
	br      ps_loop                 # and continue the loop
ps_end:
	ldw     r3, 0(sp)               # restore stack
	ldw     ra, 4(sp)
	addi    sp, sp, 8
	ret




_start:
	movi    sp, 0x7FFC
	movia   r2, TEXT
	call    PrintString
	break


	
TEXT: .asciz "Hello world!\n"      # .asciz defines a null-terminated string
