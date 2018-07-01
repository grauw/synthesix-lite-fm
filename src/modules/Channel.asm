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
	ENDM

; b = key
; c = velocity
; ix = this
Channel_NoteOff:
	ld a,(ix + Channel.note.key)
	cp b
	ret nz
	ld (ix + Channel.note.gate),0
	ld (ix + Channel.note.offTrigger),127
	ld (ix + Channel.note.offVelocity),c
	ret

; b = key
; c = velocity
; ix = this
Channel_NoteOn:
	ld a,(ix + Channel.note.gate)
	ld (ix + Channel.note.gate),127
	ld (ix + Channel.note.key),b
	ld (ix + Channel.note.velocity),c
	and a
	ret nz
	ld (ix + Channel.note.trigger),127
	ret

; b = key
; c = pressure
; ix = this
Channel_PolyPressure:
	ld a,(ix + Channel.note.key)
	cp b
	ret nz
	ld (ix + Channel.note.pressure),c
	ret

; b = controller
; c = value
; ix = this
Channel_ControlChange:
	ld e,b
	ld d,0
	add ix,de
	ld (ix + Channel.controllers),c
	ret

; b = program
; ix = this
Channel_ProgramChange:
	ld (ix + Channel.program),b
	ret

; b = pressure
; ix = this
Channel_ChannelPressure:
	ld (ix + Channel.pressure),b
	ret

; b = bend LSB
; c = bend MSB
; ix = this
Channel_PitchBendChange:
	ld (ix + Channel.pitchBend),b
	ld (ix + Channel.pitchBend + 1),c
	ret

; ix = this
Channel_ClearTriggers:
	ld (ix + Channel.note.trigger),0
	ld (ix + Channel.note.offTrigger),0
	ret
