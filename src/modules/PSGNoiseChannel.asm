;
;
;
PSGNoiseChannel: MACRO ?psg, ?channel
	channel: Channel
	gate: Or channel.note.gate, channel.controllers + 64
	pitchBend: PitchBend channel.pitchBend + 1, channel.pitchBend, channel.note.key, Constants_instance + 0, Constants_instance + 2, Constants_instance + 0
	psgNoise: PSGNoise ?psg, ?channel, pitchBend.note, pitchBend.noteFraction, gate.value
	Update:
		call gate.Update
		call pitchBend.Update
		jp psgNoise.Update
	ENDM
