;
;
;
OPLLChannel: MACRO ?msxMusic, ?channel
	channel: Channel
	instrument: Clamp channel.program, Constants_instance + 0, Constants_instance + 15
	opllNote: OPLLNote ?msxMusic, ?channel, instrument.value, channel.note.velocity, channel.controllers + 7, channel.note.gate,
	                   channel.controllers + 68, channel.note.key, channel.note.offVelocity, channel.controllers + 64
	Update:
		call instrument.Update
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
