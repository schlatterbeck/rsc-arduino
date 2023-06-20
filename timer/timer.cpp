#include "timer.h"
    
Arduino_Timer::Arduino_Timer (unsigned long duration)
    : default_duration (duration)
{
}

void Arduino_Timer::start (unsigned long now, unsigned long dur)
{
    started = true;
    start_time = now;
    if (dur == 0) {
        dur = default_duration;
    }
    duration = dur;
}

void Arduino_Timer::stop ()
{
    started = false;
}

bool Arduino_Timer::is_reached (unsigned long now)
{
    return now - start_time >= duration;
}

bool Arduino_Timer::is_started ()
{
    return started;
}
