/* http://arduino.cc/en/Tutorial/CapacitanceMeter */
/*  RCTiming_capacitance_meter (modified RSC)
 *   Paul Badger 2008
 *  Demonstrates use of RC time constants to measure the value of a capacitor 
 *
 * Theory   A capcitor will charge, through a resistor, in one time constant,
 * defined as T seconds where
 *    TC = R * C
 * 
 *    TC = time constant period in seconds
 *    R = resistance in ohms
 *    C = capacitance in farads
 *        (1 microfarad (ufd) = .0000001 farad = 10^-6 farads ) 
 *
 *    The capacitor's voltage at one time constant is defined as 63.2%
 *    of the charging voltage.
 *
 *  Hardware setup:
 *  Test Capacitor between common point and ground (positive side of an
 *  electrolytic capacitor  to common)
 *  Test Resistor between chargePin and common point
 *  We try 10k, 100k, 1M Ohm Resistors until we get a count > 100 or
 *  have reached the hightes Resistor.
 *  100 ohm resistor between dischargePin and common point
 *  Wire between common point and analogPin (A/D input)
 * 
 * For measuring low-capacities: We use an NE555 clock chip in astable
 * mode and use the arduino frequency counter for measuring the
 * frequency. The frequency depends on the capacitor:
 *
 *     f = 1 / (ln (2) * C * (R1 + 2R2))
 * we use both R1 = R2 = 1M Ohm, so we get for C:
 *
 *     C = 1 / (ln (2) * f * 3 * R)
 */

#include <debounce.h>
#include <FreqCounter.h>

#define DEBOUNCE_TIME_MS 20

#define analogPin      0          // analog pin for measuring capacitor voltage
#define dischargePin   7          // pin to discharge the capacitor
#define MAX_RESISTORS (sizeof (resistors) / sizeof (float))

byte chargePins [] = {2, 3, 4};
// change this to whatever resistor values you are using
float resistors [] = {10000.0, 100000.0, 1000000.0};

unsigned long startTime;
unsigned long elapsedTime;
float microFarads;                // floating point variable to preserve
                                  // precision, make calculations
float nanoFarads;

Debounced_Input start_high_capacity (10, DEBOUNCE_TIME_MS);
Debounced_Input start_low_capacity  (11, DEBOUNCE_TIME_MS);

void setup ()
{
    // init chargePins

    for (size_t i=0; i<MAX_RESISTORS; i++)
    {
        pinMode (chargePins [i], INPUT);
        digitalWrite (chargePins [i], LOW); // no pull-up
    }
    pinMode (dischargePin, INPUT);    // don't discharge at start
    digitalWrite (dischargePin, LOW); // no pull-up
    Serial.begin (115200);            // initialize serial transmission
    Serial.println ("Starting");
}

void loop ()
{
    int x;
    delay (10); // for debouncer to work (frq counter will turn off timer)
    if (!start_high_capacity.read ())
    {
        for (size_t j=0; j<MAX_RESISTORS; j++)
        {
            for (size_t i=0; i<MAX_RESISTORS; i++)
            {
                pinMode (chargePins [i], INPUT);
                digitalWrite (chargePins [i], LOW); // no pull-up
            }

            /* dicharge the capacitor  */
            digitalWrite (dischargePin, LOW);
            pinMode      (dischargePin, OUTPUT);
            // Wait for discharge
            while ((x = analogRead (analogPin)) > 2)
                { }
            delay (1000);
            pinMode (dischargePin, INPUT);

            pinMode (chargePins [j], OUTPUT);
            digitalWrite (chargePins [j], HIGH); // charge
            startTime = millis ();               // .. and start timer

            // 647 is 63.2% of 1023, which corresponds to full-scale voltage :
            while (analogRead (analogPin) < 648)
                {}

            elapsedTime = millis () - startTime;
            // convert milliseconds to seconds ( 10^-3 )
            // and Farads to microFarads ( 10^6 ),  net 10^3 (1000)  
            microFarads = ((float) elapsedTime / resistors [j]) * 1000.0;   
            if (elapsedTime <= 1 and j >= MAX_RESISTORS-1)
            {
                Serial.println ("Capacitor too small to measure");
                break;
            }
            if (elapsedTime < 100 and j < MAX_RESISTORS-1)
            {
                continue;
            }
            Serial.print ("R=");
            Serial.print ((int)(resistors [j] / 1000));
            Serial.print ("k ");

            Serial.print (elapsedTime);       // print the value to serial port
            Serial.print (" mS    ");         // print units and carriage return

            if (microFarads > 1){
                Serial.print   (microFarads);
                Serial.println (" uF");
            }
            else
            {
                nanoFarads = microFarads * 1000.0;
                Serial.print   (nanoFarads);
                Serial.println (" nF");
            }
            break;
        }
    }
    if (!start_low_capacity.read ())
    {
        float c = 0;
        const char *unit = " pF";
        // FreqCounter::f_comp = 10; // frq compensation
        FreqCounter::start (1000);
        while (FreqCounter::f_ready == 0)
            ;
        c = 1000000.0 / (0.69314718055994529 * FreqCounter::f_freq * 3);
        if (c > 1000)
        {
            c /= 1000;
            unit = " nF";
        }
        Serial.print (c);
        Serial.println (unit);
    }
} 
