;
;
;
OPLLBasicChannel: MACRO ?msxMusic, ?channel
	super: OPLLChannel ?msxMusic, ?channel
	channel: equ super.channel
	opllVoice: OPLLVoice ?msxMusic, channel.controllers + 80, channel.controllers + 81, channel.controllers + 82, channel.controllers + 83, channel.controllers + 84,
	                   channel.controllers + 16, channel.controllers + 19, channel.controllers + 20, channel.controllers + 21, channel.controllers + 22, channel.controllers + 23,
	                   channel.controllers + 88, channel.controllers + 89, channel.controllers + 90, channel.controllers + 91, channel.controllers + 92,
	                   channel.controllers + 24, channel.controllers + 25, channel.controllers + 26, channel.controllers + 27, channel.controllers + 28, channel.controllers + 29, channel.controllers + 30, channel.controllers + 31
	Update:
		call opllVoice.Update
		jp super.Update
	ENDM
