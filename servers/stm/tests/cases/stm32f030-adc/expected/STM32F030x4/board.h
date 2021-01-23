/*
    AKTOS Electronics. 

    License: MIT

*/

#ifndef _BOARD_H_
#define _BOARD_H_

/*
 * Generated for STM32F030x4 
 *
 * Pinout is: 
 *   - 6: Digital Output
 *   - 7: Analog Input 1
 *   - 19: SW Data
 *   - 20: SW Clock
 */

#define STM32F030x4
    // see https://github.com/ChibiOS/ChibiOS/pull/31
    #define STM32F030x6 
/*
 * IO pins assignments.
 */

#define PA0_DOUT   0

#define PA1_ADCIN   1

#define PA13_SWDIO   13

#define PA14_SWCLK   14


#include "stm32f030_init_io.h" // from chibi-project/include/init-io/ 
#define PA13_AF0_SYS_SWDIO    0
#define PA14_AF0_SYS_SWCLK    0

// GPIOF
// ------------
#define VAL_GPIOF_MODER             (0 /* GPIOx_MODER_DEFAULT */ \
                                               )
#define VAL_GPIOF_OTYPER             (0 /* GPIOx_OTYPER_DEFAULT */ \
                                               )
#define VAL_GPIOF_OSPEEDR             (0 /* GPIOx_OSPEEDR_DEFAULT */ \
                                               )
#define VAL_GPIOF_PUPDR             (0 /* GPIOx_PUPDR_DEFAULT */ \
                                               )
#define VAL_GPIOF_ODR             (0 /* GPIOx_ODR_DEFAULT */ \
                                               )
#define VAL_GPIOF_AFRL             (0 /* GPIOx_AFRL_DEFAULT */ \
                                               )
#define VAL_GPIOF_AFRH             (0 /* GPIOx_AFRH_DEFAULT */ \
                                               )

// GPIOA
// ------------
#define VAL_GPIOA_MODER             (0 /* GPIOx_MODER_DEFAULT */ \
                                                | PIN_MODE_OUTPUT(PA0_DOUT) \
                                                | PIN_MODE_ANALOG(PA1_ADCIN) \
                                                | PIN_MODE_ALTERNATE(PA13_SWDIO) \
                                                | PIN_MODE_ALTERNATE(PA14_SWCLK) \
                                               )
#define VAL_GPIOA_OTYPER             (0 /* GPIOx_OTYPER_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                               )
#define VAL_GPIOA_OSPEEDR             (0 /* GPIOx_OSPEEDR_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | PIN_OSPEED_40M(PA13_SWDIO) \
                                                | 0 \
                                               )
#define VAL_GPIOA_PUPDR             (0 /* GPIOx_PUPDR_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | PIN_PUPDR_PULLUP(PA13_SWDIO) \
                                                | PIN_PUPDR_PULLDOWN(PA14_SWCLK) \
                                               )
#define VAL_GPIOA_ODR             (0 /* GPIOx_ODR_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                               )
#define VAL_GPIOA_AFRL             (0 /* GPIOx_AFRL_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                                | 0 \
                                               )
#define VAL_GPIOA_AFRH             (0 /* GPIOx_AFRH_DEFAULT */ \
                                                | 0 \
                                                | 0 \
                                                | PIN_AFIO_AF(PA13_SWDIO, PA13_AF0_SYS_SWDIO) \
                                                | PIN_AFIO_AF(PA14_SWCLK, PA14_AF0_SYS_SWCLK) \
                                               )

// GPIOB
// ------------
#define VAL_GPIOB_MODER             (0 /* GPIOx_MODER_DEFAULT */ \
                                               )
#define VAL_GPIOB_OTYPER             (0 /* GPIOx_OTYPER_DEFAULT */ \
                                               )
#define VAL_GPIOB_OSPEEDR             (0 /* GPIOx_OSPEEDR_DEFAULT */ \
                                               )
#define VAL_GPIOB_PUPDR             (0 /* GPIOx_PUPDR_DEFAULT */ \
                                               )
#define VAL_GPIOB_ODR             (0 /* GPIOx_ODR_DEFAULT */ \
                                               )
#define VAL_GPIOB_AFRL             (0 /* GPIOx_AFRL_DEFAULT */ \
                                               )
#define VAL_GPIOB_AFRH             (0 /* GPIOx_AFRH_DEFAULT */ \
                                               )



#if !defined(_FROM_ASM_)
#ifdef __cplusplus
extern "C" {
#endif
  void boardInit(void);
#ifdef __cplusplus
}
#endif
#endif /* _FROM_ASM_ */

#endif /* _BOARD_H_ */
