#include "timer.h"
    
Arduino_Timer::Arduino_Timer (unsigned long duration)
    : default_duration (duration)
{
}

unsigned long Arduino_Timer::get_endtime (void)
{
    return end;
}

void Arduino_Timer::start (unsigned long now, unsigned long duration)
{
    started = true;
    last = now;
    if (duration == 0)
    {
        duration = default_duration;
    }
    end  = (now + duration);
    if (MODULUS != 1)
    {
        end = end % MODULUS;
    }
}

void Arduino_Timer::stop ()
{
    started = false;
}

bool Arduino_Timer::is_reached (unsigned long now)
{
    if (now < last)
        return started && now > end;
    return started && last < end && end <= now;
}

bool Arduino_Timer::is_started ()
{
    return started;
}
