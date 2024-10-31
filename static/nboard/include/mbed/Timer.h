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
#ifndef MBED_TIMER_H
#define MBED_TIMER_H

#include "simulator.h"
#include "stdint.h"

namespace mbed {

class Timer {

public:
    Timer(){
      stopped = true;
    };

    /** Start the timer
     */
    void start()
    {
      if(stopped) current = get_current_time();
      stopped = false;
    };

    /** Stop the timer
     */
    void stop()
    {
      if(stopped) return;
      final = get_current_time() - current;
      stopped = true;
    };

    /** Reset the timer to 0.
     *
     * If it was already running, it will continue
     */
    void reset()
    {
      current = get_current_time();
    };

    /** Get the time passed in seconds
     *
     *  @returns    Time passed in seconds
     */
    float read()
    {
      if(!stopped) final = get_current_time() - current;
      return (float)final / 1.0e6;
    };

    /** Get the time passed in milliseconds
     *
     *  @returns    Time passed in milliseconds
     */
    int read_ms()
    {
      if(!stopped) final = get_current_time() - current;
      return final / 1e3;
    };

    /** Get the time passed in microseconds
     *
     *  @returns    Time passed in microseconds
     */
    int read_us()
    {
      if(!stopped) final = get_current_time() - current;
      return final;
    };

    /** An operator shorthand for read()
     */
    operator float(){
      return read();
    };

private:
  bool stopped;
  uint64_t current;
  uint64_t final;
};

}; // namespace mbed

#endif
