/**
 ******************************************************************************
 * @file	pwm_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des PWM.
 *
 ******************************************************************************
 */

#include "pwm_api.h"

/* Fonctions initialisation PWM *********************************************/
void PWM_output(uint8_t pin, float frequency_in_hz)
{
  pin_mode(pin, PIN_MODE_PWM);
  pwm_freq(pin, frequency_in_hz);
}
/* Fonctions écriture rapport cyclique **************************************/
void PWM_write(uint8_t pin, float duty_cycle)
{
  pwm_rcy(pin, duty_cycle);
}
