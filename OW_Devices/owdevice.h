#ifndef owdevice_h
#define owdevice_h

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

// Wraps OneWire Dallas/Maxim Devices
class OW_Device
{
    public:
        // If addr is specified, no search is performed
        // If ONEWIRE_SEARCH is 0 *and* no addr is given, we use the
        // Read ROM one-wire command. This only works if there's only a
        // single device on the one-wire bus!
        OW_Device  (OneWire &device, uint8_t *addr = 0, uint8_t id = 0x27);
        ~OW_Device () {};

        const uint8_t        *get_addr (void);
        bool                  is_valid (void) { return _is_valid; }
        const uint8_t * const get_buf  (void);
    protected:
        uint8_t  _addr [8];
        uint8_t  _buf  [10]; // temp storage for commands
        OneWire &_device;
        bool     _is_valid;
};
#endif // owdevice_h
