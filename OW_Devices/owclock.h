#ifndef owtimer_h
#define owtimer_h

// Work around a bug in arduino environment:
// When it compiles the libs, it seems to find sub-libraries, while
// when compiling the sketch it doesn't. Broken.
// So we *must* include all sub-libs in the main sketch and not try here
// to include the stuff when it's already there.
#ifndef time_h
#include <time.h>
#endif
#ifndef OneWire_h
#include <OneWire.h>
#endif

// Wraps OneWire Clock Dallas/Maxim DS2417 into its own class
class OW_Clock
{
    public:
        // If addr is specified, no search is performed
        // If ONEWIRE_SEARCH is 0 *and* no addr is given, we use the
        // Read ROM one-wire command. This only works if there's only a
        // single device on the one-wire bus!
        OW_Clock  (OneWire &clock, uint8_t *addr = 0);
        ~OW_Clock () {};

        const uint8_t *get_addr (void);
        bool           is_valid (void) { return _is_valid; }
        void           set_time (time_t timestamp);
        time_t         time     (void);
    private:
        uint8_t *_addr;
        uint8_t  _buf  [8];
        OneWire &_clock;
        bool     _is_valid;
};
#endif // owtimer_h
