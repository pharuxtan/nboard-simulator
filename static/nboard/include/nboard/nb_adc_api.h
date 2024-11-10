/**
 ******************************************************************************
 * @file	nb_adc_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion de l'ADC (convertisseur analogique /
 * 			numérique) sur la NBoard.
 * 			Cette bibliothèque permet de :
 *			+ lire la valeur d'une entrée analogique.
 *
 * @todo	03/10/2024 : à compléter pour la compatibilité avec d'autres cartes
 *			que la NBoard.
 *
 ******************************************************************************
 */

#include "nboard.h"

/**
 * @brief	Sélectionne une entrée analogique de la NBoard en configurant le
 * 			multiplexeur analogique.
 * @param	uint8_t la voie du multiplexeur à sélectionner
 * @retval
 */
void NB_ADC_MUX_select(uint8_t value);

/**
 * @brief	Lit la valeur d'une entrée analogique.
 * @param	uint8_t l'entrée à lire
 * @retval	uint16_t le résultat de la conversion de la tension (grandeur
 * 			analogique) en entrée
 */
uint16_t NB_ADC_read(uint8_t pin);
