# define LED          13
# define MAGNET1       8
# define MAGNET2       7
# define FOTO          0
# define MOTOR         9
# define MOTOR_DIR1    4
# define MOTOR_DIR2    3
# define MOTOR_MIN  0x7F

int direction = 0;
int motor     = MOTOR_MIN;

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

void setup ()
{
    pinMode (LED,        OUTPUT);
    pinMode (MAGNET1,    INPUT);
    pinMode (MAGNET2,    INPUT);
    pinMode (MOTOR,      OUTPUT);
    pinMode (MOTOR_DIR1, OUTPUT);
    pinMode (MOTOR_DIR2, OUTPUT);

    digitalWrite (MOTOR,   LOW);
    linksrum ();
    direction = 0;

    digitalWrite (MAGNET1, HIGH); // enable pull-up resistor
    digitalWrite (MAGNET2, HIGH); // enable pull-up resistor
    Serial.begin (115200);
}

void loop ()
{
    int val   = 0;
    if (!digitalRead (MAGNET1))
    {
        digitalWrite (LED,   HIGH);
        analogWrite  (MOTOR, motor);
    }
    else
    {
        digitalWrite (LED, LOW);
        digitalWrite (MOTOR, LOW);
    }
    delay (1000);
    motor += 0x20;
    if (motor > 0xFF)
    {
        if (direction)
        {
            linksrum ();
        }
        else
        {
            rechtsrum ();
        }
        direction = !direction;
        motor     = MOTOR_MIN;
    }
    //val = analogRead(FOTO);
    Serial.print(motor); 
    Serial.print("/"); 
    Serial.println(direction); 
}
