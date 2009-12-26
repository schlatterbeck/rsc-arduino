/* One Wire Clock Dallas/Maxim DS2417 Conrad Part No 170014
 * --------------------------------------------------------
 */

#include <stdio.h>
#include <OneWire.h>
#include <time.h>
#include <owclock.h>
 
OneWire  ow    (2);
uint8_t _adr [9];
uint8_t _buf [9];
 
void setup(void) {
    Serial.begin (9600);
}

void loop(void)
{
    ow.reset_search ();
    ow.search (_adr);
    if (OneWire::crc8 (_adr, 7) == _adr [7])
    {
        Serial.println ("CRC OK");
    }
    for (int i=0; i<8; i++)
    {
        Serial.print (_adr [i], HEX);
        Serial.print (' ');
    }
    Serial.println ();
    ow.reset  ();
    ow.select (_adr);
    ow.write (0x4E);
    ow.write (0x47);
    ow.write (0x11);
    ow.reset  ();
    ow.select (_adr);
    ow.write (0x44, 1);
    delay (4711);
    ow.depower ();
    ow.reset  ();
    ow.select (_adr);
    ow.write (0xBE);
    for (int i=0; i<9; i++)
    {
        _buf [i] = ow.read ();
    }
    for (int i=0; i<9; i++)
    {
        Serial.print (_buf [i], HEX);
        Serial.print (' ');
    }
    Serial.println ();
}
