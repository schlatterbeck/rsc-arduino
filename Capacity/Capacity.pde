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
 *  220 ohm resistor between dischargePin and common point
 *  Wire between common point and analogPin (A/D input)
 */

#define analogPin      0          // analog pin for measuring capacitor voltage
#define dischargePin   7          // pin to discharge the capacitor
#define MAX (sizeof (resistors) / sizeof (float))

byte chargePins [] = {4, 5, 6};
// change this to whatever resistor values you are using
float resistors [] = {10000.0, 100000.0, 1000000.0};

unsigned long startTime;
unsigned long elapsedTime;
float microFarads;                // floating point variable to preserve
                                  // precision, make calculations
float nanoFarads;

void setup()
{
    // init chargePins
    for (int i=0; i<MAX; i++)
    {
        pinMode (chargePins [i], INPUT);
        digitalWrite (chargePins [i], LOW); // no pull-up
    }
    pinMode (dischargePin, INPUT);    // don't discharge at start
    digitalWrite (dischargePin, LOW); // no pull-up
    Serial.begin(9600);               // initialize serial transmission
    Serial.println ("Starting");
}

void loop(){
    int x;
    for (int j=0; j<MAX; j++)
    {
        for (int i=0; i<MAX; i++)
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
        pinMode(dischargePin, INPUT);

        pinMode(chargePins [j], OUTPUT);
        digitalWrite (chargePins [j], HIGH); // charge
        startTime = millis ();               // .. and start timer

        // 647 is 63.2% of 1023, which corresponds to full-scale voltage :
        while (analogRead (analogPin) < 648)
            {}

        elapsedTime = millis() - startTime;
        // convert milliseconds to seconds ( 10^-3 )
        // and Farads to microFarads ( 10^6 ),  net 10^3 (1000)  
        microFarads = ((float) elapsedTime / resistors [j]) * 1000.0;   
        if (elapsedTime <= 1 and j >= MAX-1)
        {
            Serial.println ("Capacitor too small to measure");
            break;
        }
        if (elapsedTime < 100 and j < MAX-1)
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

