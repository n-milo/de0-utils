# Does some math on variables in memory

.text
.global _start
.org    0x0050

_start:
    ldw     r2, M(r0)       # r2 = M
    addi    r2, r2, 2       # r2 = M+2
    ldw     r3, K(r0)       # r3 = K
    sub     r2, r2, r3      # r2 = M+2-K
    stw     r2, A(r0)       # store it in A

    ldw     r2, J(r0)       # r2 = J
    ldw     r3, D(r0)       # r3 = D
    add     r2, r2, r3      # r2 = J+D
    ldw     r3, B(r0)       # r3 = B
    div     r2, r2, r3      # r2 = (J+D)/B
    stw     r2, F(r0)       # store it in F

    ldw     r3, C(r0)       # r3 = C
    mul     r2, r2, r3      # r2 already holds F from above, now r2 = F * C
    stw     r2, W(r0)       # store it in W

    break

    .org    0x2000

A:  .skip   4
F:  .skip   4
W:  .skip   4

B:  .word   2
C:  .word   3
D:  .word   4
K:  .word   5
J:  .word   6
M:  .word   7

    .end
