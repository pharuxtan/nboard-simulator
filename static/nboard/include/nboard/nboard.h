/**
 ******************************************************************************
 * @file	nboard.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de définition globale pour la NBoard.
 *
 ******************************************************************************
 */

#ifndef INC_NBOARD_H_
#define INC_NBOARD_H_

/******************* BIBLIOTHEQUES *******************************************/

/* Bibliothèques Simulateur **************************************************/
#include "simulator.h"

/* Bibliothèques IUT communes (indépendantes de la carte) ********************/
#include "gpio_api.h"
#include "pinnames.h"
#include "tim_api.h"
#include "pwm_api.h"

/* Bibliothèques IUT spécifiques NBoard **************************************/
#include "ihm_api.h"
#include "nb_adc_api.h"
#include "nb_bus_api.h"
#include "nb_dac_api.h"
#include "nb_api.h"

/* Vos bibliothèques *********************************************************/
// à compléter si besoin

#endif /* INC_NBOARD_H_ */
