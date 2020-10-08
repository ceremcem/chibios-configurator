{{#each pinout}}{{#with pinout[@key] as pin}}
{{#unless ["swdio", "swclk"].includes(pin.peripheral.type)}}
#define {{pin.gpioPort}}_myvar{{@index}}         {{pin.ioName}}
{{/unless}}
{{/with}}{{/each}}
