#include "owclock.h"
    
void OW_Clock::set_time (time_t timestamp)
{
    char *ts = (char *) &timestamp;
    _device.reset  ();
    _device.select (_addr);
    _device.write  (0x99); // WRITE CLOCK
    _device.write  (0x0C); // No interrupt, clock enabled
    for (int i=0; i<4; i++)
    {
        _device.write (ts [i]);
    }
    _device.reset (); // clock starts after reset!
}

time_t OW_Clock::time (void)
{
    time_t retval = 0;
    char *ts = (char *) &retval;
    _device.reset  ();
    _device.select (_addr);
    _device.write  (0x66); // READ CLOCK
    _device.read   ();     // ignore device control byte
    for (int i=0; i<4; i++)
    {
        ts [i] = _device.read ();
    }
    return retval;
}
