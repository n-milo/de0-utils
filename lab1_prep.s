.equ JTAG_UART_BASE,    0x10001000  # base address for the JTAG UART interface
.equ DATA_OFFSET,       0           # data regsiter is at base+0
.equ STATUS_OFFSET,     4           # status register is at base+4
.equ WSPACE_MASK,       0xFFFF      # WSPACE is held in the top 16 bits of the control register

.global _start


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

    
_start:
    movi    sp, 0x7FFC
    movi    r2, '*'
    call    PrintChar
    break
