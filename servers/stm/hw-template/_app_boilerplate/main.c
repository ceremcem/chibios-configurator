#include "main.h"

int main(void) {
  halInit();
  chSysInit();
  init_io();
  {{#if halUse.includes("ADC")}}
  adcStart(&{{adc.driver}}, NULL);
  {{/if}}
  {{#adc.isContinuous}}
  adcStartConversion(&{{adc.driver}}, &{{adc.conf}}, {{adc.bufferName}}, ADC_BUF_DEPTH);
  {{else}}
  adcConvert(&{{adc.driver}}, &{{adc.conf}}, {{adc.bufferName}}, ADC_BUF_DEPTH);
  {{/}}
  // ---------------- APP CODE STARTS HERE -------------------------
  
}

{{#if halUse.includes("ADC")}}
void {{adc.callback}}(ADCDriver *adcp, adcsample_t *buffer, size_t n)
{
  (void) adcp;
  (void) n;
  for (uint8_t i = 0; i < ADC_CH_NUM; i++){
    // do something with buffer[i]
  }
}
{{/if}}