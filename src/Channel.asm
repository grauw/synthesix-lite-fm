;
;
;
Channel: MACRO ?channel
	; a = register
	; d = value
	WriteRegister:
		jp System_ThrowException
	writeRegister: equ $ - 2
	channel:
		db ?channel
	basicChannel:
		db ?channel = 0 ? 127 : 0
	gate:
		db 0
	key:
		db 0
	velocity:
		db 0
	offVelocity:
		db 0
	program:
		db 0
	pressure:
		db 0
	pitchBend:
		dw 4000H
	controllers:
		db 0, 0, 0, 0, 0, 0, 0, 127, 0, 0, 0, 0, 0, 0, 0, 0  ; CC   0-15
		db 8, 0, 0, 0, 0, 0, 127, 0, 8, 0, 0, 0, 0, 0, 127, 0  ; CC  16-31
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  32-47
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  48-63
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  64-79
		db 0, 0, 127, 0, 0, 0, 0, 0, 0, 0, 127, 0, 0, 0, 0, 0  ; CC  80-95
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  96-111
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC 112-127
	_size:
	ENDM

; de = MSX Music
; ix = this
Channel_Construct:
	ld hl,MSXMusic.WriteRegister
	add hl,de
	ld (ix + Channel.writeRegister),l
	ld (ix + Channel.writeRegister + 1),h
	call Channel_UpdateBasicControllers
	ret

; ix = this
Channel_WriteRegister:
	jp ix

; a = velocity
; b = key
Channel_NoteOff:
	ld d,a
	ld a,(ix + Channel.key)
	cp b
	ret nz
	ld (ix + Channel.gate),0
	ld (ix + Channel.offVelocity),d
	jp Channel_UpdateKeyFrequency

; a = velocity
; b = key
Channel_NoteOn:
	ld (ix + Channel.gate),127
	ld (ix + Channel.key),b
	ld (ix + Channel.velocity),a
	call Channel_UpdateVolumeInstrument
	jp Channel_UpdateKeyFrequency

; a = pressure
; b = key
Channel_PolyPressure:
	ld d,a
	ld a,(ix + Channel.key)
	cp b
	ret nz
	ld (ix + Channel.pressure),d
	ret

; a = value
; b = controller
Channel_ControlChange: PROC
	push ix
	ld e,b
	ld d,0
	add ix,de
	ld (ix + Channel.controllers),a
	pop ix
	bit 6,(ix + Channel.basicChannel)
	call nz,Basic
	cp 7
	jp z,Channel_UpdateVolumeInstrument
	cp 64
	jp z,Channel_UpdateKeyFrequency
	cp 68
	jp z,Channel_UpdateKeyFrequency
	ret
Basic:
	ld a,b
	cp 16
	ret c
	cp 32
	jp c,Channel_UpdateBasicControllers
	cp 80
	ret c
	cp 96
	jp c,Channel_UpdateBasicControllers
	ret
	ENDP

; a = program
Channel_ProgramChange:
	ld (ix + Channel.program),a
	jp Channel_UpdateVolumeInstrument

; a = pressure
Channel_ChannelPressure:
	ld (ix + Channel.pressure),a
	ret

; a = bend MSB
; b = bend LSB
Channel_PitchBendChange:
	ld (ix + Channel.pitchBend),b
	ld (ix + Channel.pitchBend + 1),a
	ret

; ix = this
Channel_UpdateKeyFrequency: PROC
	ld a,(ix + Channel.key)
	add a,a
	ld e,a
	ld d,0
	ld hl,Channel_frequencyTable
	add hl,de
	ld d,(hl)
	ld a,10H
	add a,(ix + Channel.channel)
	call Channel_WriteRegister
	inc hl
	ld a,(ix + Channel.gate)
	or (ix + Channel.controllers + 68)
	rrca
	rrca
	and 00010000B
	or (hl)
	ld d,a
	ld a,(ix + Channel.offVelocity)
	cpl
	or (ix + Channel.controllers + 64)
	bit 6,a
	jr z,NoSustain
	set 5,d
NoSustain:
	ld a,20H
	add a,(ix + Channel.channel)
	jp Channel_WriteRegister
	ENDP

; ix = this
Channel_UpdateVolumeInstrument: PROC
	ld a,(ix + Channel.program)
	add a,a
	add a,a
	add a,a
	add a,a
	ld d,a
	ld a,(ix + Channel.velocity)
	add a,(ix + Channel.controllers + 7)
	sub 127
	jr nc,NoClip
	xor a
NoClip:
	cpl
	rrca
	rrca
	rrca
	and 0FH
	or d
	ld d,a
	ld a,30H
	add a,(ix + Channel.channel)
	jp Channel_WriteRegister
	ENDP

; ix = this
Channel_UpdateBasicControllers:
	ld a,(ix + Channel.controllers + 88)
	rlca
	and 10000000B
	ld d,a
	ld a,(ix + Channel.controllers + 89)
	and 01000000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 90)
	rrca
	and 00100000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 91)
	rrca
	rrca
	and 00010000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 24)
	rrca
	rrca
	rrca
	and 00001111B
	or d
	ld d,a
	ld a,00H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 80)
	and 10000000B
	rlca
	ld d,a
	ld a,(ix + Channel.controllers + 81)
	and 01000000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 82)
	rrca
	and 00100000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 83)
	rrca
	rrca
	and 00010000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 16)
	rrca
	rrca
	rrca
	and 00001111B
	or d
	ld d,a
	ld a,01H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 27)
	rlca
	and 11000000B
	ld d,a
	ld a,(ix + Channel.controllers + 25)
	rrca
	cpl
	and 00111111B
	or d
	ld d,a
	ld a,02H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 19)
	rlca
	and 11000000B
	ld d,a
	ld a,(ix + Channel.controllers + 84)
	rrca
	rrca
	and 00010000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 92)
	rrca
	rrca
	rrca
	and 00001000B
	or d
	ld d,a
	ld a,(ix + Channel.controllers + 26)
	rrca
	rrca
	rrca
	rrca
	and 00000111B
	or d
	ld d,a
	ld a,03H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 28)
	rlca
	cpl
	and 11110000B
	ld d,a
	ld a,(ix + Channel.controllers + 29)
	rrca
	rrca
	rrca
	cpl
	and 00001111B
	or d
	ld d,a
	ld a,04H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 20)
	rlca
	cpl
	and 11110000B
	ld d,a
	ld a,(ix + Channel.controllers + 21)
	rrca
	rrca
	rrca
	cpl
	and 00001111B
	or d
	ld d,a
	ld a,05H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 30)
	rlca
	cpl
	and 11110000B
	ld d,a
	ld a,(ix + Channel.controllers + 31)
	rrca
	rrca
	rrca
	cpl
	and 00001111B
	or d
	ld d,a
	ld a,06H
	call Channel_WriteRegister
	ld a,(ix + Channel.controllers + 22)
	rlca
	cpl
	and 11110000B
	ld d,a
	ld a,(ix + Channel.controllers + 23)
	rrca
	rrca
	rrca
	cpl
	and 00001111B
	or d
	ld d,a
	ld a,07H
	jp Channel_WriteRegister

;
Channel_frequencyTable:
	INCLUDE "FNumTable.asm"
