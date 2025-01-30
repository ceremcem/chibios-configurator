# Description

Generates ChibiOS configurations.

# Live Demo

https://aktos.io/chibi-config/

# Development 

1. Setup your environment: (see ./scada.js/doc/using-virtual-environment.md)
2. `./scada.js/venv`
3. Install dependencies: `make install-deps`

### Production: 

```
make release-build
exit
./production.service
```

### Development: 
4. `./ui-dev.service`
5. Use your favourite text editor to edit files.
3. Open http://localhost:4013 to see the application. 
