;
;
;
MIDIChannel: MACRO
	note: MIDINote
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
MIDIChannel_NoteOff:
	ld a,(ix + MIDIChannel.note.key)
	cp b
	ret nz
	ld (ix + MIDIChannel.note.gate),0
	ld (ix + MIDIChannel.note.offTrigger),127
	ld (ix + MIDIChannel.note.offVelocity),c
	ret

; b = key
; c = velocity
; ix = this
MIDIChannel_NoteOn: PROC
	ld a,c
	and a
	jr z,Off
	ld a,(ix + MIDIChannel.note.gate)
	ld (ix + MIDIChannel.note.gate),127
	ld (ix + MIDIChannel.note.key),b
	ld (ix + MIDIChannel.note.velocity),c
	and a
	ret nz
	ld (ix + MIDIChannel.note.trigger),127
	ret
Off:
	ld a,(ix + MIDIChannel.note.key)
	cp b
	ret nz
	ld (ix + MIDIChannel.note.gate),0
	ld (ix + MIDIChannel.note.offTrigger),127
	ld (ix + MIDIChannel.note.offVelocity),64
	ret
	ENDP

; b = key
; c = pressure
; ix = this
MIDIChannel_PolyPressure:
	ld a,(ix + MIDIChannel.note.key)
	cp b
	ret nz
	ld (ix + MIDIChannel.note.pressure),c
	ret

; b = controller
; c = value
; ix = this
MIDIChannel_ControlChange:
	ld e,b
	ld d,0
	add ix,de
	ld (ix + MIDIChannel.controllers),c
	ret

; b = program
; ix = this
MIDIChannel_ProgramChange:
	ld (ix + MIDIChannel.program),b
	ret

; b = pressure
; ix = this
MIDIChannel_ChannelPressure:
	ld (ix + MIDIChannel.pressure),b
	ret

; b = bend LSB
; c = bend MSB
; ix = this
MIDIChannel_PitchBendChange:
	ld (ix + MIDIChannel.pitchBend),b
	ld (ix + MIDIChannel.pitchBend + 1),c
	ret

; ix = this
MIDIChannel_ClearTriggers:
	ld (ix + MIDIChannel.note.trigger),0
	ld (ix + MIDIChannel.note.offTrigger),0
	ret
