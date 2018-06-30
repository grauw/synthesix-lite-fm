;
; AY-3-8910 PSG / YM2149 SSG driver
;
PSG_ADDRESS: equ 0A0H
PSG_DATA_WRITE: equ 0A1H
PSG_DATA_READ: equ 0A2H
PSG_FREQUENCY: equ 1789773

PSG: MACRO ?address = PSG_ADDRESS, ?dataWrite = PSG_DATA_WRITE, ?dataRead = PSG_DATA_READ
	; e = register
	; d = value
	SafeWriteRegister:
		ld a,e
		cp 14
		ret nc
		cp 7
		jr z,MaskMixer
	; a = register
	; d = value
	WriteRegister:
		di
		out (?address),a
		ld a,d
		ei
		out (?dataWrite),a
		ret
	MaskMixer:
		ld a,d
		and 3FH
		or 80H
		ld d,a
		ld a,e
		jr WriteRegister

	; a = register
	; a <- value
	ReadRegister:
		di
		out (?address),a
		ei
		in a,(?dataRead)
		ret
	ENDM

; ix = this
PSG_Construct:
	call PSG_Reset
	call PSG_Mute
	ret

; ix = this
PSG_Destruct:
	call PSG_Reset
	ret

; e = register
; d = value
; ix = this
PSG_WriteRegister:
	ld a,e
	ld bc,PSG.WriteRegister
	JP_OFFSET ix,bc

; e = register
; d = value
; ix = this
PSG_SafeWriteRegister:
	ld bc,PSG.SafeWriteRegister
	JP_OFFSET ix,bc

; b = count
; e = register
; d = value
; ix = this
PSG_FillRegisters:
	push bc
	push de
	call PSG_SafeWriteRegister
	pop de
	pop bc
	inc e
	djnz PSG_FillRegisters
	ret

; ix = this
PSG_Reset:
	ld b,3
	ld de,0008H
	call PSG_FillRegisters
	ld b,14
	ld de,0000H
	call PSG_FillRegisters
	ret

; ix = this
PSG_Mute:
	ld de,3F07H
	call PSG_SafeWriteRegister
	ret

; f <- c: found
PSG_Detect:
	scf
	ret
