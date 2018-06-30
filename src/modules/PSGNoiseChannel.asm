;
;
;
PSGNoiseChannel: MACRO ?psg, ?channel
	channel: Channel
	gate: Or channel.note.gate, channel.controllers + 68
	psgNoise: PSGNoise ?psg, ?channel, channel.note.key, gate.value
	Update:
		call gate.Update
		jp psgNoise.Update
	ENDM

; ix = this
PSGNoiseChannel_Construct:
	call Channel_Construct
	ld de,PSGNoiseChannel.psgNoise
	add ix,de
	call PSGNoise_Construct
	ld de,-PSGNoiseChannel.psgNoise
	add ix,de
	ret
