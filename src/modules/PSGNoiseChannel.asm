;
;
;
PSGNoiseChannel: MACRO ?psg, ?channel
	channel: Channel
	gate: Or channel.note.gate, channel.controllers + 64
	psgNoise: PSGNoise ?psg, ?channel, channel.note.key, Constants_instance + 0, gate.value
	Update:
		call gate.Update
		jp psgNoise.Update
	ENDM
