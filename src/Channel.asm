;
;
;
Channel: MACRO
	note: Note
	program:
		db 0
	pressure:
		db 0
	pitchBend:
		dw 4000H
	controllers:
		db 0, 0, 0, 0, 0, 0, 0, 127, 64, 0, 64, 127, 0, 0, 0, 0  ; CC   0-15
		db 8, 0, 0, 0, 0, 0, 127, 0, 8, 0, 0, 0, 0, 0, 127, 0  ; CC  16-31
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  32-47
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  48-63
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  64-79
		db 0, 0, 127, 0, 0, 0, 0, 0, 0, 0, 127, 0, 0, 0, 0, 0  ; CC  80-95
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC  96-111
		db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0  ; CC 112-127
	_size:
	ENDM

; ix = this
Channel_Construct:
	ret

; a = velocity
; b = key
Channel_NoteOff:
	ld d,a
	ld a,(ix + Channel.note.key)
	cp b
	ret nz
	ld (ix + Channel.note.gate),0
	ld (ix + Channel.note.offVelocity),d
	ret

; a = velocity
; b = key
Channel_NoteOn:
	ld (ix + Channel.note.gate),127
	ld (ix + Channel.note.key),b
	ld (ix + Channel.note.velocity),a
	ret

; a = pressure
; b = key
Channel_PolyPressure:
	ld d,a
	ld a,(ix + Channel.note.key)
	cp b
	ret nz
	ld (ix + Channel.note.pressure),d
	ret

; a = value
; b = controller
Channel_ControlChange:
	ld e,b
	ld d,0
	add ix,de
	ld (ix + Channel.controllers),a
	ret

; a = program
Channel_ProgramChange:
	ld (ix + Channel.program),a
	ret

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
