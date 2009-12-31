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

// Wraps OneWire Temperature Sensor Dallas/Maxim DS18S20 into its own class
class OW_Temperature
{
    public:
        // If addr is specified, no search is performed
        // If ONEWIRE_SEARCH is 0 *and* no addr is given, we use the
        // Read ROM one-wire command. This only works if there's only a
        // single device on the one-wire bus!
        OW_Temperature  (OneWire &temperature, uint8_t *addr = 0);
        ~OW_Temperature () {};

        const uint8_t *get_addr    (void);
        bool           is_valid    (void) { return _is_valid; }
        time_t         temperature (void);
    private:
        uint8_t *_addr;
        uint8_t  _buf  [8];
        OneWire &_temperature;
        bool     _is_valid;
};
#endif // owtimer_h
