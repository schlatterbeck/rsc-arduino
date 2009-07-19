#include "timer.h"
    
OW_Timer::OW_Timer (OneWire &clock, char *addr = 0)
    : _addr     (addr)
    , _is_valid (False)
{

    if (!_addr)
    {
#if ONEWIRE_SEARCH
        clock.reset_search ();
        while (clock.search (_addr) && _addr [0] != 0x27)
            {}
#else
        clock.write (0x33); // Read ROM
        for (int i=0; i<8; i++)
        {
            _addr [i] = clock.read ();
        }
#endif
        if (  _addr [0] == 0x27
           && OneWire::crc8 (clock_addr, 7) == clock_addr[7]
           )
        {
            is_valid = True;
        }
    }
}

unsigned long OW_Timer::set_time (time_t timestamp)
{
    char *ts = (char *) &timestamp;
    clock.reset  ();
    clock.select (_addr);
    clock.write  (0x99); // WRITE CLOCK
    clock.write  (0x0C); // No interrupt, clock enabled
    for (int i=0; i<4; i++)
    {
        clock.write (ts [i]);
    }
    clock.reset (); // clock starts after reset!
}

time_t OW_Timer::time (void)
{
    time_t retval = 0;
    char *ts = (char *) &retval;
    clock.reset  ();
    clock.select (_addr);
    clock.write  (0x66); // READ CLOCK
    clock.read   ();     // ignore device control byte
    for (int i=0; i<4; i++)
    {
        ts [i] = clock.read ();
    }
}
