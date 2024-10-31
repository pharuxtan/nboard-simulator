/* mbed Microcontroller Library
 * Copyright (c) 2006-2013 ARM Limited
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef MBED_PWMOUT_H
#define MBED_PWMOUT_H

#include "PinNames.h"
#include "simulator.h"

namespace mbed {

class PwmOut {

public:

    /** Create a PwmOut connected to the specified pin
     *
     *  @param pin PwmOut pin to connect to
     */
    PwmOut(PinName pin) : _pin(pin)
    {
    }

    /** Set the output duty-cycle, specified as a percentage (float)
     *
     *  @param value A floating-point value representing the output duty-cycle,
     *    specified as a percentage. The value should lie between
     *    0.0f (representing on 0%) and 1.0f (representing on 100%).
     *    Values outside this range will be saturated to 0.0f or 1.0f.
     */
    void write(float value)
    {
        pwm_rcy(_pin, value);
    }

    /** Set the PWM period, specified in seconds (float), keeping the duty cycle the same.
     *
     *  @param seconds Change the period of a PWM signal in seconds (float) without modifying the duty cycle
     *  @note
     *   The resolution is currently in microseconds; periods smaller than this
     *   will be set to zero.
     */
    void period(float seconds)
    {
        pwm_period(_pin, seconds * 1.0e6);
    }

    /** Set the PWM period, specified in milliseconds (int), keeping the duty cycle the same.
     *  @param ms Change the period of a PWM signal in milliseconds without modifying the duty cycle
     */
    void period_ms(int ms)
    {
        pwm_period(_pin, ms * 1000);
    }

    /** Set the PWM period, specified in microseconds (int), keeping the duty cycle the same.
     *  @param us Change the period of a PWM signal in microseconds without modifying the duty cycle
     */
    void period_us(int us)
    {
        pwm_period(_pin, us);
    }

    /** Set the PWM pulsewidth, specified in seconds (float), keeping the period the same.
     *  @param seconds Change the pulse width of a PWM signal specified in seconds (float)
     */
    void pulsewidth(float seconds)
    {
        pwm_pulse(_pin, seconds * 1.0e6);
    }

    /** Set the PWM pulsewidth, specified in milliseconds (int), keeping the period the same.
     *  @param ms Change the pulse width of a PWM signal specified in milliseconds
     */
    void pulsewidth_ms(int ms)
    {
        pwm_pulse(_pin, ms * 1000);
    }

    /** Set the PWM pulsewidth, specified in microseconds (int), keeping the period the same.
     *  @param us Change the pulse width of a PWM signal specified in microseconds
     */
    void pulsewidth_us(int us)
    {
        pwm_pulse(_pin, us);
    }

    /** A operator shorthand for write()
     *  \sa PwmOut::write()
     */
    PwmOut &operator= (float value)
    {
        // Underlying call is thread safe
        write(value);
        return *this;
    }

private:
  PinName _pin;
  float rcy;
};

} // namespace mbed


#endif
