/**
 ******************************************************************************
 * @file	tim_api.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des TIM.
 *
 * 			/!\ Le TIM2 est utilisé par cette bibliothèque et ne peut donc pas
 * 			être utilisé pour d'autres fonctions (PWM, encodeur, ...).
 *
 ******************************************************************************
 */

#ifndef INC_TIM_API_H_
#define INC_TIM_API_H_

#include "stdbool.h"
#include "stdint.h"
#include "simulator.h"

/******************* TYPES STRUCTURES ****************************************/

/**
 * @brief	Définition de la structure TIM_ticker pour gérer une interruption
 *			périodique
 */
typedef struct
{
	uint32_t previous_tick; /*!< Spécifie la date (en ticks) du dernier
	 déclenchement de l'interruption périodique. */
	uint32_t period_ms; /*!< Spécifie la période (en ms) de déclenchement de
	 l'interruption périodique. */
	void (*isr)(void); /*!< Spécifie la routine d'interruption à
	 déclencher. */
} T_TIM_ticker;

/**
 * @brief	Définition de la structure TIM_timeout pour gérer une interruption
 *			à déclencher après une attente
 */
typedef struct
{
	uint32_t start_tick; /*!< Spécifie la date (en ticks) du démarrage de
	 l'attente. */
	uint32_t delay_ms; /*!< Spécifie le délai d'attente (en ms) avant le
	 déclenchement de l'interruption. */
	void (*isr)(void); /*!< Spécifie la routine d'interruption à
	 déclencher. */
} T_TIM_timeout;

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonctions attente bloquante ***********************************************/
void TIM_wait_ms(uint32_t time_ms);
void TIM_wait_us(uint32_t time_us);
/* Fonctions timer "chronomètre" *********************************************/
void TIM_start(void);
void TIM_stop(void);
void TIM_reset(void);
uint32_t TIM_read_ms(void);
uint32_t TIM_read_us(void);
/* Fonction timer avec interruption périodique *******************************/
// void TIM_attach_isr_ms(uint32_t period_ms, void (*f)(void));
/* Fonction timer avec interruption après une attente ************************/
// void TIM_timeout_ms(uint32_t delay_ms, void (*f)(void));

#endif /* INC_TIM_API_H_ */
