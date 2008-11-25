//# undef int
//# include <stdio.h>

# define LED          13
# define MAGNET_OBEN   8
# define MAGNET_UNTEN  7
# define FOTO          0
# define MOTOR         9
# define MOTOR_DIR1    4
# define MOTOR_DIR2    3
# define MOTOR_MIN  0x7F

# define HELL         40
# define FINSTER     400

# define STATUS_TAG          0
# define STATUS_NACHT        1
# define STATUS_START_RAUF   2
# define STATUS_RAUFFAHREN   3
# define STATUS_START_RUNTER 4
# define STATUS_RUNTERFAHREN 5
# define STATUS_ERROR        6

int status   = STATUS_NACHT;
char errbuf [80];
char *errmsg = "";

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
    digitalWrite (MOTOR_DIR1, HIGH);
    digitalWrite (MOTOR_DIR2, LOW);
}

void rechtsrum ()
{
    digitalWrite (MOTOR_DIR1, LOW);
    digitalWrite (MOTOR_DIR2, HIGH);
}

// Wir benutzen Status-Funktionen für jeden Status unserer Maschine:
// Wenn die Funktion 0 zurückliefert, geht die Maschine in den nächsten
// Zustand, sonst bleibt sie im gleichen Zustand.

int fahren (int magnet)
{
    if (!digitalRead (MAGNET_OBEN))
    {
        return 1;
    }
    return 0;
}

int starte_rauffahren ()
{
    if (digitalRead (MAGNET_UNTEN))
    {
        errmsg = "Hochfahren: Türe nicht unten";
        status = STATUS_ERROR;
        return 0;
    }
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
        errmsg = "Hochfahren: Türe nicht oben";
        status = STATUS_ERROR;
        return 0;
    }
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
    if (val < HELL)
    {
        return 1;
    }
    return 0;
}

int tag ()
{
    int val;
    motor_aus ();
    val = analogRead (FOTO);
    if (val > FINSTER)
    {
        return 1;
    }
    return 0;
}

int error ()
{
    Serial.println (errmsg); 
    return 0;
}

# undef int
struct state {
    int status;
    int next_status;
    int (*statefun)();
};

// Stati müssen in der Reihenfolge der numerischen Zustandswerte sein
// Zustände müssen lückenlos nummeriert sein
struct state stati [] =
{ { STATUS_TAG,          STATUS_START_RUNTER, tag                 }
, { STATUS_NACHT,        STATUS_START_RAUF,   nacht               }
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

    digitalWrite (MOTOR,   LOW);
    linksrum ();

    digitalWrite (MAGNET_OBEN,  HIGH); // enable pull-up resistor
    digitalWrite (MAGNET_UNTEN, HIGH); // enable pull-up resistor
    Serial.begin (115200);
    if (FINSTER <= HELL)
    {
        status = STATUS_ERROR;
        errmsg = "FINSTER <= HELL";
    }
}

void loop ()
{
    struct state *st = &stati [status];
    // Hard-coded error state must work if state-table is broken
    if (status == STATUS_ERROR)
    {
        error ();
        return;
    }
    if (st->status != status)
    {
        status = STATUS_ERROR;
//        sprintf 
//            ( errbuf
//            , "Error in state-table, expected %d got %d"
//            , status
//            , st->status
//            );
//        errmsg = errbuf;
        return;
    }
    if (st->statefun ())
    {
        status = st->next_status;
    }
}
