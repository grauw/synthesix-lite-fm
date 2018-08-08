;
; Minimal VBlank interrupt handler
;
VBlankHandler: MACRO
	hook:
		Hook 38H, Entry, OldHook
	Entry:
		push af
		in a,(99H)
		rlca
		jr nc,NotVBlank
		push hl
		ld hl,(JIFFY)
		inc hl
		ld (JIFFY),hl
		pop hl
		pop af
		ei
		ret
	NotVBlank:
		pop af
	OldHook:
		ds 5
	ENDM

; ix = this
VBlankHandler_Construct:
	push ix
	ld de,VBlankHandler.hook
	add ix,de
	call Hook_Install
	pop ix
	ret

; ix = this
VBlankHandler_Destruct:
	push ix
	ld de,VBlankHandler.hook
	add ix,de
	call Hook_Uninstall
	pop ix
	ret
