;
;
;
Channel: MACRO ?channel
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
	opllNote: OPLLNote ?channel, program, velocity, controllers + 7, gate, controllers + 68, key, offVelocity, controllers + 64
	opllTone: OPLLTone controllers + 80, controllers + 81, controllers + 82, controllers + 83, controllers + 84,
	                   controllers + 16, controllers + 19, controllers + 20, controllers + 21, controllers + 22, controllers + 23,
	                   controllers + 88, controllers + 89, controllers + 90, controllers + 91, controllers + 92,
	                   controllers + 24, controllers + 25, controllers + 26, controllers + 27, controllers + 28, controllers + 29, controllers + 30, controllers + 31
	_size:
	ENDM

; de = MSX Music
; ix = this
Channel_Construct:
	ld bc,Channel.opllNote
	add ix,bc
	call OPLLNote_Construct
	ld bc,Channel.opllTone - Channel.opllNote
	add ix,bc
	call OPLLTone_Construct
	ld bc,-Channel.opllTone
	add ix,bc
	ret

; a = velocity
; b = key
Channel_NoteOff:
	ld d,a
	ld a,(ix + Channel.key)
	cp b
	ret nz
	ld (ix + Channel.gate),0
	ld (ix + Channel.offVelocity),d
	jp Channel_UpdateNote

; a = velocity
; b = key
Channel_NoteOn:
	ld (ix + Channel.gate),127
	ld (ix + Channel.key),b
	ld (ix + Channel.velocity),a
	jp Channel_UpdateNote

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
	jp z,Channel_UpdateNote
	cp 64
	jp z,Channel_UpdateNote
	cp 68
	jp z,Channel_UpdateNote
	ret
Basic:
	ld a,b
	cp 16
	ret c
	cp 32
	jp c,Channel_UpdateTone
	cp 80
	ret c
	cp 96
	jp c,Channel_UpdateTone
	ret
	ENDP

; a = program
Channel_ProgramChange:
	ld (ix + Channel.program),a
	jp Channel_UpdateNote

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
Channel_UpdateNote:
	ld de,Channel.opllNote.Update
	add ix,de
	jp ix

; ix = this
Channel_UpdateTone:
	ld de,Channel.opllTone.Update
	add ix,de
	jp ix
