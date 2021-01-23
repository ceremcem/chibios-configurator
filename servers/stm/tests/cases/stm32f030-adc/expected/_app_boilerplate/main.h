#include "ch.h"
#include "hal.h"
#include "io.h"

extern void init_io(void); // defined in io.c
void adcReadCallback1(ADCDriver *adcp, adcsample_t *buffer, size_t n);
static void gptCallback1(GPTDriver *gptp);

#define ADC_BUF_DEPTH 1 
#define ADC_CH_NUM 1    // How many channel you use at same time

// Create buffer to store ADC results. 
// This is a one-dimensional interleaved array
static adcsample_t samples_buf1[ADC_BUF_DEPTH * ADC_CH_NUM];

// See os/hal/ports/STM32/LLD/ADCv1/hal_adc_lld.h
// for available ADCConversionGroup fields.
static const ADCConversionGroup adcgrpcfg1 = {
  circular : FALSE,
  num_channels : ADC_CH_NUM,
  end_cb : adcReadCallback1,
  error_cb : NULL,
  cfgr1 : ADC_CFGR1_RES_12BIT,
    
  // Treshold Register 
  tr: ADC_TR(0, 0),                                       

  smpr : ADC_SMPR_SMP_13P5,

  // See ADC channel selection register (ADC_CHSELR) in RM
  chselr: ADC_CHSELR_CHSEL1
};

static const GPTConfig gptCfg1 = {
  frequency:    100000U, // Hz
  callback:     gptCallback1,
  cr2:          0,
  dier:         0U
};
