;
;
;
Channel: MACRO
	channel: MIDIChannel
	program: Clamp channel.program, Constants_instance + 0, Constants_instance + 15
	gate: Or channel.note.gate, channel.controllers + 64
	sustainVelocity: Not channel.note.offVelocity
	sustain: Or sustainVelocity.value, channel.controllers + 69
	volumeControllers: Attenuate channel.controllers + 7, channel.controllers + 11
	volume: Attenuate channel.note.velocity, volumeControllers.value
	pitchBend: PitchBend channel.pitchBend + 1, channel.pitchBend, channel.note.key, Constants_instance + 0, Constants_instance + 2, Constants_instance + 0
	controllers: equ channel.controllers
	trigger: equ channel.note.trigger
	note: equ pitchBend.note
	noteFraction: equ pitchBend.noteFraction
	Update:
		call program.Update
		call gate.Update
		call sustainVelocity.Update
		call sustain.Update
		call volumeControllers.Update
		call volume.Update
		jp pitchBend.Update
	ENDM
