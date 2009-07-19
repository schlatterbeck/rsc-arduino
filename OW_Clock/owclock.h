#ifndef owtimer_h
#define owtimer_h

#include <time.h>
#include <OneWire.h>

// Wraps OneWire Clock Dallas/Maxim DS2417 into its own class
class OW_Clock
{
    public:
        // If addr is specified, no search is performed
        // If ONEWIRE_SEARCH is 0 *and* no addr is given, we use the
        // Read ROM one-wire command. This only works if there's only a
        // single device on the one-wire bus!
        OW_Clock  (char *addr = 0);
        ~OW_Clock () {};

        const char *get_addr (void);
        bool        is_valid (void) { return _is_valid; }
        void        set_time (time_t timestamp);
        time_t      time     (void);
    private:
        bool _is_valid;
        char _addr [8];
};
#endif // owtimer_h
