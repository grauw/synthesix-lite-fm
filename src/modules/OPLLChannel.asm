;
;
;
OPLLChannel: MACRO ?msxMusic, ?channel
	channel: Channel
	opllNote: OPLLNote ?msxMusic, ?channel, channel.program, channel.velocity, channel.controllers + 7, channel.gate,
	                   channel.controllers + 68, channel.key, channel.offVelocity, channel.controllers + 64
	Update:
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
