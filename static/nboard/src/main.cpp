#include "IHM.h"

IHM ihm;

DigitalOut led7(PA_2);
DigitalOut led6(PA_0);
PwmOut led5(PA_1);
PwmOut led4(PA_3);
DigitalOut led3(PA_5);
PwmOut led2(PA_6);
PwmOut led1(PA_7);
DigitalOut led0(PB_3);

DigitalIn BP0(PA_9, PullUp);
DigitalIn BP1(PA_10, PullUp);
DigitalIn BP2(PB_0, PullUp);
DigitalIn BP3(PB_7, PullUp); 

BusOut mux(PF_0, PF_1, PA_8);
AnalogIn pot(PB_1);

int main()
{
  int cpt;
  float pot_read;
  
  mux = 0x7;

  led5.period_ms(1000);
  led4.period_ms(1000);
  led2.period_ms(1000);
  led1.period_ms(1000);

  while(1)
  {
    ++cpt %= 0x3FF;
    ihm.BAR_set(cpt);

    pot_read = pot.read();
    led5.write(pot_read);
    led4.write(pot_read);
    led2.write(pot_read);
    led1.write(pot_read);

    led0 = !BP0;
    led3 = !BP1;
    led6 = !BP2;
    led7 = !BP3;

    ihm.LCD_gotoxy(0, 0);
    ihm.LCD_printf("POT: %6.2f%%", pot_read * 100.0);
    ihm.LCD_gotoxy(1, 0);
    ihm.LCD_printf("JOG: %02X  COD: %02X", ihm.JOG_read(), ihm.COD_read());

    wait_ms(20);
  }
}
