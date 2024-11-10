/**
 ******************************************************************************
 * @file	gpio_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des GPIO.
 *
 ******************************************************************************
 */

#include "gpio_api.h"

/* Fonctions initialisation GPIO *********************************************/
void GPIO_input(uint8_t pin, uint8_t mode)
{
  if(mode == PULL_NONE){
    pin_mode(pin, PIN_MODE_INPUT_PULL_NONE);
  } else if(mode == PULL_UP){
    pin_mode(pin, PIN_MODE_INPUT_PULL_UP);
  } else if(mode == PULL_DOWN){
    pin_mode(pin, PIN_MODE_INPUT_PULL_DOWN);
  }
}
void GPIO_output(uint8_t pin)
{
  pin_mode(pin, PIN_MODE_OUTPUT);
}
/* Fonction lecture entrée numérique *****************************************/
uint8_t GPIO_read(uint8_t pin)
{
  return read_pin(pin);
}
/* Fonctions écriture sortie numérique ***************************************/
void GPIO_write(uint8_t pin, uint8_t value)
{
  set_pin(pin, value);
}
void GPIO_toggle(uint8_t pin)
{
  toggle_pin(pin);
}
