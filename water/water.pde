/* Water
 * ------------
 *
 * turns on and off a Triac and light emitting diode(LED) connected to a
 * digital  pin. The triac switches on a water valve.
 * Uses pins 11, 12, 13 for digital output.
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
    { unsigned long action_time;
      bool          action_valid;
      unsigned long debounce_time;
      bool          debounce_valid;
      int           out_pin;
      int           in_pin;
    };

static struct water_s water [3] =
    { { 0, false, 0, false, 11, 2}
    , { 0, false, 0, false, 12, 3}
    , { 0, false, 0, false, 13, 4}
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

bool timeout_reached 
    (unsigned long last, unsigned long now, unsigned long timeout)
{
    if (last > now)
    {
        last    -= 0x7FFFFFFF;
        now     -= 0x7FFFFFFF;
        timeout -= 0x7FFFFFFF;
    }
    if (timeout > last && timeout <= now)
    {
        return true;
    }
    return false;
}

void loop ()
{
    int k;
    unsigned long now = millis ();

    // Buttons
    for (k=0; k<3; k++)
    {
        struct water_s *w = & water [k];
        int b = digitalRead (w->in_pin);
        if (w->debounce_valid && timeout_reached (last, now, w->debounce_time))
        {
            w->debounce_valid = false;
        }
        if (!b && !w->debounce_valid)
        {
            int pin = digitalRead (w->out_pin);
            w->debounce_time  = now + DEBOUNCE_TIME_MS;
            w->debounce_valid = true;
            if (pin)
            {
                digitalWrite (w->out_pin, LOW);
                w->action_valid = false;
            }
            else
            {
                digitalWrite (w->out_pin, HIGH);
                w->action_time  = now + TURNOFF_TIME_MS;
                w->action_valid = true;
            }
        }
    }
    // Serial commands
    if (Serial.available ())
    {
        int b = serialbuf [serialpos] = Serial.read ();
        if (b == '\n' || b == '\r')
        {
            Serial.println (serialbuf);
            serialbuf [serialpos] = '\0';
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
                    w->action_time  = now + TURNOFF_TIME_MS;
                    w->action_valid = true;
                }
                else if (!strncmp (serialbuf + i, "off", 3))
                {
                    digitalWrite (w->out_pin, LOW);
                    w->action_valid = false;
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
        if (w->action_valid && timeout_reached (last, now, w->action_time))
        {
            digitalWrite (w->out_pin, LOW);
            w->action_valid = false;
            Serial.println ("timeout");
        }
    }
    last = now;
}

