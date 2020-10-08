/*
    AKTOS Electronics. 

    License: MIT

*/

#ifndef _BOARD_H_
#define _BOARD_H_

/*
 * Generated for {{mcu.chibiDef}} 
 *
 * Pinout is: 
 {{#each Object.keys(pinout) as pin}}
 *   - {{pin}}: {{pinout[pin].peripheral.name}}
 {{/each}}
 */

#define {{mcu.chibiDef}}
{{#if mcu.chibiDef === 'STM32F030x4'}}
    // see https://github.com/ChibiOS/ChibiOS/pull/31
    #define STM32F030x6 
{{/if}}


/*
 * IO pins assignments.
 */
{{#each pinout}}{{#with pinout[@key] as pin}}
#define {{pin.ioName}}   {{pin.gpioNo}}
{{/with}}{{/each}}

#include "stm32f030_init_io.h" // from chibi-project/include/init-io/ 

{{#each define}}
#define {{.name}}    {{.value}}
{{/each}}

{{#each byGpio}}{{#with byGpio[@key] as pins, @key as GPIOx}}
// {{@key}}
// ------------
{{#each GPIO_REGISTERS as REGISTER}}
#define VAL_{{GPIOx}}_{{REGISTER}}             (0 /* GPIOx_{{REGISTER}}_DEFAULT */ \
                                                {{#each pins as pin}}
                                                | {{pin.registerMacro[REGISTER] || 0}} \
{{/each}}                                               )
{{/each}}{{/with}}{{/each}}


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
