#include "owdevice.h"
    
OW_Device::OW_Device (OneWire & device, uint8_t *addr, uint8_t id)
    : _device   (device)
    , _is_valid (false)
{

    if (addr)
    {
        for (int i=0; i<8; i++)
        {
            _addr [i] = addr [i];
        }
    }
    else
    {
        for (int i=0; i<8; i++)
        {
            _addr [i] = 0;
        }
        _device.reset ();
#if ONEWIRE_SEARCH
        _device.reset_search ();
        while (_device.search (_addr) && _addr [0] != id)
            {}
#else
        _device.write (0x33); // Read ROM
        for (int i=0; i<8; i++)
        {
            _addr [i] = _device.read ();
        }
#endif
        if (  _addr [0] == id
           && OneWire::crc8 (_addr, 7) == _addr[7]
           )
        {
            _is_valid = true;
        }
    }
}

const uint8_t *OW_Device::get_addr (void)
{
    // return a static buffer so that our addr isn't modified
    static uint8_t adr [8];
    for (int i=0; i<8; i++)
    {
        adr [i] = _addr [i];
    }
    return adr;
}

const uint8_t * const OW_Device::get_buf (void)
{
    return _buf;
}
