;
;
;
OPLLChannel: MACRO ?msxMusic, ?channel
	channel: Channel
	instrument: Clamp channel.program, Constants_instance + 0, Constants_instance + 15
	gate: Or channel.note.gate, channel.controllers + 68
	sustainVelocity: Not channel.note.offVelocity
	sustain: Or sustainVelocity.value, channel.controllers + 64
	volume: Attenuate channel.note.velocity, channel.controllers + 7
	opllNote: OPLLNote ?msxMusic, ?channel, instrument.value, volume.value, gate.value, channel.note.key, sustain.value
	Update:
		call instrument.Update
		call gate.Update
		call sustainVelocity.Update
		call sustain.Update
		call volume.Update
		jp opllNote.Update
	ENDM

; ix = this
OPLLChannel_Construct:
	call Channel_Construct
	ld de,OPLLChannel.opllNote
	add ix,de
	call OPLLNote_Construct
	ld de,-OPLLChannel.opllNote
	add ix,de
	ret
