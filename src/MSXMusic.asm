;
; MSX-MUSIC YM2413 OPLL driver
;
MSXMusic_ADDRESS: equ 7CH
MSXMusic_DATA: equ 7DH
MSXMusic_ID_ADDRESS: equ 4018H
MSXMusic_ENABLE_ADDRESS: equ 7FF6H
MSXMusic_FREQUENCY: equ 3579545

MSXMusic: MACRO ?channel1, ?channel2, ?channel3, ?channel4, ?channel5, ?channel6, ?channel7, ?channel8, ?channel9, ?channel10, ?channel11
	this:
	slot:
		db 0
	internal:
		db 0

	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
	; a = register
	; d = value
	WriteRegister:
		out (MSXMusic_ADDRESS),a
		in a,(MSXMusic_ADDRESS)  ; wait 12 cycles
		in a,(MSXMusic_ADDRESS)  ;  "
		ld a,d
		out (MSXMusic_DATA),a
		in a,(09AH)  ; R800 wait: ~72 cycles
		in a,(09AH)
		ret

	voice: OPLLVoice this, ?channel1.controllers + 80, ?channel1.controllers + 81, ?channel1.controllers + 82, ?channel1.controllers + 83, ?channel1.controllers + 84,
	                       ?channel1.controllers + 16, ?channel1.controllers + 19, ?channel1.controllers + 20, ?channel1.controllers + 21, ?channel1.controllers + 22, ?channel1.controllers + 23,
	                       ?channel1.controllers + 88, ?channel1.controllers + 89, ?channel1.controllers + 90, ?channel1.controllers + 91, ?channel1.controllers + 92,
	                       ?channel1.controllers + 24, ?channel1.controllers + 25, ?channel1.controllers + 26, ?channel1.controllers + 27, ?channel1.controllers + 28, ?channel1.controllers + 29, ?channel1.controllers + 30, ?channel1.controllers + 31
	tone1: OPLLTone this, 0, ?channel1.program, ?channel1.volume, ?channel1.gate, ?channel1.trigger, ?channel1.note, ?channel1.noteFraction, ?channel1.sustain
	tone2: OPLLTone this, 1, ?channel2.program, ?channel2.volume, ?channel2.gate, ?channel2.trigger, ?channel2.note, ?channel2.noteFraction, ?channel2.sustain
	tone3: OPLLTone this, 2, ?channel3.program, ?channel3.volume, ?channel3.gate, ?channel3.trigger, ?channel3.note, ?channel3.noteFraction, ?channel3.sustain
	tone4: OPLLTone this, 3, ?channel4.program, ?channel4.volume, ?channel4.gate, ?channel4.trigger, ?channel4.note, ?channel4.noteFraction, ?channel4.sustain
	tone5: OPLLTone this, 4, ?channel5.program, ?channel5.volume, ?channel5.gate, ?channel5.trigger, ?channel5.note, ?channel5.noteFraction, ?channel5.sustain
	tone6: OPLLTone this, 5, ?channel6.program, ?channel6.volume, ?channel6.gate, ?channel6.trigger, ?channel6.note, ?channel6.noteFraction, ?channel6.sustain
	tone7: OPLLTone this, 6, ?channel7.program, ?channel7.volume, ?channel7.gate, ?channel7.trigger, ?channel7.note, ?channel7.noteFraction, ?channel7.sustain
	tone8: OPLLTone this, 7, ?channel8.program, ?channel8.volume, ?channel8.gate, ?channel8.trigger, ?channel8.note, ?channel8.noteFraction, ?channel8.sustain
	tone9: OPLLTone this, 8, ?channel9.program, ?channel9.volume, ?channel9.gate, ?channel9.trigger, ?channel9.note, ?channel9.noteFraction, ?channel9.sustain

	Update:
		call voice.Update
		call tone1.Update
		call tone2.Update
		call tone3.Update
		call tone4.Update
		call tone5.Update
		call tone6.Update
		call tone7.Update
		call tone8.Update
		jp tone9.Update
	ENDM

; a = slot
; b = internal
; ix = this
MSXMusic_Construct:
	ld (ix + MSXMusic.slot),a
	ld (ix + MSXMusic.internal),b
	call MSXMusic_Enable
	call MSXMusic_Reset
	ret

; ix = this
MSXMusic_Destruct:
	call MSXMusic_Mute
	call MSXMusic_Disable
	ret

; e = register
; d = value
; ix = this
MSXMusic_WriteRegister:
	ld a,e
	ld bc,MSXMusic.WriteRegister
	JP_OFFSET ix,bc

; ix = this
MSXMusic_Enable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	set 0,a
	ld e,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; ix = this
MSXMusic_Disable:
	bit 0,(ix + MSXMusic.internal)
	ret nz
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_ReadSlot
	res 0,a
	ld e,a
	ld a,(ix + MSXMusic.slot)
	ld hl,MSXMusic_ENABLE_ADDRESS
	call Memory_WriteSlot
	ret

; b = count
; e = register base
; d = value
; ix = this
MSXMusic_FillRegisters:
	push bc
	push de
	call MSXMusic_WriteRegister
	in a,(09AH)  ; R800 wait: ~62 cycles - 5 (ret)
	pop de
	pop bc
	inc e
	djnz MSXMusic_FillRegisters
	ret

; ix = this
MSXMusic_Mute:
	ld de,000EH
	call MSXMusic_WriteRegister  ; rhythm off
	ld de,0F07H
	call MSXMusic_WriteRegister  ; max carrier release rate
	ld b,9
	ld de,0F30H
	call MSXMusic_FillRegisters  ; instrument 0, min volume
	ld b,9
	ld de,0010H
	call MSXMusic_FillRegisters  ; frequency 0
	ld b,9
	ld de,0020H
	call MSXMusic_FillRegisters  ; key off
	ret

; ix = this
MSXMusic_Reset:
	ld b,39H
	ld de,0000H
	call MSXMusic_FillRegisters
	ret

; f <- c: found
; a <- slot
; b <- 0: external, -1: internal
MSXMusic_Detect:
	ld hl,MSXMusic_MatchInternalID
	call Memory_SearchSlots
	ld b,-1
	ret c
	ld hl,MSXMusic_MatchExternalID
	call Memory_SearchSlots
	ld b,0
	ret

; a = slot id
; f <- c: found
MSXMusic_MatchInternalID:
	ld de,MSXMusic_internalId
	ld hl,MSXMusic_ID_ADDRESS
	ld bc,8
	call Memory_MatchSlotString
	ret

; a = slot id
; ix = this
; f <- c: found
MSXMusic_MatchExternalID:
	ld de,MSXMusic_externalId
	ld hl,MSXMusic_ID_ADDRESS + 4
	ld bc,4
	call Memory_MatchSlotString
	ret

;
MSXMusic_internalId:
	db "APRLOPLL"

MSXMusic_externalId:
	db "OPLL"
