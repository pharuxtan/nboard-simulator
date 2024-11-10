/**
 ******************************************************************************
 * @file	gpio_api.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des GPIO.
 *
 ******************************************************************************
 */

#ifndef INC_GPIO_API_H_
#define INC_GPIO_API_H_

/******************* CONSTANTES SYMBOLIQUES **********************************/
#include "simulator.h"
#include "stm32f3xx_hal_gpio.h"

/* Constantes symboliques résistance de tirage *******************************/
#define PULL_NONE	GPIO_NOPULL
#define PULL_UP		GPIO_PULLUP
#define PULL_DOWN	GPIO_PULLDOWN

/* Constantes symboliques front de déclenchement interruption ****************/
#define RISING_EDGE		GPIO_MODE_IT_RISING			// front montant
#define FALLING_EDGE	GPIO_MODE_IT_FALLING		// front descendant
#define ANY_EDGE		GPIO_MODE_IT_RISING_FALLING	// tout front

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonctions initialisation GPIO *********************************************/
void GPIO_input(uint8_t pin, uint8_t mode);
void GPIO_output(uint8_t pin);
/* Fonction lecture entrée numérique *****************************************/
uint8_t GPIO_read(uint8_t pin);
/* Fonctions écriture sortie numérique ***************************************/
void GPIO_write(uint8_t pin, uint8_t value);
void GPIO_toggle(uint8_t pin);

#endif /* INC_GPIO_API_H_ */
