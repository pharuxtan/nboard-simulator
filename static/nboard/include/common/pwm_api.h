/**
 ******************************************************************************
 * @file	pwm_api.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des PWM.
 *
 ******************************************************************************
 */

#ifndef INC_PWM_API_H_
#define INC_PWM_API_H_

#include "simulator.h"

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonctions initialisation PWM *********************************************/
void PWM_output(uint8_t pin, float frequency_in_hz);
/* Fonctions écriture rapport cyclique **************************************/
void PWM_write(uint8_t pin, float duty_cycle);

#endif /* INC_PWM_API_H_ */
