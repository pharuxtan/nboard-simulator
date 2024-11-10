/**
 ******************************************************************************
 * @file	nb_dac_api.h
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

#ifndef INC_NB_DAC_API_H_
#define INC_NB_DAC_API_H_

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonction écriture sortie analogique ***************************************/
void NB_DAC_write(uint8_t pin, uint16_t value);

#endif /* INC_NB_DAC_API_H_ */
