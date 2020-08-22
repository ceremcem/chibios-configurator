# Format: 
#   STM_CODE(REGEX): [{TYPE: HUMAN_READABLE_NAME}, ...]
export replace-map = 
    "GPIO"                      : 
        * din: "Digital Input" 
        * dout: "Digital Output"
    "TIM([0-9]+)_CH([0-9]+)(N?)$"   :
        * pwm: "PWM $1_$2$3"
        * timer: "Timer $1_$2$3"
    "ADC_IN([0-9]+)"            : adc-in: "Analog Input $1"
    "I2C([0-9]+)_SCL"           : i2c-clock: "I2C ($1) Clock"
    "I2C([0-9]+)_SDA"           : i2c-data: "I2C ($1) Data"
    "SYS_SWCLK"                 : swclk: "SWD Clock"
    "SYS_SWDIO"                 : swdio: "SWD I/O"


export peripheralConfigs =
    din:
        * {id: \pullup, name: "Pull up"}
        * {id: \pulldown, name: "Pull down"}
        * {id: \float, name: "Float"}

    dout:
        * {id: \pushpull, name: "Push-pull"}
        * {id: \opencollector, name: "Open collector"}
