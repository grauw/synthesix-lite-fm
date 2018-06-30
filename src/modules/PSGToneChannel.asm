;
;
;
PSGToneChannel: MACRO ?psg, ?channel
	channel: Channel
	gate: Or channel.note.gate, channel.controllers + 68
	volumeControllers: Attenuate channel.controllers + 7, channel.controllers + 11
	volume: Attenuate channel.note.velocity, volumeControllers.value
	psgTone: PSGTone ?psg, ?channel, channel.note.key, gate.value, volume.value
	Update:
		call gate.Update
		call volumeControllers.Update
		call volume.Update
		jp psgTone.Update
	ENDM

; ix = this
PSGToneChannel_Construct:
	call Channel_Construct
	ld de,PSGToneChannel.psgTone
	add ix,de
	call PSGTone_Construct
	ld de,-PSGToneChannel.psgTone
	add ix,de
	ret
