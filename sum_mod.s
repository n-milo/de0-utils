.text
.global _start
.org    0x0000

_start:
    ldw     r2, N(r0)           # load N into r2, r2 holds the number of elements remaining

    movi    r3, LIST            # move address of LIST into r3
                                # r3 will point to the next list element

    movi    r4, 0               # set r4 to 0, r4 will hold the sum
    movi    r6, 0               # set r6 to 0, r6 will hold the repl_count

LOOP:
    ldw     r5, 0(r3)           # load r3 into r5, r5 holds list[i]
    add     r4, r4, r5          # add r5 to r4

IF:
    blt     r5, r0, END_IF      # if r5 < 0, jump to END_IF
THEN:                           # if we continue, list[i] >= 0
    movi    r7, -1
    stw     r7, 0(r3)           # store r7 (-1) into list[i]
    addi    r6, r6, 1           # increment r6, which holds repl_count
END_IF:


    addi    r3, r3, 4           # add 4 to r3, to point to the next list element
    subi    r2, r2, 1           # decrement r2 once, it now holds how many elements are left
    bgt     r2, r0, LOOP        # if r2 > 0, jump to LOOP
END_LOOP:

    stw     r6, REPL_COUNT(r0)  # r6 holds the replacement count, store it in REPL_COUNT
    stw     r4, SUM(r0)         # r4 holds the sum, store it in SUM
    break

            .org    0x1000
SUM:        .skip   4
REPL_COUNT: .skip   4
N:          .word   5
LIST:       .word   12, 0xFFFFFFFE, 7, -1, 2
            .end
