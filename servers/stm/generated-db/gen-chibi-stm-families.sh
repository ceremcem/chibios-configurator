#!/bin/bash
# Description: 
# Generates ChibiOS MCU family definitions for board.h
set -u
CHIBIOS=$1
cd $CHIBIOS

# see http://www.chibios.com/forum/viewtopic.php?f=2&t=5511&p=38572#p38577
find -name stm32_registry.h -exec cat {} \; \
    | tr ' ' '\n' \
    | grep -oP '(?<=defined\()STM32.+(?=\))' \
    | sort \
    | uniq 

