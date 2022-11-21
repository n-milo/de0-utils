// #include "nios2_control.h"

#define HEX_DATA ((volatile unsigned int *) 0x10000020)

// mapping of digits (0-9) to data to write to the 7-segment displays
unsigned int hex_table[16] = {
    0x3F, 0x06, 0x5B, 0x4F,
    0x66, 0x6D, 0x7D, 0x07,
    0x7F, 0x6F, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

void DisplayDigit(int which_hex_display, int value) {
    if (value < 0 || value >= 10)
        return;

    if (which_hex_display < 0 || which_hex_display >= 4)
        return;

    // first clear the data at the given hex display by ANDing it with a number
    // with all 1's except the 8 bits of the hex display, which would be 0
    // e.g. if which_hex_display == 2, we have
    //      *HEX_DATA &= ~(0xFF << 16)
    //                 = ~(0x00FF0000)
    //                 = 0xFF00FFFF
    *HEX_DATA &= ~(0xFFu << (which_hex_display * 8));

    // then, set the hex data display from the hex table
    *HEX_DATA |= hex_table[value] << (which_hex_display * 8);
}

void interrupt_handler(void)
{
    unsigned int ipending;

}

/*-----------------------------------------------------------------*/

void Init (void)
{

}

/*-----------------------------------------------------------------*/

int main (void)
{
    DisplayDigit(3, 1);
    DisplayDigit(2, 2);
    DisplayDigit(1, 3);
    DisplayDigit(0, 4);

    while (1)
    {
    }

    return 0;
}
