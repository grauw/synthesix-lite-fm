;
;
;
Constants: MACRO
	REPT 128, ?value
	db ?value
	ENDM
	ENDM

Constants_instance: Constants
