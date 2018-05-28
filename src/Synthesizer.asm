;
;
;
Synthesizer_CHANNELS: equ 16

Synthesizer: MACRO
	midiIn:
		MSXMidi
	msxMusic:
		MSXMusic
	channels:
		REPT Synthesizer_CHANNELS, ?channel
		Channel ?channel
		ENDM
	ENDM

; ix = this
Synthesizer_Construct: PROC
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
	push ix
	ld hl,Synthesizer.msxMusic
	ld e,ixl
	ld d,ixh
	add hl,de
	ld de,Synthesizer.channels
	add ix,de
	ex de,hl
	ld b,Synthesizer_CHANNELS
Loop:
	push bc
	push de
	call Channel_Construct
	ld de,Channel._size
	add ix,de
	pop de
	pop bc
	djnz Loop
	pop ix
	ret
	ENDP

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

; a = channel
; ix = this
; ix <- channel
Synthesizer_GetChannel:
	add a,a
	add a,a
	add a,a
	add a,a  ; Channel._size (16)
	ld e,a
	ld d,0
	add ix,de
	ld de,Synthesizer.channels
	add ix,de
	ret

; ix = this
Synthesizer_Run: PROC
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Install
	ex (sp),ix
	pop iy
Loop:
	push ix
	call Synthesizer_Process
	pop ix
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
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Channel_NoteOff
Process1001:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	and a
	jp nz,Channel_NoteOn
	ld a,64
	jp Channel_NoteOff
Process101:
	bit 4,a
	jr nz,Process1011
Process1010:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Channel_PolyPressure
Process1011:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Channel_ControlChange
Process11:
	bit 5,a
	jr nz,Process111
Process110:
	bit 4,a
	jr nz,Process1101
Process1100:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	jp Channel_ProgramChange
Process1101:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	jp Channel_ChannelPressure
Process111:
	bit 4,a
	jr nz,Process1111
Process1110:
	call Synthesizer_GetChannel
	call MidiIn_ReadByteBlockingIY
	ld b,a
	call MidiIn_ReadByteBlockingIY
	jp Channel_PitchBendChange
Process1111:
	ret
	ENDP
