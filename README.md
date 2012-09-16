Device Design Duck Hunt
=======================

Duck Hunt built in Python using processing.py, with support for a custom built
input "gun" using an [Adafruit 3-axis
accelerometer](http://www.adafruit.com/products/163). Players are identified
by the UID of a MiFare Classic 1K NFC tag, as read by a [PN532 NFC
reader](http://adafruit.com/products/364). The accelerometer input is
processed by an Arduino, the code for which is included in `arduino/`.

This was a homework project for CS294-84 "Device Design" at UC Berkeley, Fall 2012.

Authors
-------

* [Chris Thompson](http://www.cs.berkeley.edu/~cthompson)
* [Daniel Haas](http://www.cs.berkeley.edu/~dhaas)

Acknowledgments
---------------

Accelerometer Duck Hunt uses the wonderful
[processing.py](http://github.com/jdf/processing.py). The game code itself was
forked early on from [a Processing
sketch](http://www.openprocessing.org/sketch/5927), but it's hardly
recognizable now (ported to pyprocessing and then to processing.py). The duck
sprite is from willdurand's [DuckHunt](https://github.com/willdurand/DuckHunt)
project on GitHub.

Requirements
------------

The only outside requirement is that you have [libnfc](http://www.libnfc.org/)
installed on your system, and the nfc-poll example is compiled and in your
path. We have only tested against the PN532-uart on Mac OS 10.8 using
libnfc-1.6 following [the instructions for making them work
together](http://www.ladyada.net/wiki/tutorials/products/rfidnfc/libnfc.html).

License
-------

All parts of this program are under the GNU Public License Version 2 (GPLv2),
except for the included processing.py, which is under the Apache License.
