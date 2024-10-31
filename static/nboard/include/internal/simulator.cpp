#include "simulator.h"

int main();

SimulatorFuncs* funcs;

extern "C" __declspec(dllexport) void internal_main(SimulatorFuncs* f) {
  funcs = f;

  main();
}

void set_signal(PinName pin, uint8_t signal){
  return funcs->set_signal(pin, signal);
}

uint8_t read_signal(PinName pin){
  return funcs->read_signal(pin);
}

void set_bus(PinName pins[16], uint16_t signal){
  return funcs->set_bus(pins, signal);
}

uint16_t read_bus(PinName pins[16]){
  return funcs->read_bus(pins);
}

void* debug(void* v){
  return funcs->debug(v);
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

void pwm_period(PinName pin, int32_t period){
  return funcs->pwm_period(pin, period);
}

void pwm_rcy(PinName pin, float rcy){
  return funcs->pwm_rcy(pin, rcy);
}

void pwm_pulse(PinName pin, int32_t pulse){
  return funcs->pwm_pulse(pin, pulse);
}

float read_ana(){
  return funcs->read_ana();
}

uint16_t readu16_ana(){
  return funcs->readu16_ana();
}

void can_write(CAN_Message* msg){
  return funcs->can_write(msg);
}

unsigned char get_jog(){
  return funcs->get_jog();
}

unsigned char get_cod(){
  return funcs->get_cod();
}