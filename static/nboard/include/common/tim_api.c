/**
 ******************************************************************************
 * @file	tim_api.c
 * @author	Bruno LARNAUDIE, Pauline MICHEL
 * @brief	Bibliothèque de gestion des TIM.
 *
 * 			/!\ Le TIM2 est utilisé par cette bibliothèque et ne peut donc pas
 * 			être utilisé pour d'autres fonctions (PWM, encodeur, ...).
 *
 ******************************************************************************
 */

#include "tim_api.h"

/* Fonctions attente bloquante ***********************************************/
void TIM_wait_ms(uint32_t time_ms)
{
  wait_ms(time_ms);
}
void TIM_wait_us(uint32_t time_us)
{
  wait_us(time_us);
}
/* Fonctions timer "chronomètre" *********************************************/
bool internal_tim_stopped = true;
uint64_t internal_tim_current = 0;
uint64_t internal_tim_final = 0;
void TIM_start(void)
{
  if(internal_tim_stopped) internal_tim_current = get_current_time();
  internal_tim_stopped = false;
}
void TIM_stop(void)
{
  if(internal_tim_stopped) return;
  internal_tim_final = get_current_time() - internal_tim_current;
  internal_tim_stopped = true;
}
void TIM_reset(void)
{
  internal_tim_current = get_current_time();
}
uint32_t TIM_read_ms(void)
{
  if(!internal_tim_stopped) internal_tim_final = get_current_time() - internal_tim_current;
  return internal_tim_final / 1e3;
}
uint32_t TIM_read_us(void)
{
  if(!internal_tim_stopped) internal_tim_final = get_current_time() - internal_tim_current;
  return internal_tim_final;
}
/* Fonction timer avec interruption périodique *******************************/
// void TIM_attach_isr_ms(uint32_t period_ms, void (*f)(void));
/* Fonction timer avec interruption après une attente ************************/
// void TIM_timeout_ms(uint32_t delay_ms, void (*f)(void));
