# Format: 
#   STM_CODE(REGEX): Array of: {TYPE: {id, name}}
export replace-map = 
    "GPIO": 
        * din: 
            id: "din"
            name: "Digital Input"
        * dout: 
            id: "dout"
            name: "Digital Output"
    "TIM([0-9]+)_CH([0-9]+)(N?)$":
        * pwm: 
            id: "pwm-$1.$2$3"
            name: "PWM $1-$2$3"
        * timer: 
            id: "timer-$1.$2$3"
            name: "Timer $1_$2$3"
    "ADC_IN([0-9]+)": 
        adc-in:
            id: "adc-in-$1"
            name: "Analog Input $1"
    "I2C([0-9]+)_SCL": 
        i2c-clock: 
            id: "i2c-clock-$1"
            name: "I2C ($1) Clock"
    "I2C([0-9]+)_SDA": 
        i2c-data: 
            id: "i2c-data-$1"
            name: "I2C ($1) Data"
    "SYS_SWCLK": 
        swclk: 
            id: "swclk"
            name: "SW Clock"
    "SYS_SWDIO": 
        swdio: 
            id: "swdio"
            name: "SW Data"
    "USART([0-9]+)_(.+)":
        serial:
            id: "usart-$1-$2"
            name: "USART ($1) $2"


export peripheralConfigs =
    din:
        mode:
            * {id: \pullup,         name: "Pull up"}
            * {id: \pulldown,       name: "Pull down"}
            * {id: \float,          name: "Float"}

    dout:
        mode:
            * {id: \pushpull,       name: "Push-pull"}
            * {id: \opencollector,  name: "Open collector"}

    adc-in:
        conversion: 
            * {id: "onDemand",       name: "On-demand/Periodic Conversion"}
            * {id: "continuous",     name: "Continuous Conversion"}
        # if conversion is onDemand
        poll:
            * id: "manualPolling"
              name: "Manual Polling"
              _tooltip: "User is responsible to call adcStartConversion() manually."
            * id: "periodic"       
              name: "Periodic Polling"
              _tooltip: "Uses a General Purpose Timer"

