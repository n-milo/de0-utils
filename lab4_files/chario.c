/* for standalone testing of this file by itself using the simulator,
   keep the following line, but for in-lab activity with the Monitor Program
   to have a multi-file project, comment out the following line */

#define TEST_CHARIO


/* no #include statements should be required, as the character I/O functions
   do not rely on any other code or definitions (the .h file for these
   functions would be included in _other_ .c files) */


/* because all character-I/O code is in this file, the #define statements
   for the JTAG UART pointers can be placed here; they should not be needed
   in any other file */

#define JTAG_UART_DATA    ((volatile unsigned int *) 0x10001000)
#define JTAG_UART_CONTROL ((volatile unsigned int *) 0x10001004)

void PrintChar(char c) {
    while ((*JTAG_UART_CONTROL & 0xFFFF0000) == 0);
    *JTAG_UART_DATA = (unsigned int) c;
    return c;
}

void PrintString(const char *s) {
    for (; *s; s++)
        PrintChar(*s);
}

void PrintHexDigit(int digit) {
    if (digit >= 10) {
        PrintChar((char) (digit - 10 + 'A'));
    } else {
        PrintChar((char) (digit + '0'));
    }
}

char CheckChar(void) {
    // bit 15 of the jtag data holds the rvalid bit, which, if 1, indicates that
    // the data is ready, and the bottom 8 bits holds the character
    unsigned data = *JTAG_UART_DATA;
    unsigned rvalid = (data & 0x8000);
    if (rvalid) {
        return (char) (data & 0xFF);
    } else {
        return 0;
    }
}

char GetChar(void) {
    while (1) {
        char c = CheckChar();
        if (c != 0)
            return c;
    }
}


#ifdef TEST_CHARIO

int main (void) {
    PrintChar('h');
    PrintChar('i');
    PrintChar('\n');
    PrintString("Hello world!\n");
    PrintHexDigit(4);
    PrintHexDigit(0xB);

    while (1) {
        PrintString("checking char...\n");
        char c = CheckChar();
        if (c != 0) {
            PrintString("got: ");
            PrintChar(c);
            PrintChar('\n');
            break;
        } else {
            PrintString("got nothing\n");
        }
    }

    PrintString("getting char...\n");
    char c = GetChar();
    PrintString("got: ");
    PrintChar(c);
    PrintChar('\n');
}

#endif /* TEST_CHARIO */
