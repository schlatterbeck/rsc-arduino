
#include <wiring.h>
#include "debounce.h"
    
Debounced_Input::Debounced_Input (int input, unsigned long duration)
    : _input   (input)
    , duration (duration)
    , current  (1)
{
    pinMode               (input, INPUT);
    digitalWrite          (input, HIGH); // enable pull-up resistor
    current = digitalRead (input);
}

int Debounced_Input::read (void)
{
    int           x   = digitalRead (_input);
    unsigned long now = millis ();

    if (timer.is_started ())
    {
        if (x == current)
        {
            timer.stop ();
        }
        else
        {
            if (timer.is_reached (now))
            {
                timer.stop ();
                current = x;
            }
        }
    }
    else
    {
        if (x != current)
        {
             timer.start (now, duration);
        }
    }
    return current;
}
