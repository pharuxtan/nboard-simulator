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
#ifndef MBED_CAN_H
#define MBED_CAN_H

#include "simulator.h"
#include "stdint.h"
#include "string.h"

/**
 *
 * \enum    CANFormat
 *
 * \brief   Values that represent CAN Format
**/
enum CANFormat {
    CANStandard = 0,
    CANExtended = 1,
    CANAny = 2
};
typedef enum CANFormat CANFormat;

/**
 *
 * \enum    CANType
 *
 * \brief   Values that represent CAN Type
**/
enum CANType {
    CANData   = 0,
    CANRemote = 1
};
typedef enum CANType CANType;

/**
 *
 * \struct  CAN_Message
 *
 * \brief   Holder for single CAN message.
 *
**/
struct CAN_Message {
    unsigned int   id;                 // 29 bit identifier
    unsigned char  data[8];            // Data field
    unsigned char  len;                // Length of data field in bytes
    CANFormat      format;             // Format ::CANFormat
    CANType        type;               // Type ::CANType
};
typedef struct CAN_Message CAN_Message;

void can_write(CAN_Message* msg); // Dummy func

typedef enum {
    IRQ_RX,
    IRQ_TX,
    IRQ_ERROR,
    IRQ_OVERRUN,
    IRQ_WAKEUP,
    IRQ_PASSIVE,
    IRQ_ARB,
    IRQ_BUS,
    IRQ_READY
} CanIrqType;


typedef enum {
    MODE_RESET,
    MODE_NORMAL,
    MODE_SILENT,
    MODE_TEST_LOCAL,
    MODE_TEST_GLOBAL,
    MODE_TEST_SILENT
} CanMode;

typedef void (*can_irq_handler)(uint32_t id, CanIrqType type);

typedef struct can_s can_t;

#ifdef __cplusplus

namespace mbed {
/** \addtogroup drivers */

/** CANMessage class
 *
 * @note Synchronization level: Thread safe
 * @ingroup drivers
 */
class CANMessage : public CAN_Message {

public:
    /** Creates empty CAN message.
     */
    CANMessage() : CAN_Message()
    {
        len    = 8;
        type   = CANData;
        format = CANStandard;
        id     = 0;
        memset(data, 0, 8);
    }

    /** Creates CAN message with specific content.
     *
     *  @param _id      Message ID
     *  @param _data    Mesaage Data
     *  @param _len     Message Data length
     *  @param _type    Type of Data: Use enum CANType for valid parameter values
     *  @param _format  Data Format: Use enum CANFormat for valid parameter values
     */
    CANMessage(unsigned _id, const char *_data, char _len = 8, CANType _type = CANData, CANFormat _format = CANStandard)
    {
        len    = _len & 0xF;
        type   = _type;
        format = _format;
        id     = _id;
        memcpy(data, _data, _len);
    }

    /** Creates CAN remote message.
     *
     *  @param _id      Message ID
     *  @param _format  Data Format: Use enum CANType for valid parameter values
     */
    CANMessage(unsigned _id, CANFormat _format = CANStandard)
    {
        len    = 0;
        type   = CANRemote;
        format = _format;
        id     = _id;
        memset(data, 0, 8);
    }
};

/** A can bus client, used for communicating with can devices
 * @ingroup drivers
 */
class CAN {

public:
    /** Write a CANMessage to the bus.
     *
     *  @param msg The CANMessage to write.
     *
     *  @returns
     *    0 if write failed,
     *    1 if write was successful
     */
    int write(CANMessage msg)
    {
      can_write(&msg);
      return 1;
    }

    enum Mode {
        Reset = 0,
        Normal,
        Silent,
        LocalTest,
        GlobalTest,
        SilentTest
    };

    enum IrqType {
        RxIrq = 0,
        TxIrq,
        EwIrq,
        DoIrq,
        WuIrq,
        EpIrq,
        AlIrq,
        BeIrq,
        IdIrq,

        IrqCnt
    };
};

} // namespace mbed

#endif

#endif    // MBED_CAN_H

