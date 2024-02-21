#include "print.h"

void kernel_main(const char* message)
{
    print_clear();
    print_set_color(PRINT_COLOR_WHITE, PRINT_COLOR_BLUE);
    print_str(message);
}
