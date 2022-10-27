# Uses subroutines to count zeroes (gives the same result as count_zeroes.s)

    .text
    .global _start
    .org    0x000

_start:

main:
    movi    sp, 0x7FFC      # initialize stack pointer
    movi    r2, LIST
    ldw     r3, N(r0)
    call    zero_count      # zero_count(&LIST, N)
    stw     r2, SUM(r0)
    break




zero_count:                 # r2 is list_address, r3 is N
    # store the old register values onto the stack
    subi    sp, sp, 16
    stw     ra, 12(sp)
    stw     r3, 8(sp)       # preserve the original value of N
    stw     r4, 4(sp)       # list element
    stw     r5, 0(sp)       # count of zero elements

    movi    r5, 0
    mov     r4, r2

zc_loop:

zc_if:
    ldw     r2, 0(r4)       # r2 will hold the number we read from r4
    call    check_if_zero
    beq     r2, r0, zc_end_if
zc_then:
    addi    r5, r5, 1
zc_end_if:

    subi    r3, r3, 1
    addi    r4, r4, 4
    bgt     r3, r0, zc_loop

    mov     r2, r5

    # restore stack frame
    ldw     ra, 12(sp)
    ldw     r3, 8(sp)
    ldw     r4, 4(sp)
    ldw     r5, 0(sp)
    addi    sp, sp, 16

    ret



check_if_zero:

ciz_if:
    bne     r2, r0, ciz_else
ciz_then:
    movi    r2, 1
    br      ciz_endif
ciz_else:
    movi    r2, 0
ciz_endif:
    
    ret



        .org    0x1000
SUM:    .skip   4
N:      .word   5
LIST:   .word   37, 0, 57, 91, 0

        .end

