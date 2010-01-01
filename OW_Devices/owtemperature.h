#ifndef owtemperature_h
#define owtemperature_h

#include "owdevice.h"

// Wraps OneWire Temperature Sensor Dallas/Maxim DS18S20 into its own class
class OW_Temperature : public OW_Device
{
    public:
        OW_Temperature  (OneWire &temperature, uint8_t *addr = 0)
            : OW_Device (temperature, addr, 0x10)
            {};
        ~OW_Temperature () {};

        int16_t  temperature (void);
        uint16_t get_aux     (void);
        void     set_aux     (uint8_t *twobytes);
        void     read_all    (void);

    protected:
        void     start_measure (void);
};
#endif // owtemperature_h
