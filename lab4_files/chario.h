#ifndef _CHARIO_H_
#define _CHARIO_H_

// prints a character
void PrintChar(char c);

// prints a null-terminated string
void PrintString(const char *s);

// prints a hex number from 0 to 15
void PrintHexDigit(int digit);

// gets a character from the JTAG UART
char GetChar(void);

// checks the JTAG UART for a ready character and returns it, or returns '\0' if
// no characters are ready yet
char CheckChar(void);

#endif /* _CHARIO_H_ */
