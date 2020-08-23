#!/bin/bash

CHIBIOS=${1:-$HOME/curr-projects/aktos/chibi-examples2/ChibiOS}
find $CHIBIOS/os/common/ext/ST/ -type f -exec basename {} \;
