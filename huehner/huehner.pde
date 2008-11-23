# define LED 13
# define MAGNET1 8
# define MAGNET2 9

void setup ()
{
    pinMode (LED,     OUTPUT);
    pinMode (MAGNET1, INPUT);
    pinMode (MAGNET2, INPUT);
    digitalWrite (MAGNET1, HIGH); // enable pull-up resistor
    digitalWrite (MAGNET2, HIGH); // enable pull-up resistor
}

void loop ()
{
    if (!digitalRead (MAGNET1))
    {
        digitalWrite (LED, HIGH);
    }
    else
    {
        digitalWrite (LED, LOW);
    }
}
