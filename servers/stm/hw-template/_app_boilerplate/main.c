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
  {{! On-Demand or Periodic }}
  {{#if adc.useGpt}}
  {{! Periodic (by using GPT) }}
  gptStart(&{{adc.gpt.driver}}, &{{adc.gpt.conf}});
  gptStartContinuous(&{{adc.gpt.driver}}, {{adc.gpt.waitTicksPerCall}});
  // adcStartConversionI is fired within the {{adc.gpt.callback}} function.
  {{else}}
  // Please manually call the following function on demand: 
  adcStartConversion(&{{adc.driver}}, &{{adc.conf}}, {{adc.bufferName}}, ADC_BUF_DEPTH);
  //Note: If no callbacks necessary, use adcConvert(...) instead.
  {{/if}}
  {{/}}
  // ---------------- END OF BOILERPLATE  -------------------------
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
{{#if adc.useGpt}}
static void {{adc.gpt.callback}}(GPTDriver *gptp)
{
  (void) gptp;
  // Note: Use only I-Class functions
  adcStartConversionI(&{{adc.driver}}, &{{adc.conf}}, {{adc.bufferName}}, ADC_BUF_DEPTH);
}
{{/if}}