/* One Wire Clock Dallas/Maxim DS2417 Conrad Part No 170014
 * --------------------------------------------------------
 */

#include <OneWire.h>
#include <time.h>
#include <owclock.h>
 
OneWire  ow    (10);
OW_Clock clock (ow);
 
void setup(void) {
    const uint8_t *addr;
    Serial.begin (9600);
    if (!clock.is_valid ())
    {
        Serial.print ("Error initializing clock\r\n");
        return;
    }
    addr = clock.get_addr ();
    Serial.print ("R=");
    for(int i=0; i<8; i++) {
        Serial.print (addr[i], HEX);
        Serial.print (" ");
    }
    Serial.print ("\r\n");
}

static char serialbuf [256];
static int serialpos = 0;
 
void loop(void)
{
    time_t time = clock.time ();
    struct tm *tm;
    if (Serial.available ())
    {
        int b = serialbuf [serialpos++] = Serial.read ();
        if (b == '\n' || b == '\r')
        {
            serialbuf [serialpos - 1] = '\0';
            if (strlen (serialbuf))
            {
                time = atol (serialbuf);
                clock.set_time (time);
                time = clock.time ();
            }
            tm = gmtime (&time);
            Serial.print (time);
            Serial.print (' ');
            Serial.print (tm->tm_year + 1900);
            Serial.print ('-');
            Serial.print (tm->tm_mon + 1);
            Serial.print ('-');
            Serial.print (tm->tm_mday);
            Serial.print ('.');
            Serial.print (tm->tm_hour);
            Serial.print (':');
            Serial.print (tm->tm_min);
            Serial.print (':');
            Serial.print (tm->tm_sec);
            Serial.println ();
            serialpos = 0;
        }
        if (serialpos >= sizeof (serialbuf))
        {
            serialpos = 0;
        }
    }
}
