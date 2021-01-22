#include "ch.h"
#include "hal.h"
#include "io.h"

extern void init_io(void); // defined in io.c

{{#if halUse.includes("ADC")}}
void {{adc.callback}}(ADCDriver *adcp, adcsample_t *buffer, size_t n);
{{#adc.useGpt}}
static void {{adc.gpt.callback}}(GPTDriver *gptp);
{{/}}

#define ADC_BUF_DEPTH 1 
#define ADC_CH_NUM {{adc.CHSEL.length}}    // How many channel you use at same time

// Create buffer to store ADC results. 
// This is a one-dimensional interleaved array
static adcsample_t {{adc.bufferName}}[ADC_BUF_DEPTH * ADC_CH_NUM];

// See os/hal/ports/STM32/LLD/ADCv1/hal_adc_lld.h
// for available ADCConversionGroup fields.
static const ADCConversionGroup {{adc.conf}} = {
  circular : {{#adc.isContinuous}}TRUE{{else}}FALSE{{/}},
  num_channels : ADC_CH_NUM,
  end_cb : {{adc.callback}},
  error_cb : NULL,
  cfgr1 : {{#adc.cfgr1}}{{.}}{{#@index !== @last}} \
            | {{/}}{{/each}},
    
  // Treshold Register 
  tr: ADC_TR(0, 0),                                       

  smpr : {{adc.samplingRate('28 cycles')}},

  // See ADC channel selection register (ADC_CHSELR) in RM
  chselr: {{#adc.CHSEL}}{{.}}{{#@index !== @last}} \
            | {{/}}{{/each}}
};
{{/if}}

{{#if adc.useGpt}}
static const GPTConfig {{adc.gpt.conf}} = {
  frequency:    {{adc.gpt.freq}}U, // Hz
  callback:     {{adc.gpt.callback}},
  cr2:          0,
  dier:         0U
};
{{/if}}