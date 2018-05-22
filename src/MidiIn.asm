;
; MIDI in
;
MidiIn_BUFFER_SIZE: equ 100H

MidiIn: MACRO
	buffer:
		dw 0
	bufferHead:
		dw 0
	bufferTail:
		dw 0
	clock:
		db 0

	WriteByte: PROC
		cp 0F8H
		jr nc,RealTime
		ld hl,(bufferHead)
		ld (hl),a
		inc l
		ld (bufferHead),hl
		ld a,(bufferTail)
		cp l
		ret nz
		call System_ThrowException
	RealTime:
		ret nz  ; not clock
		ld hl,clock
		inc (hl)
		ret
		ENDP
	ENDM

; ix = this
MidiIn_Construct:
	push ix
	ld bc,MidiIn_BUFFER_SIZE
	ld ix,Heap_main
	call Heap_AllocateAligned
	pop ix
	ld (ix + MidiIn.buffer),e
	ld (ix + MidiIn.buffer + 1),d
	ld (ix + MidiIn.bufferHead),e
	ld (ix + MidiIn.bufferHead + 1),d
	ld (ix + MidiIn.bufferTail),e
	ld (ix + MidiIn.bufferTail + 1),d
	ret

; ix = this
MidiIn_Destruct:
	ld e,(ix + MidiIn.buffer)
	ld d,(ix + MidiIn.buffer + 1)
	push ix
	ld bc,MidiIn_BUFFER_SIZE
	ld ix,Heap_main
	call Heap_Free
	pop ix
	ret

; ix = this
; f <- nz: a message can be read
; Modifies: af
MidiIn_HasMessage:
	ld a,(ix + MidiIn.bufferHead)
	cp (ix + MidiIn.bufferTail)
	ret

; ix = this
; a = byte
; f <- z: buffer full
; Modifies: af, hl
MidiIn_WriteByte:
	cp 0F8H
	call nc,System_ThrowException
	ld l,(ix + MidiIn.bufferHead)
	ld h,(ix + MidiIn.bufferHead + 1)
	ld (hl),a
	inc l
	ld (ix + MidiIn.bufferHead),l
	ld a,(ix + MidiIn.bufferTail)
	cp l
	ret nz
	call System_ThrowException

; ix = this
; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
MidiIn_ReadByte:
	ld l,(ix + MidiIn.bufferTail)
	ld h,(ix + MidiIn.bufferTail + 1)
	ld a,(ix + MidiIn.bufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (ix + MidiIn.bufferTail),l
	ret nz
	dec l
	ret

; ix = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOff:
	or 10000000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOn:
	or 10010000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = note
; c = pressure
MidiIn_PolyPressure:
	or 10100000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = controller
; c = value
MidiIn_ControlChange:
	or 10110000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = program
MidiIn_ProgramChange:
	or 11000000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = pressure
MidiIn_ChannelPressure:
	or 11010000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ret

; ix = this
; a = channel
; b = coarse
; c = fine
MidiIn_PitchBend:
	or 11100000B
	call MidiIn_WriteByte
	ld a,b
	call MidiIn_WriteByte
	ld a,c
	call MidiIn_WriteByte
	ret

;
MidiIn_overrunErrorMessage:
	db "MIDI UART overrun error.",0

MidiIn_framingErrorMessage:
	db "MIDI UART framing error.",0

MidiIn_parityErrorMessage:
	db "MIDI UART parity error.",0
