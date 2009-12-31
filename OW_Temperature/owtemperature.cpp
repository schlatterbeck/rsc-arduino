#include "owclock.h"
    
OW_Temperature::OW_Temperature (OneWire & temperature, uint8_t *addr)
    : _addr        (addr)
    , _temperature (temperature)
    , _is_valid    (false)
{

    if (!_addr)
    {
#if ONEWIRE_SEARCH
        _temperature.reset_search ();
        while (_temperature.search (_buf) && _buf [0] != 0x27)
            {}
#else
        _temperature.reset ();
        _temperature.write (0x33); // Read ROM
        for (int i=0; i<8; i++)
        {
            _buf [i] = _temperature.read ();
        }
#endif
        if (  _buf [0] == 0x10
           && OneWire::crc8 (_buf, 7) == _buf[7]
           )
        {
            _is_valid = true;
            _addr     = _buf;
        }
    }
}

const uint8_t *OW_Temperature::temperature (void)
{
    // return a static buffer so that our addr isn't modified
    static uint8_t adr [8];
    for (int i=0; i<8; i++)
    {
        adr [i] = _addr [i];
    }
    return adr;
}

void OW_Temperature::set_time (time_t timestamp)
{
    char *ts = (char *) &timestamp;
    _temperature.reset  ();
    _temperature.select (_addr);
    _temperature.write  (0x99); // WRITE CLOCK
    _temperature.write  (0x0C); // No interrupt, clock enabled
    for (int i=0; i<4; i++)
    {
        _temperature.write (ts [i]);
    }
    _temperature.reset (); // clock starts after reset!
}

time_t OW_Temperature::time (void)
{
    time_t retval = 0;
    char *ts = (char *) &retval;
    _temperature.reset  ();
    _temperature.select (_addr);
    _temperature.write  (0x66); // READ CLOCK
    _temperature.read   ();     // ignore device control byte
    for (int i=0; i<4; i++)
    {
        ts [i] = _temperature.read ();
    }
    return retval;
}
