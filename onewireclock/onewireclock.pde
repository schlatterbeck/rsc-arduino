/* One Wire Clock Dallas/Maxim DS2417 Conrad Part No 170014
 * --------------------------------------------------------
 */

#include <OneWire.h>
 
// DS18S20 Temperature chip i/o
OneWire clock (10);  // on pin 10
byte clock_addr[8];
 
void setup(void) {
    Serial.begin (9600);
    clock.reset_search ();
    if (!clock.search (clock_addr))
    {
        Serial.print ("Error initializing clock\r\n");
    }
    Serial.print ("R=");
    for(int i=0; i<8; i++) {
        Serial.print (clock_addr[i], HEX);
        Serial.print (" ");
    }
    Serial.print ("\r\n");
    if (OneWire::crc8 (clock_addr, 7) != clock_addr[7]) {
        Serial.print ("CRC is not valid!\r\n");
    }
}
 
void loop(void) {
    byte readrom [8];
    byte i;
    byte present = 0;

    clock.reset  ();
    clock.write  (0x33);
    for (i=0; i<8; i++)
    {
        readrom [i] = clock.read ();
        Serial.print (readrom [i], HEX);
        Serial.print (' ');
    }
    Serial.print ("\r\n");

    clock.reset  ();
    clock.select (clock_addr);
    clock.write  (0x99);
    clock.write  (0x0C);
    clock.write  (0x23);
    clock.write  (0x17);
    clock.write  (0x05);
    clock.write  (0x00);
    clock.reset  ();

    for (int j=0; j<10; j++)
    {
        delay (1000);
        clock.reset  ();
        clock.select (clock_addr);
        clock.write  (0x66);
        for (i=0; i<5; i++)
        {
            byte data;
            data = clock.read ();
            Serial.print (data, HEX);
            Serial.print (' ');
        }
        Serial.print ("\r\n");
    }
}
