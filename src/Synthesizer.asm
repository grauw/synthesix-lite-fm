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
	psgChannel1: PSGToneChannel psg, 0
	psgChannel2: PSGToneChannel psg, 1
	psgChannel3: PSGToneChannel psg, 2
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
		call psgChannel5.Update
		REPT 16, ?channel
		ld ix,(channels + ?channel * 2)
		call Channel_ClearTriggers
		ENDM
		ret
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

; ix = this
Synthesizer_Run: PROC
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Install
	pop ix
Loop:
	push ix
	call Synthesizer_Process
	pop ix
	push ix
	call Synthesizer_Update
	pop ix
	jr Loop
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Uninstall
	pop ix
	ret
	ENDP

; ix = this
Synthesizer_Process:
	ld e,ixl
	ld d,ixh
	ld iy,Synthesizer.midiIn
	add iy,de
	ld de,Synthesizer.channels
	add ix,de
	jp MidiIn_ProcessIY

; ix = this
Synthesizer_Update:
	ld de,Synthesizer.Update
	add ix,de
	jp ix
