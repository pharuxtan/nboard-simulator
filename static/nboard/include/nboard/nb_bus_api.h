/**
 ******************************************************************************
 * @file	nb_dac_api.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion du bus de 8 LED (8 sorties numériques) sur
 * 			la NBoard.
 *
 *			/!\ Cette bibliothèque n'est compatible qu'avec la NBoard.
 *
 * @todo	03/10/2024 : est-ce que d'autres cartes utilisées à l'IUT ont un
 * 			bus de LED ? si oui, à compléter pour la compatibilité avec ces
 * 			autres cartes.
 *
 ******************************************************************************
 */

#ifndef INC_NB_BUS_API_H_
#define INC_NB_BUS_API_H_

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonction initialisation bus ***********************************************/
void NB_8LED_output(uint8_t pin7, uint8_t pin6, uint8_t pin5, uint8_t pin4,
		uint8_t pin3, uint8_t pin2, uint8_t pin1, uint8_t pin0);
/* Fonction écriture bus *****************************************************/
void NB_8LED_write(uint8_t value);

#endif /* INC_NB_BUS_API_H_ */
