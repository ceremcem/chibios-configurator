#ifndef _BOARD_H_
#define _BOARD_H_

/*
 * MCU type
 */
#define STM32F103x8
#define STM32F103xB // temporary, see the PR

// See pal_default_config in board.c in order to see what variables to set

/*
 * IO pins assignments.
 */
/* GPIOA */
#define GPIOA_PWM1_3        10u
#define GPIOA_0             0u
#define GPIOA_1             1u
#define GPIOA_2             2u
#define GPIOA_3             3u
#define GPIOA_4             4u

/*
 * I/O Assignment
 *
 * Refer to board.c/hw_init_io for additional settings
 *
 * Please refer to the STM32 Reference Manual for details.
 */

#include "stm32f103_init_io.h"
/*
 * Mass settings
 */
// Port A setup
#define VAL_GPIOACRL            CR_DEFAULT      /*  PA7...PA0 */
#define VAL_GPIOACRH            CR_DEFAULT      /* PA15...PA8 */
#define VAL_GPIOAODR            ODR_DEFAULT

// Port B setup
#define VAL_GPIOBCRL            CR_DEFAULT      /*  PA7...PA0 */
#define VAL_GPIOBCRH            CR_DEFAULT      /* PA15...PA8 */
#define VAL_GPIOBODR            ODR_DEFAULT

// Port C setup
#define VAL_GPIOCCRL            CR_DEFAULT      /*  PA7...PA0 */
#define VAL_GPIOCCRH            CR_DEFAULT      /* PA15...PA8 */
#define VAL_GPIOCODR            ODR_DEFAULT

// Port D setup
#define VAL_GPIODCRL            CR_DEFAULT      /*  PA7...PA0 */
#define VAL_GPIODCRH            CR_DEFAULT      /* PA15...PA8 */
#define VAL_GPIODODR            ODR_DEFAULT

// Port E setup
#define VAL_GPIOECRL            CR_DEFAULT      /*  PA7...PA0 */
#define VAL_GPIOECRH            CR_DEFAULT      /* PA15...PA8 */
#define VAL_GPIOEODR            ODR_DEFAULT

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
