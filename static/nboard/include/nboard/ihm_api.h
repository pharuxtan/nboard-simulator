/**
 ******************************************************************************
 * @file	ihm_api.h
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * 			sur la base de la bibliothèque développée par Jacques-Olivier KLEIN
 * 			et Bruno LARNAUDIE pour la XBoard
 * @brief	Bibliothèque de gestion de l'IHM de la NBoard (passant par le bus
 * 			CAN).
 *
 * @todo	03/10/2024 : à généraliser pour la compatibilité avec le cas d'une
 * 			carte IHM distante (non intégrée à la carte comme c'est le cas sur
 * 			la NBoard)
 *
 ******************************************************************************
 */

#ifndef INC_IHM_API_H_
#define INC_IHM_API_H_

/******************* CONSTANTES SYMBOLIQUES **********************************/

/* Constantes symboliques JOG ************************************************/
/* valeur renvoyée si le Jog est enfoncé (en position de repos) */
#define JOG_MSK_PUSH   (1<<2)
/* valeur renvoyée si le Jog est poussé vers la droite (non enfoncé). */
#define JOG_MSK_RIGHT  (1<<4)
/* valeur renvoyée si le Jog est poussé vers le haut (non enfoncé). */
#define JOG_MSK_UP     (1<<3)
/* valeur renvoyée si le Jog est poussé vers la gauche (non enfoncé). */
#define JOG_MSK_LEFT   (1<<1)
/* valeur renvoyée si le Jog est poussé vers le bas (non enfoncé).*/
#define JOG_MSK_DOWN   1

/******************* PROTOTYPES DE FONCTIONS *********************************/

/* Fonctions écriture LCD ****************************************************/
void IHM_LCD_locate(uint8_t y, uint8_t x);
void IHM_LCD_printf(const char *format, ...);
void IHM_LCD_clear(void);
/* Fonction écriture bargraph ************************************************/
void IHM_BAR_write(uint16_t valeur);
/* Fonctions lectures JOG et COD *********************************************/
uint8_t IHM_JOG_read(void);
int8_t IHM_COD_read(void);

#endif /* INC_IHM_API_H_ */
