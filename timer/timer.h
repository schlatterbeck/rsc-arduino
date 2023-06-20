#ifndef timer_h
#define timer_h

// Implements a polled timer. Reached is called with the current polling
// time and evaluates to true if the end-time was reached since the last
// poll.
class Arduino_Timer
{
    public:
        Arduino_Timer  (unsigned long duration = 0);
        ~Arduino_Timer () {};

        void start      (unsigned long now, unsigned long duration = 0);
        void stop       ();
        bool is_reached (unsigned long now);
        bool is_started ();
    protected:
        // old version for arduino before 0012 overflows at that value
        // static const unsigned long MODULUS = 34359738UL;
        bool started;
        unsigned long start_time;
        unsigned long default_duration;
        unsigned long duration;
};
#endif // timer_h
