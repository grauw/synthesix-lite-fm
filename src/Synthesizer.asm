;
;
;
Synthesizer_CHANNELS: equ 16

Synthesizer: MACRO
	midiIn:
		MSXMidi
	channels:
		dw channel1.channel
		dw channel2.channel
		dw channel3.channel
		dw channel4.channel
		dw channel5.channel
		dw channel6.channel
		dw channel7.channel
		dw channel8.channel
		dw channel9.channel
		dw channel10.channel
		dw channel11.channel
		dw channel12.channel
		dw channel13.channel
		dw channel14.channel
		dw channel15.channel
		dw channel16.channel
	channel1: Channel
	channel2: Channel
	channel3: Channel
	channel4: Channel
	channel5: Channel
	channel6: Channel
	channel7: Channel
	channel8: Channel
	channel9: Channel
	channel10: Channel
	channel11: Channel
	channel12: Channel
	channel13: Channel
	channel14: Channel
	channel15: Channel
	channel16: Channel
	msxMusic:
		MSXMusic channel1, channel2, channel3, channel4, channel5, channel6, channel7, channel8, channel9, channel10, channel11
	psg:
		PSG channel12, channel13, channel14, channel15, channel16
	Update:
		call channel1.Update
		call channel2.Update
		call channel3.Update
		call channel4.Update
		call channel5.Update
		call channel6.Update
		call channel7.Update
		call channel8.Update
		call channel9.Update
		call channel10.Update
		call channel11.Update
		call channel12.Update
		call channel13.Update
		call channel14.Update
		call channel15.Update
		call channel16.Update
		call psg.Update
		call msxMusic.Update
		REPT 16, ?channel
		ld ix,(channels + ?channel * 2)
		call MIDIChannel_ClearTriggers
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

; ix = this
; ix <- MIDI In
Synthesizer_GetMidiIn:
	ld de,Synthesizer.midiIn
	add ix,de
	ret

; ix = this
; ix <- MSX Music
Synthesizer_GetMSXMusic:
	ld de,Synthesizer.msxMusic
	add ix,de
	ret

; ix = this
; ix <- PSG
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
	ld a,(JIFFY)
	ld c,a
Loop:
	push bc
	push ix
	call Synthesizer_Process
	pop ix
	pop bc
	ld a,(JIFFY)
	sub c
	jr z,Loop
	ld b,a
	add a,c
	ld c,a
UpdateLoop:
	push bc
	push ix
	call Synthesizer_Update
	pop ix
	pop bc
	djnz UpdateLoop
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
	call MSXMidi_CheckErrorIY
	ld de,Synthesizer.channels
	add ix,de
	jp MidiIn_ProcessIY

; ix = this
Synthesizer_Update:
	ld de,Synthesizer.Update
	add ix,de
	jp ix
