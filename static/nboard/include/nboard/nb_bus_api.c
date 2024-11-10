/**
 ******************************************************************************
 * @file	nb_dac_api.c
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

#include "nboard.h"

uint8_t tab_bus_pinnames[8] = { NC, NC, NC, NC, NC, NC, NC, NC };

/* Fonction initialisation bus ***********************************************/
void NB_8LED_output(uint8_t pin7, uint8_t pin6, uint8_t pin5, uint8_t pin4,
                    uint8_t pin3, uint8_t pin2, uint8_t pin1, uint8_t pin0)
{
	tab_bus_pinnames[0] = pin0;
	tab_bus_pinnames[1] = pin1;
	tab_bus_pinnames[2] = pin2;
	tab_bus_pinnames[3] = pin3;
	tab_bus_pinnames[4] = pin4;
	tab_bus_pinnames[5] = pin5;
	tab_bus_pinnames[6] = pin6;
	tab_bus_pinnames[7] = pin7;
}
/* Fonction écriture bus *****************************************************/
void NB_8LED_write(uint8_t value)
{
	uint8_t i = 0;
	for (i = 0; i < 8; i++)
	{
		if (tab_bus_pinnames[i] != NC)
		{
			/* écriture individuelle de chaque sortie numérique du bus */
			GPIO_write(tab_bus_pinnames[i], value & (1 << i));
		}
		else
		{
      error("Le bus de 8 LED a une broche qui n'est pas défini");
		}
	}
}
