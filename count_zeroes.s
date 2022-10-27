# Counts zeroes in a list of numbers in memory

    .text
    .global _start
    .org    0x000

_start:
    ldw     r2, N(r0)
    movi    r3, LIST
    movi    r4, 0

LOOP:
    ldw     r5, 0(r3)
    bne     r5, r0, NOTZERO
    addi    r4, r4, 1

NOTZERO:
    addi    r3, r3, 4
    subi    r2, r2, 1
    bgt     r2, r0, LOOP

    stw     r4, SUM(r0)
    break


        .org    0x1000
SUM:    .skip   4
N:      .word   5
LIST:   .word   0, 0, 57, 91, 0

        .end

