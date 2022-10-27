# Defining a subroutine:
SubroutineName:
    # Reserve stack space and save registers:
    subi    sp, sp, ?       # Reserve space on the stack
    stw     ra, ?(sp)       # Save the return address for nested calls
    ...
    stw     r?, ?(sp)       # Save the contents of the registers

    <body>

    # Now, do the same in reverse:
    ldw     ra, ?(sp)       # Re-load the return address
    ...
    ldw     r?, ?(sp)       # Re-load the register values
    addi    sp, sp, ?       # Put the stack pointer back

    ret


# Calling a subroutine:
    movi    r2, <arg1>  # r2 holds arg1
    movi    r3, <arg2>  # r3 holds arg2
    call    SubroutineWithTwoArgsAndReturnValue
    stw     r2, ...     # Use return valeu
