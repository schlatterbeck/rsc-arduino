#ifndef debounce_h
#define debounce_h

# include "timer.h"
//# include <wiring.h>

// Implements a debounced sensor. Uses a timer to debounce reads.
// When timer is reached and input was the same since timer started we
// return the new value.
class Debounced_Input
{
    public:
        Debounced_Input  (int input, unsigned long duration_ms = 500);
        ~Debounced_Input () {};

        int read  (void);
        int input (void) {return _input;};

    private:
        int           _input;
        long          duration;
        int           current;
        Arduino_Timer timer;
};
#endif // timer_h
