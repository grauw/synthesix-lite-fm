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
	key:
		db 0
	fnumLSB:
		db 0
	fnumMSB:
		db 0
	volumeInstrument:
		db 0
	_size:
	ENDM

; de = MSX Music
; ix = this
Channel_Construct:
	ld hl,MSXMusic.WriteRegister
	add hl,de
	ld (ix + Channel.writeRegister),l
	ld (ix + Channel.writeRegister + 1),h
	ret

; ix = this
Channel_WriteRegister:
	jp ix

; a = velocity
; b = key
Channel_NoteOff: PROC
	ld d,a
	ld a,(ix + Channel.key)
	cp b
	ret nz
	ld a,d
	ld d,(ix + Channel.fnumMSB)
	res 4,d
	bit 6,a
	jr nz,NoSustain
	set 5,d
NoSustain:
	ld (ix + Channel.fnumMSB),d
	ld a,20H
	add a,(ix + Channel.channel)
	jp Channel_WriteRegister
	ENDP

; a = velocity
; b = key
Channel_NoteOn:
	ld (ix + Channel.key),b
	cpl
	rrca
	rrca
	rrca
	and 0FH
	ld d,a
	ld a,(ix + Channel.volumeInstrument)
	and 0F0H
	or d
	ld d,a
	ld (ix + Channel.volumeInstrument),d
	ld a,30H
	add a,(ix + Channel.channel)
	call Channel_WriteRegister
	sla b
	ld e,b
	ld d,0
	ld hl,Channel_frequencyTable
	add hl,de
	ld d,(hl)
	ld (ix + Channel.fnumLSB),d
	ld a,10H
	add a,(ix + Channel.channel)
	call Channel_WriteRegister
	inc hl
	ld d,(hl)
	ld (ix + Channel.fnumMSB),d
	ld a,20H
	add a,(ix + Channel.channel)
	jp Channel_WriteRegister

; a = pressure
; b = key
Channel_PolyPressure:
	ret

; a = value
; b = controller
Channel_ControlChange:
	ret

; a = program
Channel_ProgramChange:
	add a,a
	add a,a
	add a,a
	add a,a
	ld d,a
	ld a,(ix + Channel.volumeInstrument)
	and 0FH
	or d
	ld d,a
	ld (ix + Channel.volumeInstrument),d
	ld a,30H
	add a,(ix + Channel.channel)
	jp Channel_WriteRegister

; a = pressure
Channel_ChannelPressure:
	ret

; a = bend MSB
; b = bend LSB
Channel_PitchBendChange:
	ret

;
Channel_frequencyTable:
	dw 41 | 0 << 9 | 1 << 12
	dw 43 | 0 << 9 | 1 << 12
	dw 46 | 0 << 9 | 1 << 12
	dw 48 | 0 << 9 | 1 << 12
	dw 51 | 0 << 9 | 1 << 12
	dw 54 | 0 << 9 | 1 << 12
	dw 58 | 0 << 9 | 1 << 12
	dw 61 | 0 << 9 | 1 << 12
	dw 65 | 0 << 9 | 1 << 12
	dw 68 | 0 << 9 | 1 << 12
	dw 73 | 0 << 9 | 1 << 12
	dw 77 | 0 << 9 | 1 << 12
	dw 81 | 0 << 9 | 1 << 12
	dw 86 | 0 << 9 | 1 << 12
	dw 91 | 0 << 9 | 1 << 12
	dw 97 | 0 << 9 | 1 << 12
	dw 103 | 0 << 9 | 1 << 12
	dw 109 | 0 << 9 | 1 << 12
	dw 115 | 0 << 9 | 1 << 12
	dw 122 | 0 << 9 | 1 << 12
	dw 129 | 0 << 9 | 1 << 12
	dw 137 | 0 << 9 | 1 << 12
	dw 145 | 0 << 9 | 1 << 12
	dw 154 | 0 << 9 | 1 << 12
	dw 163 | 0 << 9 | 1 << 12
	dw 172 | 0 << 9 | 1 << 12
	dw 183 | 0 << 9 | 1 << 12
	dw 194 | 0 << 9 | 1 << 12
	dw 205 | 0 << 9 | 1 << 12
	dw 217 | 0 << 9 | 1 << 12
	dw 230 | 0 << 9 | 1 << 12
	dw 258 | 0 << 9 | 1 << 12
	dw 274 | 0 << 9 | 1 << 12
	dw 290 | 0 << 9 | 1 << 12
	dw 307 | 0 << 9 | 1 << 12
	dw 326 | 0 << 9 | 1 << 12
	dw 345 | 0 << 9 | 1 << 12
	dw 365 | 0 << 9 | 1 << 12
	dw 387 | 0 << 9 | 1 << 12
	dw 410 | 0 << 9 | 1 << 12
	dw 435 | 0 << 9 | 1 << 12
	dw 460 | 0 << 9 | 1 << 12
	dw 488 | 0 << 9 | 1 << 12
	dw 258 | 1 << 9 | 1 << 12
	dw 274 | 1 << 9 | 1 << 12
	dw 290 | 1 << 9 | 1 << 12
	dw 307 | 1 << 9 | 1 << 12
	dw 326 | 1 << 9 | 1 << 12
	dw 345 | 1 << 9 | 1 << 12
	dw 365 | 1 << 9 | 1 << 12
	dw 387 | 1 << 9 | 1 << 12
	dw 410 | 1 << 9 | 1 << 12
	dw 435 | 1 << 9 | 1 << 12
	dw 460 | 1 << 9 | 1 << 12
	dw 488 | 1 << 9 | 1 << 12
	dw 258 | 2 << 9 | 1 << 12
	dw 274 | 2 << 9 | 1 << 12
	dw 290 | 2 << 9 | 1 << 12
	dw 307 | 2 << 9 | 1 << 12
	dw 326 | 2 << 9 | 1 << 12
	dw 345 | 2 << 9 | 1 << 12
	dw 365 | 2 << 9 | 1 << 12
	dw 387 | 2 << 9 | 1 << 12
	dw 410 | 2 << 9 | 1 << 12
	dw 435 | 2 << 9 | 1 << 12
	dw 460 | 2 << 9 | 1 << 12
	dw 488 | 2 << 9 | 1 << 12
	dw 258 | 3 << 9 | 1 << 12
	dw 274 | 3 << 9 | 1 << 12
	dw 290 | 3 << 9 | 1 << 12
	dw 307 | 3 << 9 | 1 << 12
	dw 326 | 3 << 9 | 1 << 12
	dw 345 | 3 << 9 | 1 << 12
	dw 365 | 3 << 9 | 1 << 12
	dw 387 | 3 << 9 | 1 << 12
	dw 410 | 3 << 9 | 1 << 12
	dw 435 | 3 << 9 | 1 << 12
	dw 460 | 3 << 9 | 1 << 12
	dw 488 | 3 << 9 | 1 << 12
	dw 258 | 4 << 9 | 1 << 12
	dw 274 | 4 << 9 | 1 << 12
	dw 290 | 4 << 9 | 1 << 12
	dw 307 | 4 << 9 | 1 << 12
	dw 326 | 4 << 9 | 1 << 12
	dw 345 | 4 << 9 | 1 << 12
	dw 365 | 4 << 9 | 1 << 12
	dw 387 | 4 << 9 | 1 << 12
	dw 410 | 4 << 9 | 1 << 12
	dw 435 | 4 << 9 | 1 << 12
	dw 460 | 4 << 9 | 1 << 12
	dw 488 | 4 << 9 | 1 << 12
	dw 258 | 5 << 9 | 1 << 12
	dw 274 | 5 << 9 | 1 << 12
	dw 290 | 5 << 9 | 1 << 12
	dw 307 | 5 << 9 | 1 << 12
	dw 326 | 5 << 9 | 1 << 12
	dw 345 | 5 << 9 | 1 << 12
	dw 365 | 5 << 9 | 1 << 12
	dw 387 | 5 << 9 | 1 << 12
	dw 410 | 5 << 9 | 1 << 12
	dw 435 | 5 << 9 | 1 << 12
	dw 460 | 5 << 9 | 1 << 12
	dw 488 | 5 << 9 | 1 << 12
	dw 258 | 6 << 9 | 1 << 12
	dw 274 | 6 << 9 | 1 << 12
	dw 290 | 6 << 9 | 1 << 12
	dw 307 | 6 << 9 | 1 << 12
	dw 326 | 6 << 9 | 1 << 12
	dw 345 | 6 << 9 | 1 << 12
	dw 365 | 6 << 9 | 1 << 12
	dw 387 | 6 << 9 | 1 << 12
	dw 410 | 6 << 9 | 1 << 12
	dw 435 | 6 << 9 | 1 << 12
	dw 460 | 6 << 9 | 1 << 12
	dw 488 | 6 << 9 | 1 << 12
	dw 258 | 7 << 9 | 1 << 12
	dw 274 | 7 << 9 | 1 << 12
	dw 290 | 7 << 9 | 1 << 12
	dw 307 | 7 << 9 | 1 << 12
	dw 326 | 7 << 9 | 1 << 12
	dw 345 | 7 << 9 | 1 << 12
	dw 365 | 7 << 9 | 1 << 12
	dw 387 | 7 << 9 | 1 << 12
	dw 410 | 7 << 9 | 1 << 12
	dw 435 | 7 << 9 | 1 << 12
	dw 460 | 7 << 9 | 1 << 12
	dw 488 | 7 << 9 | 1 << 12
	dw 511 | 7 << 9 | 1 << 12
