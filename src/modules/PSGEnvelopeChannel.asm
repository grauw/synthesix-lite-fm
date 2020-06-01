;
;
;
PSGEnvelopeChannel: MACRO ?psg, ?channel
	channel: MIDIChannel
	shape: Clamp channel.program, Constants_instance + 0, Constants_instance + 7
	gate: Or channel.note.gate, channel.controllers + 64
	pitchBend: PitchBend channel.pitchBend + 1, channel.pitchBend, channel.note.key, Constants_instance + 0, Constants_instance + 2, Constants_instance + 0
	psgEnvelope: PSGEnvelope ?psg, ?channel, shape.value, pitchBend.note, pitchBend.noteFraction, gate.value
	Update:
		call shape.Update
		call gate.Update
		call pitchBend.Update
		jp psgEnvelope.Update
	ENDM
