;
;
;
PSGChannel: MACRO ?psg, ?channel
	channel: Channel
	gate: Or channel.note.gate, channel.controllers + 68
	volumeControllers: Attenuate channel.controllers + 7, channel.controllers + 11
	volume: Attenuate channel.note.velocity, volumeControllers.value
	psgNote: PSGNote ?psg, ?channel, channel.note.key, gate.value, volume.value
	Update:
		call gate.Update
		call volumeControllers.Update
		call volume.Update
		jp psgNote.Update
	ENDM

; ix = this
PSGChannel_Construct:
	call Channel_Construct
	ld de,PSGChannel.psgNote
	add ix,de
	call PSGNote_Construct
	ld de,-PSGChannel.psgNote
	add ix,de
	ret
