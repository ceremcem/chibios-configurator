#include "main.h"

int main(void) {
  halInit();
  chSysInit();
  init_io();
  adcStart(&ADCD1, NULL);
  
  
  gptStart(&GPTD1, &gptCfg1);
  gptStartContinuous(&GPTD1, 10000);
  // adcStartConversionI is fired within the gptCallback1 function.
    // ---------------- END OF BOILERPLATE  -------------------------
}
void adcReadCallback1(ADCDriver *adcp, adcsample_t *buffer, size_t n)
{
  (void) adcp;
  (void) n;
  for (uint8_t i = 0; i < ADC_CH_NUM; i++){
    // do something with buffer[i]
  }
}

static void gptCallback1(GPTDriver *gptp)
{
  (void) gptp;
  // Note: Use only I-Class functions
  adcStartConversionI(&ADCD1, &adcgrpcfg1, samples_buf1, ADC_BUF_DEPTH);
}
