#ifndef _SIMULATOR_H
#define _SIMULATOR_H

#include "stdint.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum : uint8_t {
  PIN_MODE_NONE,
  PIN_MODE_OUTPUT,
  PIN_MODE_INPUT_PULL_UP,
  PIN_MODE_INPUT_PULL_DOWN,
  PIN_MODE_INPUT_PULL_NONE,
  PIN_MODE_PWM,
} InternalPinMode;

typedef struct SimulatorFuncs {
  void (*pin_mode)(uint8_t pin, InternalPinMode mode);
  void (*set_pin)(uint8_t pin, uint8_t state);
  void (*toggle_pin)(uint8_t pin);
  uint8_t (*read_pin)(uint8_t pin);
  void (*set_bus)(uint8_t pins[16], uint16_t state);
  void (*error)(const char* msg);
  void (*wait)(float s);
  void (*wait_ms)(int32_t ms);
  void (*wait_us)(int32_t us);
  uint64_t (*get_current_time)();
  void (*pwm_freq)(uint8_t pin, float freq);
  void (*pwm_rcy)(uint8_t pin, float rcy);
  uint16_t (*read_ana)(uint8_t pin);
  void (*write_ana)(uint8_t pin, uint16_t value);
  void (*can_write)(uint16_t ident, uint8_t size, uint8_t *tab_data);
  uint8_t (*get_jog)();
  int8_t (*get_cod)();
} SimulatorFuncs;

void pin_mode(uint8_t pin, InternalPinMode mode);
void set_pin(uint8_t pin, uint8_t state);
void toggle_pin(uint8_t pin);
uint8_t read_pin(uint8_t pin);
void set_bus(uint8_t pins[16], uint16_t state);
void error(const char* msg);
void wait(float s);
void wait_ms(int32_t ms);
void wait_us(int32_t us);
uint64_t get_current_time();
void pwm_freq(uint8_t pin, float freq);
void pwm_rcy(uint8_t pin, float rcy);
uint16_t read_ana(uint8_t pin);
void write_ana(uint8_t pin, uint16_t value);
void can_write(uint16_t ident, uint8_t size, uint8_t *tab_data);
uint8_t get_jog();
int8_t get_cod();

typedef void (*PFN_internal_main)(SimulatorFuncs* f);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" __declspec(dllexport) void internal_main(SimulatorFuncs* f);
#else
void internal_main(SimulatorFuncs* f);
#endif

#endif