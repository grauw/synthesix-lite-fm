;
; Math functions
;

; hl = exponent (signed fixed point 1.4.11) (least significant bit ignored)
; dehl <- product (fixed point 16.16)
; Modifies: af, b, de, hl
Math_Pow2: PROC
	ld b,h
	res 0,l
	ld a,h
	and 07H
	ld h,a
	ld de,Math_pow2Table
	add hl,de
	ld e,(hl)
	inc l
	ld d,(hl)
	ex de,hl
	sra b
	sra b
	sra b
	jp m,NegativeExponent
PositiveExponent:
	ld de,1
	ret z
PositiveShiftLoop:
	add hl,hl
	rl e
	rl d
	djnz PositiveShiftLoop
	ret
NegativeExponent:
	ld de,0
	scf
	rr h
	rr l
	ld a,-1
	sub b
	ret z
	ld b,a
NegativeShiftLoop:
	srl h
	rr l
	djnz NegativeShiftLoop
	ret
	ENDP
