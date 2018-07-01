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

; iy = this
; f <- nz: a message can be read
; Modifies: af
MidiIn_HasMessageIY:
	ld a,(iy + MidiIn.bufferHead)
	cp (iy + MidiIn.bufferTail)
	ret

; iy = this
; a = byte
; f <- z: buffer full
; Modifies: af, hl
MidiIn_WriteByteIY:
	cp 0F8H
	call nc,System_ThrowException
	ld l,(iy + MidiIn.bufferHead)
	ld h,(iy + MidiIn.bufferHead + 1)
	ld (hl),a
	inc l
	ld (iy + MidiIn.bufferHead),l
	ld a,(iy + MidiIn.bufferTail)
	cp l
	ret nz
	call System_ThrowException

; iy = this
; a <- byte
; f <- z: buffer empty
; Modifies: af, hl
MidiIn_ReadByteIY:
	ld l,(iy + MidiIn.bufferTail)
	ld h,(iy + MidiIn.bufferTail + 1)
	ld a,(iy + MidiIn.bufferHead)
	cp l
	ret z
	ld a,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	ret nz
	dec l
	ret

; iy = this
; a <- byte
; Modifies: af, hl
MidiIn_ReadByteBlockingIY: PROC
	ld l,(iy + MidiIn.bufferTail)
	ld h,(iy + MidiIn.bufferTail + 1)
Loop:
	ld a,(iy + MidiIn.bufferHead)
	cp l
	jr z,Loop
	ld a,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	ret
	ENDP

; iy = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOffIY:
	or 10000000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ld a,c
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = note
; c = velocity
MidiIn_NoteOnIY:
	or 10010000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ld a,c
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = note
; c = pressure
MidiIn_PolyPressureIY:
	or 10100000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ld a,c
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = controller
; c = value
MidiIn_ControlChangeIY:
	or 10110000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ld a,c
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = program
MidiIn_ProgramChangeIY:
	or 11000000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = pressure
MidiIn_ChannelPressureIY:
	or 11010000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ret

; iy = this
; a = channel
; b = coarse
; c = fine
MidiIn_PitchBendIY:
	or 11100000B
	call MidiIn_WriteByteIY
	ld a,b
	call MidiIn_WriteByteIY
	ld a,c
	call MidiIn_WriteByteIY
	ret

; ix = channels
; iy = this
MidiIn_ProcessIY: PROC
	ld l,(iy + MidiIn.bufferTail)
	ld h,(iy + MidiIn.bufferTail + 1)
	ld a,(iy + MidiIn.bufferHead)
	sub l
	ret z  ; no messages
	ld e,a
	ld a,(hl)
	inc l
	add a,a
	jr c,Status1
Status0:
	ld (iy + MidiIn.bufferTail),l
	ret
Status1:
	add a,a
	jr c,Status11
Status10:
	add a,a
	jr c,Status101
Status100:
	add a,a
	jr c,Status1001
Status1000:
	dec e
	ret z  ; incomplete message
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_NoteOff
Status1001:
	dec e
	ret z  ; incomplete message
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	ld a,c
	and a
	jp nz,Channel_NoteOn
	ld c,64
	jp Channel_NoteOff
Status101:
	add a,a
	jr c,Status1011
Status1010:
	dec e
	ret z  ; incomplete message
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_PolyPressure
Status1011:
	dec e
	ret z  ; incomplete message
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_ControlChange
Status11:
	add a,a
	jr c,Status111
Status110:
	add a,a
	jr c,Status1101
Status1100:
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_ProgramChange
Status1101:
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_ChannelPressure
Status111:
	add a,a
	jr c,Status1111
Status1110:
	dec e
	ret z  ; incomplete message
	dec e
	ret z  ; incomplete message
	call GetChannel
	ld b,(hl)
	inc l
	ld c,(hl)
	inc l
	ld (iy + MidiIn.bufferTail),l
	jp Channel_PitchBendChange
Status1111:
	ld (iy + MidiIn.bufferTail),l
	ret
; a = channel * 16
; ix = channels
; ix <- channel
GetChannel:
	rrca
	rrca
	rrca
	ld e,a
	ld d,0
	add ix,de
	ld e,(ix)
	ld d,(ix + 1)
	ld ixl,e
	ld ixh,d
	ret
	ENDP

;
MidiIn_overrunErrorMessage:
	db "MIDI UART overrun error.",0

MidiIn_framingErrorMessage:
	db "MIDI UART framing error.",0

MidiIn_parityErrorMessage:
	db "MIDI UART parity error.",0
