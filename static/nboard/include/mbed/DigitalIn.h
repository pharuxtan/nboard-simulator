#ifndef MBED_DIGITALIN_H
#define MBED_DIGITALIN_H

#include "PinNames.h"
#include "PinNamesTypes.h"
#include "simulator.h"

namespace mbed {

class DigitalIn {

public:
  DigitalIn(PinName pin) : _pin(pin) {}

  DigitalIn(PinName pin, PinMode mode) : _pin(pin), _mode(mode) {}

  int read()
  {
    uint8_t val = read_signal(_pin);
    switch(_mode){
      case PullUp:
        return val ? 0 : 1;
      case PullDown:
        return val ? 1 : 0;
      default:
        break;
    }
    return 1;
  }

  void mode(PinMode pull)
  {
    _mode = pull;
  }

  operator int(){
    return read();
  }

private:
  PinName _pin;
  PinMode _mode = PullNone;
};

}

#endif