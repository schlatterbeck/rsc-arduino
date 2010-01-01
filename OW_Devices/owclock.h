#ifndef owclock_h
#define owclock_h

#include "owdevice.h"

// Wraps OneWire Clock Dallas/Maxim DS2417 into its own class
class OW_Clock : public OW_Device
{
    public:
        OW_Clock  (OneWire &clock, uint8_t *addr = 0)
            : OW_Device (clock, addr, 0x27)
            {};
        ~OW_Clock () {};

        void           set_time (time_t timestamp);
        time_t         time     (void);
};
#endif // owclock_h
