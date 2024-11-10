/**
 ******************************************************************************
 * @file	nb_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque d'initialisation de la NBoard.
 * 			Cette bibliothèque permet de :
 *			+ initialiser la NBoard selon votre application (en TP SN, en SAE
 *			robot, ...).
 *
 ******************************************************************************
 */

#include "nboard.h"

/**
 * @brief	Initialise la NBoard.
 * @param
 * @retval
 */
void NB_init(void)
{
	/******************* NE PAS TOUCHER **************************************/
  
	/******************* Contrôle du mux *************************************/

	/* Initialisation des entrées de sélection du mux en sorties numériques */
	GPIO_output(PF_0);
	GPIO_output(PF_1);
	GPIO_output(PA_8);

	/*************************************************************************/

	/******************* A REMPLIR : ENTREES NUMERIQUES **********************/

	GPIO_input(PA_9, PULL_UP);
	GPIO_input(PA_10, PULL_UP);
	GPIO_input(PB_7, PULL_UP);
	GPIO_input(PB_0, PULL_UP);

	/*************************************************************************/

	/******************* A REMPLIR : SORTIES NUMERIQUES **********************/

	GPIO_output(PA_0);
	GPIO_output(PA_2);
	GPIO_output(PA_5);
	GPIO_output(PB_3);

	/*************************************************************************/

	/******************* A REMPLIR : BUS SORTIES NUMERIQUES ******************/

	/*************************************************************************/

	/******************* A REMPLIR : ENTREES ANALOGIQUES *********************/

	/*************************************************************************/

	/******************* A REMPLIR : SORTIES ANALOGIQUES *********************/

	/*************************************************************************/

	/******************* A REMPLIR : PWM *************************************/

  PWM_output(PA_1, 1);
  PWM_output(PA_3, 1);
  PWM_output(PA_6, 1);
  PWM_output(PA_7, 1);

	/*************************************************************************/

	/******************* A REMPLIR : TIMER ***********************************/

	/*************************************************************************/
}
