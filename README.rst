.. image:: http://sflogo.sourceforge.net/sflogo.php?group_id=844678&type=7
    :height: 62
    :width: 210
    :alt: SourceForge.net Logo
    :target: http://sourceforge.net/projects/rsc-arduino


Various Arduino Projects
========================

:Author: Ralf Schlatterbeck <rsc@runtux.com>

Libraries:
----------

Libraries need to be installed in the hardware/libraries directory of the
unpacked arduino software.

- OneWire: Stolen somewhere off the net and fixed device discovery,
  BSD-style copyright
- OW_Devices: Builds on top of OneWire and encapsulates different
  devices (in particular a temperature sensor Dallas/Maxim DS18S20 and a
  realtime-clock Dallas/Maxim DS2417)
- FreqCounter library by Martin Nawrath, someday I'll change this to be
  more object-oriented...
- time: gmtime implementation for arduino
- timer: polled timer and debounced digital inputs for arduino

Projects:
---------

Projects are arduino sketches and need to be installed into your arduino
``sketchbook.path``.

- Capacity: Measure capacity with two methods: By loading via a resistor
  and measuring the time (for capacities down to about 10 nF) and by
  using a NE555 as oscillator with known resistors and using a
  frequency-counter (from about 100nF down to some pF)
- huehner: Chicken door, see http://blog.runtux.com/2009/01/08/54/ (in
  german), improved software and hardware compared to the above
  blog-entry (added an error-LED and a one-wire clock)
- onewireclock: Software to display and set the one-wire realtime clock
  DS2417
- temperature: temperature measurement with DS18S20
- water: Small box to switch electric valves for watering the garden,
  this switches 220V electric valves with opto-couplers, so I'm not
  making the schematics available because you need to know what you're
  doing with these voltages

License:
--------

Every file that doesn't have an explicit license in the file itself is covered
by the GNU General Public License version 3.0 (GPLv3) or higher.
http://www.gnu.org/copyleft/gpl.html

Changes
-------

Version 0.2: Fixes for newer Arduino development package

- Fix various problems with obsolete include files
- Fix several compiler warnings

Version 0.1: Initial Release

Initial Release of Arduino Software.

- Initial Release
