;
; Top-level application program class
;
Application: MACRO
	cli:
		CLI
	vblankHandler:
		VBlankHandler
	synthesizer:
		Synthesizer
	size:
	ENDM

;
Application_Main:
	call Application_CheckStack

	call VDP_InitMirrorsOnVDPUpgrades

	ld hl,Application_welcome
	call System_Print

	ld ix,Heap_main
	call Heap_Construct

	call MemoryTest_Test
	call HeapTest_Test

	ld ix,Application_instance
	call Application_Construct
	push ix
	ld hl,Application_EnterMainLoop
	call System_TryCall
	pop ix
	call Application_Destruct

	call System_Rethrow
	ret

; ix = this
; ix <- this
Application_Construct:
	push ix
	call Application_GetCLI
	call CLI_Construct
	pop ix
	push ix
	call Application_GetVBlankHandler
	call VBlankHandler_Construct
	pop ix
	push ix
	call Application_GetSynthesizer
	call Synthesizer_Construct
	pop ix
	ret

; ix = this
; ix <- this
Application_Destruct:
	push ix
	call Application_GetSynthesizer
	call Synthesizer_Destruct
	pop ix
	push ix
	call Application_GetVBlankHandler
	call VBlankHandler_Destruct
	pop ix
	push ix
	call Application_GetCLI
	call CLI_Destruct
	pop ix
	ret

; ix = this
; ix <- command-line interface
Application_GetCLI:
	ld de,Application.cli
	add ix,de
	ret

; ix = this
; ix <- vblank handler
Application_GetVBlankHandler:
	ld de,Application.vblankHandler
	add ix,de
	ret

; ix = this
; ix <- synthesizer
Application_GetSynthesizer:
	ld de,Application.synthesizer
	add ix,de
	ret

; ix = this
Application_EnterMainLoop:
	call Application_ParseCLI
	call Application_EnterBlackout
	push ix
	ld hl,Application_Play
	call System_TryCall
	pop ix
	call Application_ExitBlackout
	call System_Rethrow
	ret

; ix = this
Application_ParseCLI:
	push ix
	call Application_GetCLI
	call CLI_Parse
;	call CLI_GetPath
;	ld a,l
;	or h
;	ld hl,Application_usageInstructions
;	jp z,System_ThrowExceptionWithMessage
	pop ix
	ret

; ix = this
Application_Play:
	ld hl,Application_listening
	call System_Print
	push ix
	call Application_GetSynthesizer
	call Synthesizer_Run
	pop ix
	ret

; If enabled, blacks out the screen to minimise audio output interference.
; ix = this
Application_EnterBlackout:
	push ix
	call Application_GetCLI
	ld a,(ix + CLI.blackout)
	pop ix
	and a
	ret z
	ld a,00H
	call VDP_SetColor
	call VDP_EnableBlank
	ret

; ix = this
Application_ExitBlackout:
	ld a,(VDP_MIRROR_0 + 7)
	call VDP_SetColor
	call VDP_DisableBlank
	ret

; Check if the stack is well above the heap
Application_CheckStack:
	ld hl,-(HEAP + HEAP_SIZE + STACK_SIZE)
	add hl,sp
	ld hl,Application_insufficientTPAError
	jp nc,System_ThrowExceptionWithMessage
	ret

;
	SECTION RAM

Application_instance: Application

	ENDS

Application_welcome:
	db "Synthesix Lite FM 1.0 by Grauw",13,10,10,0

Application_listening:
	db "Listening...",13,10,0

Application_insufficientTPAError:
	db "Insufficient TPA space.",13,10,0

Application_usageInstructions:
	db "Usage: synthefm [options]",13,10
	db 13,10
	db "Options:",13,10
	db "  /b  Enter blackout mode during playback.",13,10,0
