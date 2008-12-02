#include <timer.h>
#include <stdio.h>

# define LED          13
# define MAGNET_OBEN   8
# define MAGNET_UNTEN  7
# define FOTO          0
# define MOTOR         9
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
# define STATUS_START_RAUF   4
# define STATUS_RAUFFAHREN   5
# define STATUS_START_RUNTER 6
# define STATUS_RUNTERFAHREN 7
# define STATUS_ERROR        8

int status   = STATUS_ERROR;
char errbuf [80];
char *errmsg = "";
int neuinitialisieren = 1;

# define TIMER_MS       10000 // 10 seconds debounce 300000 // 5 minutes
# define FAHRZEIT_MS    20000 // max 20 seconds for up/down of door
Arduino_Timer timer (TIMER_MS);

void motor_an ()
{
    digitalWrite (LED,   HIGH);
    //digitalWrite (MOTOR, HIGH);
}

void motor_aus ()
{
    digitalWrite (LED,   LOW);
    digitalWrite (MOTOR, LOW);
}

void linksrum ()
{
    digitalWrite (MOTOR_DIR1, HIGH);
    digitalWrite (MOTOR_DIR2, LOW);
}

void rechtsrum ()
{
    digitalWrite (MOTOR_DIR1, LOW);
    digitalWrite (MOTOR_DIR2, HIGH);
}

// Wir benutzen Status-Funktionen fuer jeden Status unserer Maschine:
// Wenn die Funktion 0 zurueckliefert, geht die Maschine in den naechsten
// Zustand, sonst bleibt sie im gleichen Zustand.

int fahren (int magnet)
{
    if (!digitalRead (magnet))
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

int error ()
{
    motor_aus ();
    Serial.println (errmsg); 
    delay (1000);
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
, { STATUS_MORGEN,       STATUS_START_RAUF,   morgen              }
, { STATUS_START_RAUF,   STATUS_RAUFFAHREN,   starte_rauffahren   }
, { STATUS_RAUFFAHREN,   STATUS_TAG,          rauffahren          }
, { STATUS_START_RUNTER, STATUS_RUNTERFAHREN, starte_runterfahren }
, { STATUS_RUNTERFAHREN, STATUS_NACHT,        runterfahren        }
, { STATUS_ERROR,        STATUS_ERROR,        error               }
};

void setup ()
{
    pinMode (LED,         OUTPUT);
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
    errmsg = "Unbekannte Tuerposition bei Start";
    if (FINSTER >= HELL)
    {
        status = STATUS_ERROR;
        errmsg = "FINSTER >= HELL";
    }
    Serial.print ("initial state: ");
    Serial.println (status);
}

void loop ()
{
    struct state *st = &stati [status];
    // Hard-coded error state must work if state-table is broken
    if (!digitalRead (KNOPF_RUNTER))
    {
        Serial.println ("LINKSRUM");
        linksrum  ();
        motor_an  ();
        neuinitialisieren = 1;
        return;
    }
    else if (!digitalRead (KNOPF_RAUF))
    {
        Serial.println ("RECHTSRUM");
        rechtsrum ();
        motor_an  ();
        neuinitialisieren = 1;
        return;
    }
    else if (neuinitialisieren)
    {
        motor_aus ();
        status = STATUS_ERROR;
        if (!digitalRead (MAGNET_OBEN))
        {
            status = STATUS_TAG;
        }
        else if (!digitalRead (MAGNET_UNTEN))
        {
            status = STATUS_NACHT;
        }
        neuinitialisieren = 0;
        return;
    }
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
        if (status != st->status)
        {
            sprintf (errbuf, "new state: %d->%d", st->status, status); 
            Serial.println (errbuf);
        }
    }
}
