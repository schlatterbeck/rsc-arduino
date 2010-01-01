/* One Wire Temperature Sensor Dallas/Maxim
 * ----------------------------------------
 */

#include <stdio.h>
#include <OneWire.h>
#include <time.h>
#include <owtemperature.h>

OneWire        ow  (3);
 
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
    adr = tem.get_addr ();
    for (int i=0; i<8; i++)
    {
        Serial.print (adr [i], HEX);
        Serial.print (' ');
    }
    Serial.println ();
    int16_t temperature = tem.temperature ();
    Serial.print (temperature >> 4);
    Serial.print ('.');
    Serial.print (temperature & 0xF);
    Serial.println ();
    adr = tem.get_buf ();
    for (int i=0; i<8; i++)
    {
        Serial.print (adr [i], HEX);
        Serial.print (' ');
    }
    Serial.println ();
}
