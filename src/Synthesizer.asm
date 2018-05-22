;
;
;
Synthesizer: MACRO
	midiIn:
		MSXMidi
	ENDM

; ix = this
Synthesizer_Construct:
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Construct
	pop ix
	ret

; ix = this
Synthesizer_Destruct:
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Destruct
	pop ix
	ret

Synthesizer_GetMidiIn:
	ld de,Synthesizer.midiIn
	add ix,de
	ret

; ix = this
Synthesizer_Run: PROC
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Install
	pop ix
Loop:
	call MidiIn_ReadByte
	jr z,Loop
	call System_PrintHexA
	jr Loop
	push ix
	call Synthesizer_GetMidiIn
	call MSXMidi_Uninstall
	pop ix
	ret
	ENDP
