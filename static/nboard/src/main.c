/******************* BIBLIOTHEQUES *******************************************/

#include "nboard.h"

/******************* CONSTANTES SYMBOLIQUES **********************************/

#define BP0 GPIO_read(PA_9)
#define BP1 GPIO_read(PA_10)
#define BP2 GPIO_read(PB_0)
#define BP3 GPIO_read(PB_7)
#define LED0 PB_3
#define LED1 PA_7
#define LED2 PA_6
#define LED3 PA_5
#define LED4 PA_3
#define LED5 PA_1
#define LED6 PA_0
#define LED7 PA_2

/******************* PROGRAMME PRINCIPAL *************************************/

int main(void)
{
	// Variables locales
  int cpt;
  float pot_read;
  uint32_t tim;

	// Initialisations
	NB_init();
	IHM_LCD_clear();

	// Programme de test de la NBoard + bibliothèque
  NB_ADC_MUX_select(7);

  TIM_start();

	while (1)
	{
		cpt++;
    cpt %= 0x3FF;
		IHM_BAR_write(cpt);

    pot_read = (float)NB_ADC_read(PB_1) / 4095.0;
    PWM_write(LED1, pot_read);
    PWM_write(LED2, pot_read);
    PWM_write(LED4, pot_read);
    PWM_write(LED5, pot_read);

    GPIO_write(LED0, !BP0);
    GPIO_write(LED3, !BP1);
    GPIO_write(LED6, !BP2);
    GPIO_write(LED7, !BP3);

    tim = TIM_read_ms();

    if(tim > 9900){
      TIM_reset();
    }

    IHM_LCD_locate(0, 0);
    IHM_LCD_printf("POT: %6.2f%% T:%01d", pot_read * 100.0, tim / 1000);
    IHM_LCD_locate(1, 0);
    IHM_LCD_printf("JOG: %02X  COD: %02X", IHM_JOG_read(), (uint8_t)IHM_COD_read());

    TIM_wait_ms(20);
	}
}
