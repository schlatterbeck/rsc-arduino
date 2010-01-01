/* One Wire Temperature Sensor Dallas/Maxim
 * ----------------------------------------
 */

#include <stdio.h>
#include <OneWire.h>
#include <time.h>
#include <owtemperature.h>

OneWire        ow  (2);
 
void setup(void)
{
    Serial.begin (9600);
}

void loop(void)
{
    /* sensor has adr: 10 DB E8 ED 1 8 0 2A */
    const uint8_t *adr = 0;
    OW_Temperature tem (ow);
    if (!tem.is_valid ())
    {
        adr = tem.get_addr ();
        for (int i=0; i<8; i++)
        {
            Serial.print (adr [i], HEX);
            Serial.print (' ');
        }
        Serial.println ("Invalid CRC");
        return;
    }
    tem.set_aux (0x4711);
    int16_t temperature = tem.temperature ();
    adr = tem.get_buf ();
    if (adr [7] == 0x10 && OneWire::crc8 (adr, 8) == adr [8])
    {
        Serial.print (temperature >> 4);
        Serial.print ('.');
        int16_t after = temperature & 0xF;
        after *= 10000 / 16;
        int16_t exp = 1;
        for (int i=0; i<3; i++)
        {
            exp *= 10;
            if (after < exp)
            {
                Serial.print (0);
            }
        }
        Serial.print (after);
    }
    else
    {
        Serial.print ("Invalid temperature");
    }
    Serial.print ("            ");
    for (int i=0; i<9; i++)
    {
        Serial.print (adr [i], HEX);
        Serial.print (' ');
    }
    Serial.print (tem.get_aux (), HEX);
    Serial.println ();
}
