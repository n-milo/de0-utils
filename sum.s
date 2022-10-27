.text
.global _start
.org    0x0000

_start:
    ldw     r2, N(r0)           # load N into r2

    movi    r3, LIST            # move &LIST into r3
                                # r3 will point to the next list element

    movi    r4, 0               # set r4 to 0

LOOP:                           # LOOP:
    ldw     r5, 0(r3)           #   load r3 into r5
    add     r4, r4, r5          #   add r5 to r4
    addi    r3, r3, 4           #   add 4 to r3, to point to the next list element
    subi    r2, r2, 1           #   decrement r2 once, it now holds how many elements are left
    bgt     r2, r0, LOOP        #   if r2 > 0, jump to LOOP

    stw     r4, SUM(r0)         # r4 now holds the sum, store it in SUM
    break                       # end program

        .org    0x1000
SUM:    .skip   4
N:      .word   5
LIST:   .word   12, 0xFFFFFFFE, 7, -1, 2
        .end
