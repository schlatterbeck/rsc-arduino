/* Blinking LED
 * ------------
 *
 * turns on and off a light emitting diode(LED) connected to a digital  
 * pin, in intervals of 2 seconds. Ideally we use pin 13 on the Arduino 
 * board because it has a resistor attached to it, needing only an LED

 *
 * Created 1 June 2005
 * copyleft 2005 DojoDave <http://www.0j0.org>
 * http://arduino.berlios.de
 *
 * based on an orginal by H. Barragan for the Wiring i/o board
 */

int ledPins [3] = {11, 12, 13};

void setup()
{
  int k;
  for (k=0; k<3; k++)
  {
      int ledPin = ledPins [k];
      pinMode(ledPin, OUTPUT); // sets the digital pin as output
  }
}

void loop()
{
  int k;
  for (k=0; k<3; k++)
  {
      int ledPin = ledPins [k];
      digitalWrite(ledPin, HIGH);   // sets the LED on
      delay(5000);                  // waits for a second
      digitalWrite(ledPin, LOW);    // sets the LED off
      delay(5000);                  // waits for a second
  }
}

