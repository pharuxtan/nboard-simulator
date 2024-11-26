/**
 ******************************************************************************
 * @file	nb_dac_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion du DAC (convertisseur numérique /
 * 			analogique) sur la NBoard.
 * 			Cette bibliothèque permet de :
 *			+ écrire la valeur d'une sortie analogique.
 *
 * @todo	03/10/2024 : à compléter pour la compatibilité avec d'autres cartes
 *			que la NBoard.
 *
 ******************************************************************************
 */

#include "nboard.h"

/**
 * @brief	Configure une pin de la NBoard en sortie analogique. Sur la NBoard,
 * 			la seule sortie analogique disponible est PA_4.
 * @param	uint8_t la pin à configurer en sortie analogique
 * @retval
 */
void NB_DAC_output(uint8_t pin)
{
  pin_mode(pin, PIN_MODE_DAC);
}

/**
 * @brief	Ecrit la valeur d'une sortie analogique. Sur la NBoard, la seule
 * 			sortie analogique disponible est PA_4.
 * @param	uint8_t la sortie à utiliser
 * @param	uint16_t la valeur numérique à convertir en tension (grandeur
 * 			analogique)
 * @retval
 */
void NB_DAC_write(uint8_t pin, uint16_t value)
{
	/* Sur la NBoard, la seule sortie analogique disponible est sur PA_4. */
	write_ana(pin, value);
};
