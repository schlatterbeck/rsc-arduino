#include <timer.h>

/* Water
 * ------------
 *
 * turns on and off a Triac and light emitting diode(LED) connected to a
 * digital  pin. The triac switches on a water valve.
 * Uses pins 10, 11, 12 for digital output.
 * Regularly ask serial driver for new commands. Commands are of the
 * form 'v[012] on' or 'v[012] off'.
 * Also ask push-button on digital input pins 3,4,5. debounce
 * push-buttons.
 * After enabling a digital output, start a timer for this output and
 * turn off the output when its time has come.
 */

#include <ctype.h>
#define DEBOUNCE_TIME_MS     500
#define TURNOFF_TIME_MS  3600000

#define SERIAL_MAX  256

struct water_s
    { Arduino_Timer turn_off;
      Arduino_Timer debounce;
      int           out_pin;
      int           in_pin;
    };

static struct water_s water [3] =
    { { Arduino_Timer (TURNOFF_TIME_MS)
      , Arduino_Timer (DEBOUNCE_TIME_MS)
      , 10, 2
      }
    , { Arduino_Timer (TURNOFF_TIME_MS)
      , Arduino_Timer (DEBOUNCE_TIME_MS)
      , 11, 3
      }
    , { Arduino_Timer (TURNOFF_TIME_MS)
      , Arduino_Timer (DEBOUNCE_TIME_MS)
      , 12, 4
      }
    };

static char serialbuf [SERIAL_MAX];
static int  serialpos = 0;
static unsigned long last = 0;

void setup ()
{
    int k;
    for (k=0; k<3; k++)
    {
        struct water_s *w = & water [k];
        pinMode      (w->out_pin, OUTPUT);
        pinMode      (w->in_pin,  INPUT);
        digitalWrite (w->in_pin,  HIGH); // enable pull-up resistor
    }
    Serial.begin (19200);
}

void loop ()
{
    int k;
    unsigned long now = millis ();

    // Buttons
    for (k=0; k<3; k++)
    {
        struct water_s *w = & water [k];
        int b = digitalRead (w->in_pin); // Button is active low
        // Inactive button and timeout reached, turn off debounce
        if (b && w->debounce.is_reached (now))
        {
            w->debounce.stop ();
        }
        if (!b)
        {
            if (!w->debounce.is_started ())
            {
                int pin = digitalRead (w->out_pin);
                if (pin)
                {
                    w->turn_off.stop ();
                    digitalWrite (w->out_pin, LOW);
                }
                else
                {
                    digitalWrite (w->out_pin, HIGH);
                    w->turn_off.start (now);
                }
            }
            w->debounce.start (now);
        }
    }
    // Serial commands
    if (Serial.available ())
    {
        int b = serialbuf [serialpos] = Serial.read ();
        if (b == '\n' || b == '\r')
        {
            serialbuf [serialpos] = '\0';
            Serial.println (serialbuf);
            if (  serialbuf [0] == 'v'
               && serialbuf [1] >= '0'
               && serialbuf [1] <= '2'
               )
            {
                int i;
                struct water_s *w = & water [serialbuf [1] - '0'];
                for (i=2; i<SERIAL_MAX; i++)
                {
                    if (!isspace (serialbuf [i]))
                    {
                        break;
                    }
                }
                if (!strncmp (serialbuf + i, "on", 2))
                {
                    digitalWrite (w->out_pin, HIGH);
                    w->turn_off.start (now);
                }
                else if (!strncmp (serialbuf + i, "off", 3))
                {
                    w->turn_off.stop ();
                    digitalWrite (w->out_pin, LOW);
                }
                else if (!strncmp (serialbuf + i, "st", 2))
                {
                    int pin = digitalRead (w->out_pin);
                    Serial.print   ("Time: ");
                    Serial.println (now);
                    Serial.print   ("V: ");
                    Serial.print   (pin);
                    Serial.print   (" (t:");
                    Serial.print   (w->turn_off.is_started  ());
                    Serial.print   (") time: ");
                    Serial.println (w->turn_off.get_endtime ());
                }
            }
            serialpos = 0;
        }
        else 
        {
            serialpos++;
        }
        // commands are much shorter than SERIAL_MAX -- ignore
        if (serialpos == SERIAL_MAX)
        {
            serialpos = 0;
        }
    }
    // Timeouts
    for (k=0; k<3; k++)
    {
        struct water_s *w = & water [k];
        if (w->turn_off.is_reached (now))
        {
            digitalWrite (w->out_pin, LOW);
            w->turn_off.stop ();
            Serial.println ("timeout");
        }
    }
    last = now;
}

