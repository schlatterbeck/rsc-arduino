#include "owclock.h"
    
OW_Clock::OW_Clock (OneWire & clock, uint8_t *addr)
    : _addr     (addr)
    , _clock    (clock)
    , _is_valid (false)
{

    if (!_addr)
    {
#if ONEWIRE_SEARCH
        _clock.reset_search ();
        while (_clock.search (_buf) && _buf [0] != 0x27)
            {}
#else
        _clock.write (0x33); // Read ROM
        for (int i=0; i<8; i++)
        {
            _buf [i] = _clock.read ();
        }
#endif
        if (  _buf [0] == 0x27
           && OneWire::crc8 (_buf, 7) == _buf[7]
           )
        {
            _is_valid = true;
            _addr     = _buf;
        }
    }
}

const uint8_t *OW_Clock::get_addr (void)
{
    // return a static buffer so that our addr isn't modified
    static uint8_t adr [8];
    for (int i=0; i<8; i++)
    {
        adr [i] = _addr [1];
    }
    return adr;
}

void OW_Clock::set_time (time_t timestamp)
{
    char *ts = (char *) &timestamp;
    _clock.reset  ();
    _clock.select (_addr);
    _clock.write  (0x99); // WRITE CLOCK
    _clock.write  (0x0C); // No interrupt, clock enabled
    for (int i=0; i<4; i++)
    {
        _clock.write (ts [i]);
    }
    _clock.reset (); // clock starts after reset!
}

time_t OW_Clock::time (void)
{
    time_t retval = 0;
    char *ts = (char *) &retval;
    _clock.reset  ();
    _clock.select (_addr);
    _clock.write  (0x66); // READ CLOCK
    _clock.read   ();     // ignore device control byte
    for (int i=0; i<4; i++)
    {
        ts [i] = _clock.read ();
    }
    return retval;
}
