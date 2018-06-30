;
;
;
OPLLVoice: MACRO ?msxMusic, ?carrierTremolo, ?carrierVibrato, ?carrierEGMode, ?carrierRateKeyScale, ?carrierWaveform,
                ?carrierMultiplier, ?carrierLevelKeyScale, ?carrierAttack, ?carrierDecay, ?carrierSustain, ?carrierRelease,
                ?modulatorTremolo, ?modulatorVibrato, ?modulatorEGMode, ?modulatorRateKeyScale, ?modulatorWaveform,
                ?modulatorMultiplier, ?modulatorLevel, ?modulatorFeedback, ?modulatorLevelKeyScale, ?modulatorAttack, ?modulatorDecay, ?modulatorSustain, ?modulatorRelease
	WriteRegister: equ ?msxMusic + MSXMusic.WriteRegister
	Update:
		ld a,(?modulatorTremolo)
		rlca
		and 10000000B
		ld d,a
		ld a,(?modulatorVibrato)
		and 01000000B
		or d
		ld d,a
		ld a,(?modulatorEGMode)
		rrca
		and 00100000B
		or d
		ld d,a
		ld a,(?modulatorRateKeyScale)
		rrca
		rrca
		and 00010000B
		or d
		ld d,a
		ld a,(?modulatorMultiplier)
		rrca
		rrca
		rrca
		and 00001111B
		or d
		ld d,a
		ld a,00H
		call WriteRegister
		ld a,(?carrierTremolo)
		and 10000000B
		rlca
		ld d,a
		ld a,(?carrierVibrato)
		and 01000000B
		or d
		ld d,a
		ld a,(?carrierEGMode)
		rrca
		and 00100000B
		or d
		ld d,a
		ld a,(?carrierRateKeyScale)
		rrca
		rrca
		and 00010000B
		or d
		ld d,a
		ld a,(?carrierMultiplier)
		rrca
		rrca
		rrca
		and 00001111B
		or d
		ld d,a
		ld a,01H
		call WriteRegister
		ld a,(?modulatorLevelKeyScale)
		rlca
		and 11000000B
		ld d,a
		ld a,(?modulatorLevel)
		rrca
		cpl
		and 00111111B
		or d
		ld d,a
		ld a,02H
		call WriteRegister
		ld a,(?carrierLevelKeyScale)
		rlca
		and 11000000B
		ld d,a
		ld a,(?carrierWaveform)
		rrca
		rrca
		and 00010000B
		or d
		ld d,a
		ld a,(?modulatorWaveform)
		rrca
		rrca
		rrca
		and 00001000B
		or d
		ld d,a
		ld a,(?modulatorFeedback)
		rrca
		rrca
		rrca
		rrca
		and 00000111B
		or d
		ld d,a
		ld a,03H
		call WriteRegister
		ld a,(?modulatorAttack)
		rlca
		cpl
		and 11110000B
		ld d,a
		ld a,(?modulatorDecay)
		rrca
		rrca
		rrca
		cpl
		and 00001111B
		or d
		ld d,a
		ld a,04H
		call WriteRegister
		ld a,(?carrierAttack)
		rlca
		cpl
		and 11110000B
		ld d,a
		ld a,(?carrierDecay)
		rrca
		rrca
		rrca
		cpl
		and 00001111B
		or d
		ld d,a
		ld a,05H
		call WriteRegister
		ld a,(?modulatorSustain)
		rlca
		cpl
		and 11110000B
		ld d,a
		ld a,(?modulatorRelease)
		rrca
		rrca
		rrca
		cpl
		and 00001111B
		or d
		ld d,a
		ld a,06H
		call WriteRegister
		ld a,(?carrierSustain)
		rlca
		cpl
		and 11110000B
		ld d,a
		ld a,(?carrierRelease)
		rrca
		rrca
		rrca
		cpl
		and 00001111B
		or d
		ld d,a
		ld a,07H
		jp WriteRegister
	ENDM

; ix = this
OPLLVoice_Construct:
	push ix
	call OPLLVoice_Update
	pop ix
	ret

; ix = this
OPLLVoice_Update:
	ld de,OPLLVoice.Update
	add ix,de
	jp ix
