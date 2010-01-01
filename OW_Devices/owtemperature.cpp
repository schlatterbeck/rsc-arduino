#include "owtemperature.h"
#include "wiring.h"
    
int16_t OW_Temperature::temperature (void)
{
    int16_t temp = 0x0;
    start_measure ();
    read_all      ();
    temp = ((_buf [1] << 8) | _buf [0]);
    temp *= _buf [7];
    temp -= (_buf [7] >> 2);
    temp += (_buf [7] - _buf [6]);
    return temp;
}

void OW_Temperature::start_measure (void)
{
    _device.reset   ();
    _device.select  (_addr);
    _device.write   (0x44, 1); // leave power on
    delay           (750);
    _device.depower ();
}

void OW_Temperature::read_all (void)
{
    _device.reset   ();
    _device.write   (0xBE);
    for (int i=0; i<9; i++)
    {
        _buf [i] = _device.read ();
    }
}

uint16_t OW_Temperature::get_aux (void)
{
    return (_buf [2] << 8) | _buf [3];
}

void OW_Temperature::set_aux (uint8_t *twobytes)
{
    _device.reset  ();
    _device.select (_addr);
    _device.write  (0x4E);
    _device.write  (twobytes [0]);
    _device.write  (twobytes [1]);
}
