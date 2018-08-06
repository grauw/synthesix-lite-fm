;
; MSX-MIDI driver
;
; MSX-MIDI uses the 8251 UART and the 8253 timer.
; See http://map.grauw.nl/resources/midi/msx-midi.php for documentation.
;
MSXMidi_IOSETTING: equ 0E2H
MSXMidi_UART_SEND: equ 0E8H
MSXMidi_UART_RECEIVE: equ 0E8H
MSXMidi_UART_COMMAND: equ 0E9H
MSXMidi_UART_STATUS: equ 0E9H
MSXMidi_TIMER_INT: equ 0EAH
MSXMidi_TIMER_COUNTER0: equ 0ECH
MSXMidi_TIMER_COUNTER1: equ 0EDH
MSXMidi_TIMER_COUNTER2: equ 0EEH
MSXMidi_TIMER_COMMAND: equ 0EFH
MSXMidi_ID_ADDRESS: equ 401CH

S1990_TIMER_CLEAR: equ 0E6H
S1990_TIMER_LSB: equ 0E6H
S1990_TIMER_MSB: equ 0E7H

MSXMidi: MACRO
	super: MidiIn
	found:
		db 0
	commandSave:
		db 0
	hook:
		Hook H.KEYI, Entry, OldHook
	Entry:
		push af
		in a,(MSXMidi_UART_STATUS)
		and 00000010B
		jr z,NotMSXMidi
		push hl
		in a,(MSXMidi_UART_RECEIVE)
		call super.WriteByte
		pop hl
		pop af
		ret
	NotMSXMidi:
		pop af
	OldHook:
		ds 5
	ENDM

; ix = this
MSXMidi_Construct:
	call MidiIn_Construct
	ret

; ix = this
MSXMidi_Destruct:
	call MidiIn_Destruct
	ret

; ix = this
MSXMidi_Install:
	call MSXMidi_Detect
	ret nc
	di
	ld (ix + MSXMidi.found),-1
	push ix
	ld de,MSXMidi.hook
	add ix,de
	call Hook_Install
	pop ix
	call MSXMidi_Configure
	ei
	ret

; ix = this
MSXMidi_Uninstall:
	ld a,(ix + MSXMidi.found)
	and a
	ret z
	di
	push ix
	ld de,MSXMidi.hook
	add ix,de
	call Hook_Uninstall
	pop ix
	call MSXMidi_Reset
	ei
	ret

; ix = this
MSXMidi_Configure:
	call MSXMidi_ConfigureExternal

	; 8253 timer 0: 500 KHz for UART
	ld a,00010110B  ; counter 0, lsb only, mode 3 (square wave), binary
	out (MSXMidi_TIMER_COMMAND),a
	ld a,8          ; 4MHz / 8 = 500KHz
	out (MSXMidi_TIMER_COUNTER0),a

	; 8251 UART: reset
	xor a
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait
	ld a,40H
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait

	; 8251 UART: set mode
	ld a,01001110B  ; 1 stop bit, no parity, 8 bits, 16x baud (31250 baud)
	out (MSXMidi_UART_COMMAND),a
	call MSXMidi_Wait

	; 8251 UART: set command
	ld a,00100101B  ; enable interrupt, rx, timer interrupt, tx
	ld (ix + MSXMidi.commandSave),a
	out (MSXMidi_UART_COMMAND),a

	; 8251 UART: reset interrupt flag
	in a,(MSXMidi_UART_RECEIVE)
	ret

; ix = this
MSXMidi_ConfigureExternal:
	call MSXMidi_DetectInternal
	ret c
	xor a           ; let external MSX-MIDI I/O ports match internal ones
	out (MSXMidi_IOSETTING),a
	ret

; ix = this
MSXMidi_Reset:
	ld a,00000001B  ; reset all except for transmission enable
	ld (ix + MSXMidi.commandSave),a
	out (MSXMidi_UART_COMMAND),a
	ret

; iy = this
; f <- z: no error
MSXMidi_CheckErrorIY: PROC
	ld a,(iy + MSXMidi.found)
	and a
	ret z
	in a,(MSXMidi_UART_STATUS)
	and 00111000B
	ret z
	push af
	ld a,(iy + MSXMidi.commandSave)
	or 00010000B
	out (MSXMidi_UART_COMMAND),a
	pop af
	bit 3,a
	ld hl,MidiIn_parityErrorMessage
	call nz,System_ThrowExceptionWithMessage
	bit 4,a
	ld hl,MidiIn_overrunErrorMessage
	call nz,System_ThrowExceptionWithMessage
	bit 5,a
	ld hl,MidiIn_framingErrorMessage
	call nz,System_ThrowExceptionWithMessage
	ret
	ENDP

; ix = this
; f <- c: found
MSXMidi_Detect: PROC
	call MSXMidi_DetectInternal
	ret c
	ld hl,MSXMidi_MatchExternalID
	call Memory_SearchSlots
	ret
	ENDP

; ix = this
; f <- c: found
MSXMidi_DetectInternal: PROC
	ld a,(EXPTBL)
	ld hl,IDBYT3
	call RDSLT
	rra
	ret
	ENDP

; ix = this
; a = slot id
; f <- c: found
MSXMidi_MatchExternalID:
	ld de,MSXMidi_id
	ld hl,MSXMidi_ID_ADDRESS
	ld bc,4
	call Memory_MatchSlotString
	ret

; Wait 1ms between UART command register writes
; Note that this is unnecessarily long; only a 5 µs wait is required.
; ix = this
MSXMidi_Wait: PROC
	push af
	push bc
	ld c,1
	out (S1990_TIMER_CLEAR),a
Loop:
	in a,(S1990_TIMER_MSB)
	cp c
	jr c,Loop
	pop bc
	pop af
	ret
	ENDP

MSXMidi_id:
	db "MIDI"
