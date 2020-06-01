;
;
;
PSGToneChannel: MACRO ?psg, ?channel
	channel: MIDIChannel
	gate: Or channel.note.gate, channel.controllers + 64
	volumeControllers: Attenuate channel.controllers + 7, channel.controllers + 11
	volume: Attenuate channel.note.velocity, volumeControllers.value
	pitchBend: PitchBend channel.pitchBend + 1, channel.pitchBend, channel.note.key, Constants_instance + 0, Constants_instance + 2, Constants_instance + 0
	psgTone: PSGTone ?psg, ?channel, pitchBend.note, pitchBend.noteFraction, gate.value, volume.value
	Update:
		call gate.Update
		call volumeControllers.Update
		call volume.Update
		call pitchBend.Update
		jp psgTone.Update
	ENDM
