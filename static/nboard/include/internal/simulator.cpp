#include "simulator.h"

extern "C" {

int main();

SimulatorFuncs* funcs;

void pin_mode(uint8_t pin, InternalPinMode mode){
  return funcs->pin_mode(pin, mode);
}

void set_pin(uint8_t pin, uint8_t state){
  return funcs->set_pin(pin, state);
}

void toggle_pin(uint8_t pin){
  return funcs->toggle_pin(pin);
}

uint8_t read_pin(uint8_t pin){
  return funcs->read_pin(pin);
}

void set_bus(uint8_t pins[16], uint16_t state){
  return funcs->set_bus(pins, state);
}

void error(const char* msg){
  return funcs->error(msg);
}

void wait(float s){
  return funcs->wait(s);
}

void wait_ms(int32_t ms){
  return funcs->wait_ms(ms);
}

void wait_us(int32_t us){
  return funcs->wait_us(us);
}

uint64_t get_current_time(){
  return funcs->get_current_time();
}

void pwm_freq(uint8_t pin, float freq){
  return funcs->pwm_freq(pin, freq);
}

void pwm_rcy(uint8_t pin, float rcy){
  return funcs->pwm_rcy(pin, rcy);
}

uint16_t read_ana(uint8_t pin){
  return funcs->read_ana(pin);
}

void write_ana(uint8_t pin, uint16_t value){
  return funcs->write_ana(pin, value);
}

void can_write(uint16_t ident, uint8_t size, uint8_t *tab_data){
  return funcs->can_write(ident, size, tab_data);
}

uint8_t get_jog(){
  return funcs->get_jog();
}

int8_t get_cod(){
  return funcs->get_cod();
}

}

__declspec(dllexport) void internal_main(SimulatorFuncs* f) {
  funcs = f;

  main();
}