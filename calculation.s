# Performs a calculation on LIST1, LIST2, LIST3, and stores the result in NEW_LIST.
# Also counts which numbers are negative and stores the count in NEG_COUNT.

.global _start
_start:
	movi	sp, 0x7FFC
	movi	r2, NEW_LIST
	movi	r3, LIST1
	movi	r4, LIST2
	movi	r5, LIST3
	ldw		r6, N(r0)
	call	Calculation
	stw		r2, NEG_COUNT(r0)
	break

Calculation:    # Calculation(v,r,s,t,n)

	# we don't need to store r2 as it will be overwritten by the return value
	# but store the rest of the registers so we don't overwrite them
	subi	sp, sp, 36
	stw		r3, 32(sp)
	stw		r4, 28(sp)
	stw		r5, 24(sp)
	stw		r6, 20(sp)
	stw		r7, 16(sp)
	stw		r8, 12(sp)
	stw		r9, 8(sp)
	stw		r10, 4(sp)
	stw		r11, 0(sp)

loop:
	ldw		r7, 0(r3)	# r7 holds r[i]
	ldw		r8, 0(r4)	# r8 holds s[i]
	ldw		r9, 0(r5)	# r9 holds t[i]
	
	movi	r11, 0		# r11 will hold the negative count
	
	# r10 will hold the result for v[i]
if:
	ble		r8, r9, else
then:
	mul		r10, r7, r8
	sub		r10, r10, r9
	br		endif
else:
	add		r10, r8, r9
endif:

	# increment the negative count if r10 < 0
if2:
	bge		r10, r0, endif2
then2:
	addi	r11, r11, 1
endif2:

	# now store the result in v[i]
	stw		r10, 0(r2)
	
	# increment the 4 list pointers
	addi	r2, r2, 4
	addi	r3, r3, 4
	addi	r4, r4, 4
	addi	r5, r5, 4
	
	# decrement the counter and continue loop
	subi	r6, r6, 1
	bgt		r6, r0, loop
	
	# store the count into the return value
	mov		r2, r11
	
	# restore registers
	ldw		r3, 32(sp)
	ldw		r4, 28(sp)
	ldw		r5, 24(sp)
	ldw		r6, 20(sp)
	ldw		r7, 16(sp)
	ldw		r8, 12(sp)
	ldw		r9, 8(sp)
	ldw		r10, 4(sp)
	ldw		r11, 0(sp)
	addi	sp, sp, 36
	ret
	
			.org 	0x1000
N: 			.word	4
NEW_LIST:	.skip	16
LIST1:		.word	9, 8, 7, 6
LIST2:		.word	1, -3, 5, -7
LIST3:		.word	-2, 4, -6, 8
NEG_COUNT:	.skip	4

