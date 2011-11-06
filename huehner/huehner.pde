#include <timer.h>
#include <stdio.h>
#include <time.h>
#include <OneWire.h>
#include <owclock.h>

# define LED          13
# define MAGNET_OBEN   7
# define MAGNET_UNTEN  8
# define FOTO          0
# define MOTOR         9
# define OWCLOCK      10
# define ERROR_LED    11
# define MOTOR_DIR1    4
# define MOTOR_DIR2    3
# define MOTOR_MIN  0x7F
# define KNOPF_RAUF   12
# define KNOPF_RUNTER  2

# define HELL        300
# define FINSTER     200

# define STATUS_TAG          0
# define STATUS_ABEND        1
# define STATUS_NACHT        2
# define STATUS_MORGEN       3
# define STATUS_NACHBARN     4
# define STATUS_START_RAUF   5
# define STATUS_RAUFFAHREN   6
# define STATUS_START_RUNTER 7
# define STATUS_RUNTERFAHREN 8
# define STATUS_ERROR        9

int status   = STATUS_ERROR;
char errbuf [80];
char *errmsg = "";
int neuinitialisieren     = 1;
int debounce_magnet       = 0;
int debounce_knopf_runter = 0;
int debounce_knopf_rauf   = 0;
OneWire  ow    (OWCLOCK);
OW_Clock clock (ow);

# define TIMER_MS       10000 // 10 seconds debounce 300000 // 5 minutes
# define FAHRZEIT_MS    75000 // max 75 seconds for up/down of door
Arduino_Timer timer (TIMER_MS);

int debounced_read (int iopin, int *counter)
{
    if (!digitalRead (iopin))
    {
        if ((*counter)++ >= 10)
        {
            *counter = 0;
            return 0;
        }
    }
    else
    {
        *counter = 0;
    }
    return 1;
}

void motor_an ()
{
    digitalWrite (LED,   HIGH);
    digitalWrite (MOTOR, HIGH);
}

void motor_aus ()
{
    digitalWrite (LED,   LOW);
    digitalWrite (MOTOR, LOW);
}

void linksrum ()
{
    digitalWrite (MOTOR_DIR1, LOW);
    digitalWrite (MOTOR_DIR2, HIGH);
}

void rechtsrum ()
{
    digitalWrite (MOTOR_DIR1, HIGH);
    digitalWrite (MOTOR_DIR2, LOW);
}

// Wir benutzen Status-Funktionen fuer jeden Status unserer Maschine:
// Wenn die Funktion 0 zurueckliefert, geht die Maschine in den naechsten
// Zustand, sonst bleibt sie im gleichen Zustand.

int fahren (int magnet)
{
    if (!debounced_read (magnet, &debounce_magnet))
    {
        return 1;
    }
    if (timer.is_reached (millis ()))
    {
        motor_aus  ();
        timer.stop ();
        errmsg = "Zeitueberschreitung fahren";
        status = STATUS_ERROR;
        return 0;
    }
    return 0;
}

int starte_rauffahren ()
{
    if (digitalRead (MAGNET_UNTEN))
    {
        errmsg = "Hochfahren: Tuere nicht unten";
        status = STATUS_ERROR;
        return 0;
    }
    timer.start (millis (), FAHRZEIT_MS);
    debounce_magnet = 0;
    rechtsrum ();
    motor_an  ();
    return 1;
}

int rauffahren ()
{
    return fahren (MAGNET_OBEN);
}

int starte_runterfahren ()
{
    if (digitalRead (MAGNET_OBEN))
    {
        errmsg = "Hochfahren: Tuere nicht oben";
        status = STATUS_ERROR;
        return 0;
    }
    timer.start (millis (), FAHRZEIT_MS);
    debounce_magnet = 0;
    linksrum  ();
    motor_an  ();
    return 1;
}

int runterfahren ()
{
    return fahren (MAGNET_UNTEN);
}

int nacht ()
{
    int val;
    motor_aus ();
    val = analogRead (FOTO);
    //Serial.println (val);
    if (val > HELL)
    {
        timer.start (millis ());
        return 1;
    }
    return 0;
}

int tag ()
{
    int val;
    motor_aus ();
    val = analogRead (FOTO);
    //Serial.println (val);
    if (val < FINSTER)
    {
        timer.start (millis ());
        return 1;
    }
    return 0;
}

int abend ()
{
    int val;
    motor_aus ();
    val = analogRead (FOTO);
    if (val > FINSTER)
    {
        status = STATUS_TAG;
        return 0;
    }
    if (timer.is_reached (millis ()))
    {
        timer.stop ();
        return 1;
    }
    return 0;
}

int morgen ()
{
    int val;
    motor_aus ();
    val = analogRead (FOTO);
    if (val < HELL)
    {
        status = STATUS_NACHT;
        return 0;
    }
    if (timer.is_reached (millis ()))
    {
        timer.stop ();
        return 1;
    }
    return 0;
}

// Bevor wir die Tuer aufmachen warten wir bis es fuer die Nachbarn (und
// uns) zumutbar ist, dass der Hahn zu kraehen anfaengt. Solange wir die
// Tuer nicht aufmachen ist es dunkel genug (und schallgedaemmt). Wir
// warten bis 4:30 UTC, das ist 6:30 CEST.
int warte_auf_nachbarn ()
{
    time_t time = clock.time ();
    struct tm *tm;
    motor_aus ();

    return 1;
    if (time < 0)
    {
        return 1;
    }
    tm = gmtime (&time);
    if (tm->tm_hour > 4 || tm->tm_hour == 4 && tm->tm_min >= 45)
    {
        return 1;
    }
    return 0;
}

int error ()
{
    motor_aus ();
    digitalWrite (ERROR_LED, HIGH);
    Serial.println (errmsg);
    delay (100);
    return 0;
}

# undef int
struct state {
    int status;
    int next_status;
    int (*statefun)();
};

// Stati muessen in der Reihenfolge der numerischen Zustandswerte sein
// Zustaende muessen lueckenlos nummeriert sein
struct state stati [] =
{ { STATUS_TAG,          STATUS_ABEND,        tag                 }
, { STATUS_ABEND,        STATUS_START_RUNTER, abend               }
, { STATUS_NACHT,        STATUS_MORGEN,       nacht               }
, { STATUS_MORGEN,       STATUS_NACHBARN,     morgen              }
, { STATUS_NACHBARN,     STATUS_START_RAUF,   warte_auf_nachbarn  }
, { STATUS_START_RAUF,   STATUS_RAUFFAHREN,   starte_rauffahren   }
, { STATUS_RAUFFAHREN,   STATUS_TAG,          rauffahren          }
, { STATUS_START_RUNTER, STATUS_RUNTERFAHREN, starte_runterfahren }
, { STATUS_RUNTERFAHREN, STATUS_NACHT,        runterfahren        }
, { STATUS_ERROR,        STATUS_ERROR,        error               }
};

void setup ()
{
    pinMode (LED,         OUTPUT);
    pinMode (ERROR_LED,   OUTPUT);
    pinMode (MAGNET_OBEN,  INPUT);
    pinMode (MAGNET_UNTEN, INPUT);
    pinMode (MOTOR,       OUTPUT);
    pinMode (MOTOR_DIR1,  OUTPUT);
    pinMode (MOTOR_DIR2,  OUTPUT);
    pinMode (KNOPF_RUNTER, INPUT);
    pinMode (KNOPF_RAUF,   INPUT);

    digitalWrite (MOTOR,   LOW);
    linksrum ();
    digitalWrite (LED,     HIGH);

    digitalWrite (MAGNET_OBEN,  HIGH); // enable pull-up resistor
    digitalWrite (MAGNET_UNTEN, HIGH); // enable pull-up resistor
    digitalWrite (KNOPF_RUNTER, HIGH); // enable pull-up resistor
    digitalWrite (KNOPF_RAUF,   HIGH); // enable pull-up resistor
    Serial.begin (115200);
}

void loop ()
{
    struct state *st = &stati [status];
    if (!debounced_read (KNOPF_RUNTER, &debounce_knopf_runter))
    {
        debounce_knopf_runter = 10;
        linksrum  ();
        motor_an  ();
        neuinitialisieren = 1;
        return;
    }
    else if (!debounced_read (KNOPF_RAUF, &debounce_knopf_rauf))
    {
        debounce_knopf_rauf = 10;
        rechtsrum ();
        motor_an  ();
        neuinitialisieren = 1;
        return;
    }
    else if (neuinitialisieren)
    {
        motor_aus ();
        errmsg = "Unbekannte Tuerposition bei Start";
        status = STATUS_ERROR;
        if (!digitalRead (MAGNET_OBEN))
        {
            status = STATUS_TAG;
            digitalWrite (ERROR_LED, LOW);
        }
        else if (!digitalRead (MAGNET_UNTEN))
        {
            status = STATUS_NACHT;
            digitalWrite (ERROR_LED, LOW);
        }
        neuinitialisieren = 0;
        debounce_knopf_rauf = debounce_knopf_runter = 0;
        if (!clock.is_valid ())
        {
            status = STATUS_ERROR;
            errmsg = "Error initializing clock";
        }
        if (FINSTER >= HELL)
        {
            status = STATUS_ERROR;
            errmsg = "FINSTER >= HELL";
        }
        Serial.print ("Initialized to: ");
        Serial.println (status);
        return;
    }
    // Hard-coded error state must work if state-table is broken
    if (status >= STATUS_ERROR)
    {
        error ();
        return;
    }
    if (st->status != status)
    {
        status = STATUS_ERROR;
        sprintf
            ( errbuf
            , "Error in state-table, expected %d got %d"
            , status
            , st->status
            );
        errmsg = errbuf;
        return;
    }
    if (st->statefun ())
    {
        status = st->next_status;
    }
    if (status != st->status)
    {
        sprintf (errbuf, "new state: %d->%d", st->status, status);
        Serial.println (errbuf);
    }
}
