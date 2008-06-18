// Implements a polled timer. Reached is called with the current polling
// time and evaluates to true if the end-time was reached since the last
// poll.
class ArduinoTimer
{
    public:
        ArduinoTimer  ();
        ~ArduinoTimer () {};

        void Start   (unsigned long now, unsigned long duration);
        void Stop    ();
        bool Reached (unsigned long now);
    private:
        static const unsigned long MODULUS = 34359738UL;
        bool started;
        unsigned long last;
        unsigned long end;
};
