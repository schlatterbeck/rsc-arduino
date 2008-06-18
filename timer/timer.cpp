#include "timer.h"
    
void ArduinoTimer::Start (unsigned long now, unsigned long duration)
{
    started = true;
    last = now;
    end  = (now + duration) % MODULUS;
}

void ArduinoTimer::Stop ()
{
    started = false;
}

bool ArduinoTimer::Reached (unsigned long now)
{
    if (now < last)
        return started && now > end;
    return started && last < end && end <= now;
}
