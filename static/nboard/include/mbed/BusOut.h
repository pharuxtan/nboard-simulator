#ifndef MBED_BUSOUT_H
#define MBED_BUSOUT_H

#include "DigitalOut.h"
#include "PinNames.h"
#include "simulator.h"

namespace mbed {

class BusOut {

public:
  BusOut(PinName p0, PinName p1 = NC, PinName p2 = NC, PinName p3 = NC,
         PinName p4 = NC, PinName p5 = NC, PinName p6 = NC, PinName p7 = NC,
         PinName p8 = NC, PinName p9 = NC, PinName p10 = NC, PinName p11 = NC,
         PinName p12 = NC, PinName p13 = NC, PinName p14 = NC, PinName p15 = NC){
    _pins[0] = p0;
    _pins[1] = p1;
    _pins[2] = p2;
    _pins[3] = p3;
    _pins[4] = p4;
    _pins[5] = p5;
    _pins[6] = p6;
    _pins[7] = p7;
    _pins[8] = p8;
    _pins[9] = p9;
    _pins[10] = p10;
    _pins[11] = p11;
    _pins[12] = p12;
    _pins[13] = p13;
    _pins[14] = p14;
    _pins[15] = p15;
  }

  BusOut(PinName pins[16]){
    for(uint8_t i=0; i<16; i++){
      _pins[i] = pins[i];
    }
  }

  void write(int value){
    set_bus(_pins, value);
  }

  int read()
  {
    return read_bus(_pins);
  }

  BusOut &operator= (int value){
    write(value);
    return *this;
  }

  BusOut &operator= (BusOut &rhs){
    write(rhs.read());
    return *this;
  }

  operator int(){
    return read();
  }

private:
  PinName _pins[16];
};

}

#endif