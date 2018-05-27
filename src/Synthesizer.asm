;
;
;
Synthesizer: MACRO
	; a = register
	; d = value
	WriteRegister:
		jp msxMusic + MSXMusic.WriteRegister
	keys:
		ds 16
	msxMusicMirror:
		ds 40H
	midiIn:
		MSXMidi
	msxMusic:
		MSXMusic
	ENDM

; ix = this
Synthesizer_Construct:
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Construct
	pop ix
	push ix
	call Synthesizer_GetMSXMusic
	call MSXMusic_Detect
	call nc,System_ThrowException
	call MSXMusic_Construct
	pop ix
	ret

; ix = this
Synthesizer_Destruct:
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Destruct
	pop ix
	push ix
	call Synthesizer_GetMSXMusic
	call MSXMusic_Destruct
	pop ix
	ret

Synthesizer_GetMidiIn:
	ld de,Synthesizer.midiIn
	add ix,de
	ret

Synthesizer_GetMSXMusic:
	ld de,Synthesizer.msxMusic
	add ix,de
	ret

; ix = this
Synthesizer_WriteRegister:
	jp ix

; ix = this
Synthesizer_Run: PROC
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Install
	ex (sp),ix
	pop iy
Loop:
	call Synthesizer_Process
	jr Loop
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Uninstall
	pop ix
	ret
	ENDP

; ix = this
; iy = MIDI In
Synthesizer_Process: PROC
	call MidiIn_ReadByteBlockingIY
	bit 7,a
	ret z
	bit 6,a
	jr nz,Process11
Process10:
	bit 5,a
	jr nz,Process101
Process100:
	bit 4,a
	jr nz,Process1001
Process1000:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_NoteOff
Process1001:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	and a
	jp nz,Synthesizer_NoteOn
	ld a,64
	jp Synthesizer_NoteOff
Process101:
	bit 4,a
	jr nz,Process1011
Process1010:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_PolyPressure
Process1011:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_ControlChange
Process11:
	bit 5,a
	jr nz,Process111
Process110:
	bit 4,a
	jr nz,Process1101
Process1100:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_ProgramChange
Process1101:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_ChannelPressure
Process111:
	bit 4,a
	jr nz,Process1111
Process1110:
	and 0FH
	ld c,a
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Synthesizer_PitchBendChange
Process1111:
	ret
	ENDP

; a = velocity
; b = key
; c = channel
Synthesizer_NoteOff: PROC
	ld d,a
	ld a,(ix + Synthesizer.keys)
	cp b
	ret nz
	ld a,d
	ld d,(ix + Synthesizer.msxMusicMirror + 20H)
	res 4,d
	bit 6,a
	jr nz,NoSustain
	set 5,d
NoSustain:
	ld (ix + Synthesizer.msxMusicMirror + 20H),d
	ld a,20H
	jp Synthesizer_WriteRegister
	ENDP

; a = velocity
; b = key
; c = channel
Synthesizer_NoteOn:
	ld (ix + Synthesizer.keys),b
	cpl
	rrca
	rrca
	rrca
	and 0FH
	ld d,a
	ld a,(ix + Synthesizer.msxMusicMirror + 30H)
	and 0F0H
	or d
	ld d,a
	ld (ix + Synthesizer.msxMusicMirror + 30H),d
	ld a,30H
	call Synthesizer_WriteRegister
	sla b
	ld e,b
	ld d,0
	ld hl,Synthesizer_frequencyTable
	add hl,de
	ld d,(hl)
	ld (ix + Synthesizer.msxMusicMirror + 10H),d
	ld a,10H
	call Synthesizer_WriteRegister
	inc hl
	ld d,(hl)
	ld (ix + Synthesizer.msxMusicMirror + 20H),d
	ld a,20H
	jp Synthesizer_WriteRegister

; a = pressure
; b = key
; c = channel
Synthesizer_PolyPressure:
	ret

; a = value
; b = controller
; c = channel
Synthesizer_ControlChange:
	ret

; a = program
; c = channel
Synthesizer_ProgramChange:
	add a,a
	add a,a
	add a,a
	add a,a
	ld d,a
	ld a,(ix + Synthesizer.msxMusicMirror + 30H)
	and 0FH
	or d
	ld d,a
	ld (ix + Synthesizer.msxMusicMirror + 30H),d
	ld a,30H
	jp Synthesizer_WriteRegister

; a = pressure
; c = channel
Synthesizer_ChannelPressure:
	ret

; a = bend MSB
; b = bend LSB
; c = channel
Synthesizer_PitchBendChange:
	ret

;
Synthesizer_frequencyTable:
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
