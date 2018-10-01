;
;
;
OPLLChannel: MACRO ?msxMusic, ?channel
	channel: Channel
	instrument: Clamp channel.program, Constants_instance + 0, Constants_instance + 15
	gate: Or channel.note.gate, channel.controllers + 64
	sustainVelocity: Not channel.note.offVelocity
	sustain: Or sustainVelocity.value, channel.controllers + 69
	volumeControllers: Attenuate channel.controllers + 7, channel.controllers + 11
	volume: Attenuate channel.note.velocity, volumeControllers.value
	opllTone: OPLLTone ?msxMusic, ?channel, instrument.value, volume.value, gate.value, channel.note.trigger, channel.note.key, Constants_instance + 0, sustain.value
	Update:
		call instrument.Update
		call gate.Update
		call sustainVelocity.Update
		call sustain.Update
		call volumeControllers.Update
		call volume.Update
		jp opllTone.Update
	ENDM
