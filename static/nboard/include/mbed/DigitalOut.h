#ifndef MBED_DIGITALOUT_H
#define MBED_DIGITALOUT_H

#include "PinNames.h"
#include "simulator.h"

namespace mbed {

class DigitalOut {

public:
  DigitalOut(PinName pin) : _pin(pin) {}

  void write(int value){
    set_signal(_pin, value);
  }

  int read()
  {
    return read_signal(_pin);
  }

  DigitalOut &operator= (int value){
    write(value);
    return *this;
  }

  DigitalOut &operator= (DigitalOut &rhs){
    write(rhs.read());
    return *this;
  }

  operator int(){
    return read();
  }

private:
  PinName _pin;
};

}

#endif