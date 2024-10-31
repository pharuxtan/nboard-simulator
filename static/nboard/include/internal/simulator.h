#ifndef _SIMULATOR_H
#define _SIMULATOR_H

#include "stdint.h"
#include "PinNames.h"
#include "CAN.h"

typedef struct SimulatorFuncs {
  void (*set_signal)(PinName pin, uint8_t signal);
  uint8_t (*read_signal)(PinName pin);
  void (*set_bus)(PinName pins[16], uint16_t signal);
  uint16_t (*read_bus)(PinName pins[16]);
  void* (*debug)(void* v);
  void (*wait)(float s);
  void (*wait_ms)(int32_t ms);
  void (*wait_us)(int32_t us);
  uint64_t (*get_current_time)();
  void (*pwm_period)(PinName pin, int32_t period);
  void (*pwm_rcy)(PinName pin, float rcy);
  void (*pwm_pulse)(PinName pin, int32_t pulse);
  float (*read_ana)();
  uint16_t (*readu16_ana)();
  void (*can_write)(CAN_Message* msg);
  unsigned char (*get_jog)();
  unsigned char (*get_cod)();
} SimulatorFuncs;

#ifdef __cplusplus
extern "C" __declspec(dllexport) void internal_main(SimulatorFuncs* f);
#else
void internal_main(SimulatorFuncs* f);
#endif

void set_signal(PinName pin, uint8_t signal);
uint8_t read_signal(PinName pin);
void set_bus(PinName pins[16], uint16_t signal);
uint16_t read_bus(PinName pins[16]);
void* debug(void* v);
void wait(float s);
void wait_ms(int32_t ms);
void wait_us(int32_t us);
uint64_t get_current_time();
void pwm_period(PinName pin, int32_t period);
void pwm_rcy(PinName pin, float rcy);
void pwm_pulse(PinName pin, int32_t pulse);
float read_ana();
uint16_t readu16_ana();
void can_write(CAN_Message* msg);
unsigned char get_jog();
unsigned char get_cod();

typedef void (*PFN_internal_main)(SimulatorFuncs* f);

#endif