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
 * @brief	Sélectionne l'entrée du multiplexeur analogique qui sera reliée à
 * 			l'unique entrée analogique (PB_1) de la NBoard.
 * @param	uint8_t le numéro de la voie d'entrée du multiplexeur analogique à
 * 			utiliser (0 à 7)
 * @retval
 */
void NB_ADC_MUX_select(uint8_t value)
{
	/* Le multiplexeur analogique de la NBoard est un multiplexeur 8 vers 1. */
	if(value < 8)
	{
		/* écriture des entrées de sélection du mux = sorties numériques vues
		 * de la NBoard */
		GPIO_write(PA_8, (value>>2)&0x01);
		GPIO_write(PF_1, (value>>1)&0x01);
		GPIO_write(PF_0, (value)&0x01);
	}
	else
	{
    error("La valeur donné pour le multiplexeur est trop élevé");
	}
}

/**
 * @brief	Configure une pin de la NBoard en entrée analogique.
 * @param	uint8_t la pin à configurer en entrée analogique
 * @retval
 */
void NB_ADC_input(uint8_t pin)
{
  pin_mode(pin, PIN_MODE_ADC);
}

/**
 * @brief	Lit la valeur d'une entrée analogique.
 * @param	uint8_t l'entrée à lire
 * @retval	uint16_t le résultat de la conversion de la tension (grandeur
 * 			analogique) en entrée
 */
uint16_t NB_ADC_read(uint8_t pin)
{
	/* Sur la NBoard, la seule entrée analogique disponible est sur PB_1. */
	return read_ana(pin);
}
