;
;
;
PSGEnvelopeChannel: MACRO ?psg, ?channel
	channel: Channel
	shape: Clamp channel.program, Constants_instance + 0, Constants_instance + 7
	gate: Or channel.note.gate, channel.controllers + 68
	psgEnvelope: PSGEnvelope ?psg, ?channel, shape.value, channel.note.key, gate.value
	Update:
		call shape.Update
		call gate.Update
		jp psgEnvelope.Update
	ENDM
