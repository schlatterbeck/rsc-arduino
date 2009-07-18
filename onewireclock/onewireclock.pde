/* One Wire Clock Dallas/Maxim DS2417 Conrad Part No 170014
 * --------------------------------------------------------
 */

#include <OneWire.h>
 
// DS18S20 Temperature chip i/o
OneWire clock (10);  // on pin 10
 
void setup(void) {
    Serial.begin (9600);
}
 
void loop(void) {
    byte i;
    byte present = 0;
    byte addr[8];

    if (!clock.search (addr)) {
        Serial.print ("No more addresses.\r\n");
        clock.reset_search ();
        return;
    }
 
    Serial.print ("R=");
    for(i=0; i<8; i++) {
        Serial.print (addr[i], HEX);
        Serial.print (" ");
    }
    Serial.print ("\r\n");
 
    if (OneWire::crc8 (addr, 7) != addr[7]) {
        Serial.print ("CRC is not valid!\r\n");
        return;
    }
 
    clock.reset  ();
    clock.select (addr);
    clock.write  (0x99);
    clock.write  (0x0C);
    clock.write  (0x23);
    clock.write  (0x17);
    clock.write  (0x05);
    clock.write  (0x00);

    delay (1000);

    clock.reset  ();
    clock.select (addr);
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
