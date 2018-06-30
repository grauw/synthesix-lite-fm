;
;
;
Synthesizer_CHANNELS: equ 16

Synthesizer: MACRO
	midiIn:
		MSXMidi
	msxMusic:
		MSXMusic
	psg:
		PSG
	channels:
		dw opllChannel1.channel
		dw opllChannel2.channel
		dw opllChannel3.channel
		dw opllChannel4.channel
		dw opllChannel5.channel
		dw opllChannel6.channel
		dw opllChannel7.channel
		dw opllChannel8.channel
		dw opllChannel9.channel
		dw dummyChannel
		dw dummyChannel
		dw psgChannel1.channel
		dw psgChannel2.channel
		dw psgChannel3.channel
		dw psgChannel4.channel
		dw psgChannel5.channel
	opllChannel1: OPLLBasicChannel msxMusic, 0
	opllChannel2: OPLLChannel msxMusic, 1
	opllChannel3: OPLLChannel msxMusic, 2
	opllChannel4: OPLLChannel msxMusic, 3
	opllChannel5: OPLLChannel msxMusic, 4
	opllChannel6: OPLLChannel msxMusic, 5
	opllChannel7: OPLLChannel msxMusic, 6
	opllChannel8: OPLLChannel msxMusic, 7
	opllChannel9: OPLLChannel msxMusic, 8
	psgChannel1: PSGChannel psg, 0
	psgChannel2: PSGChannel psg, 1
	psgChannel3: PSGChannel psg, 2
	psgChannel4: PSGNoiseChannel psg, 1
	psgChannel5: PSGEnvelopeChannel psg, 2
	dummyChannel: Channel
	Update:
		call opllChannel1.Update
		call opllChannel2.Update
		call opllChannel3.Update
		call opllChannel4.Update
		call opllChannel5.Update
		call opllChannel6.Update
		call opllChannel7.Update
		call opllChannel8.Update
		call opllChannel9.Update
		call psgChannel1.Update
		call psgChannel2.Update
		call psgChannel3.Update
		call psgChannel4.Update
		jp psgChannel5.Update
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
	push ix
	call Synthesizer_GetPSG
	call PSG_Detect
	call nc,System_ThrowException
	call PSG_Construct
	pop ix
	ld de,Synthesizer.opllChannel1
	add ix,de
	call OPLLBasicChannel_Construct
	ld de,Synthesizer.opllChannel2 - Synthesizer.opllChannel1
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel3 - Synthesizer.opllChannel2
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel4 - Synthesizer.opllChannel3
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel5 - Synthesizer.opllChannel4
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel6 - Synthesizer.opllChannel5
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel7 - Synthesizer.opllChannel6
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel8 - Synthesizer.opllChannel7
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.opllChannel9 - Synthesizer.opllChannel8
	add ix,de
	call OPLLChannel_Construct
	ld de,Synthesizer.psgChannel1 - Synthesizer.opllChannel9
	add ix,de
	call PSGChannel_Construct
	ld de,Synthesizer.psgChannel2 - Synthesizer.psgChannel1
	add ix,de
	call PSGChannel_Construct
	ld de,Synthesizer.psgChannel3 - Synthesizer.psgChannel2
	add ix,de
	call PSGChannel_Construct
	ld de,Synthesizer.psgChannel4 - Synthesizer.psgChannel3
	add ix,de
	call PSGNoiseChannel_Construct
	ld de,Synthesizer.psgChannel5 - Synthesizer.psgChannel4
	add ix,de
	call PSGEnvelopeChannel_Construct
	ld de,Synthesizer.dummyChannel - Synthesizer.psgChannel5
	add ix,de
	call Channel_Construct
	ld de,-Synthesizer.dummyChannel
	add ix,de
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
	push ix
	call Synthesizer_GetPSG
	call PSG_Destruct
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

Synthesizer_GetPSG:
	ld de,Synthesizer.psg
	add ix,de
	ret

; a = channel
; ix = this
; ix <- channel
Synthesizer_GetChannel:
	and 0FH
	add a,a
	ld e,a
	ld d,0
	add ix,de
	ld e,(ix + Synthesizer.channels)
	ld d,(ix + Synthesizer.channels + 1)
	ld ixl,e
	ld ixh,d
	ret

; ix = this
Synthesizer_Run: PROC
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Install
	ex (sp),ix
	pop iy
Loop:
	push iy
	push ix
	call Synthesizer_Process
	pop ix
	push ix
	call Synthesizer_Update
	pop ix
	pop iy
	jr Loop
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Uninstall
	pop ix
	ret
	ENDP

; iy = MIDI In
; ix = this
Synthesizer_Update:
	ld de,Synthesizer.Update
	add ix,de
	jp ix

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
