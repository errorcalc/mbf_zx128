	device zxspectrum128

	; define DEBUG 1

PART_START	equ  #7500

	org #6000
start	module lib
	include "../../lib/shared.asm"	
	endmodule

	ei : ld sp, start
	
	ld a, %00111000 : call lib.SetScreenAttr
	call PART_START

.loop	halt
	halt
	halt
	ld a, 1 : out #fe, a
	call PART_START + 3
	ld a, 0 : out #fe, a
	jr .loop

	org PART_START
	include "part.box.asm"
	
	display /d, 'Part length: ', $ - PART_START
	display 'Part ended at: ', $

	; build
	if (_ERRORS == 0 && _WARNINGS == 0)
	  savesna SNA_FILENAME, start	  ; SNA_FILENAME defined in Makefile
	  savebin BIN_FILENAME, PART_START, $-PART_START  ; BIN_FILENAME defined in Makefile
	endif
