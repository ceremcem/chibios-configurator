all: gen-chibi-headers gen-stm-types gen-supported-types

gen-chibi-headers:
	./gen-chibi-stm-families.sh > chibi-stm-families.txt

gen-stm-types:
	ls stm-db/mcu/ | grep STM32 | cut -f1 -d. > stm-mcu-types.txt

gen-supported-types:
	./run-ls gen-mcu-family-map.ls 2> issues.txt

clean:
	rm *.txt
	rm *.json