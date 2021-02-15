;******************************************************************************
;  File name: lab1_skeleton.asm
;  Author:  Christopher Crary
;  Last Modified By: Dr. Schwartz
;  Last Modified On: 19 May 2020
;  Purpose: To filter data stored within a predefined input table based on a
;			set of given conditions and store a subset of filtered values
;			into an output table.
;******************************************************************************
;*********************************INCLUDES*************************************
.include "ATxmega128a1udef.inc"
;******************************END OF INCLUDES*********************************
;*********************************EQUATES**************************************
; potentially useful expressions
.equ NULL = 0
.equ OUT_TABLE_ADDR = 0x3700
.equ IN_TABLE_ADDR = 0xABCD
.equ ThirtySeven = 3*7 + 37/3 - (3-7)  ; 21 + 12 + 4

.equ TabSize = 16;
;******************************END OF EQUATES**********************************
;***************************MEMORY CONFIGURATION*******************************
; program memory constants (if necessary)
.cseg
.org 0xABCD
IN_TABLE:
.db 99, 0x3B, 0164, 0b00111111, 0x44, 0x55, 'p', 0112, 't', 0b00111010, '<', 0x39, 0x57, 49, 100, 0
.db NULL
; label used to calculate size of input table
IN_TABLE_END:

; data memory allocation (if necessary)
.dseg

OUT_TABLE:
.byte (IN_TABLE_END - IN_TABLE)
;*************************END OF MEMORY CONFIGURATION**************************
;********************************MAIN PROGRAM**********************************
.cseg
; configure the reset vector 
;	(ignore meaning of "reset vector" for now)
.org 0x0
rjmp MAIN

; place main program after interrupt vectors 
;	(ignore meaning of "interrupt vectors" for now)
.org 0x100
MAIN:
; point appropriate indices to input/output tables
; load lo byte, hi byte, load ramp into r16 to extend program memory address
; starting address is 0xABCD = 43981. 43981*2 = 87962. 87962 = 1579A.
; Lo bit = 9A
; Hi bit = 57
; byte3 = 01
ldi ZL, low(IN_TABLE << 1)	
ldi ZH, high(IN_TABLE<< 1)
ldi r16, byte3(IN_TABLE << 1)
out CPU_RAMPZ, r16
ldi XL, low(OUT_TABLE_ADDR)
ldi XH, high(OUT_TABLE_ADDR)
ldi r17, 191
ldi r18, 55
ldi r19, 114
clr r16



; loop through input table, performing filtering and storing conditions
LOOP:
clz
	; load value from input table into an appropriate register
	elpm r16, Z+; st
	; determine if the end of table has been reached (perform general check)
	cpi r16, NULL
	; if end of table (EOT) has been reached, i.e., the NULL character was 
	; encountered, the program should branch to the relevant label used to
	; terminate the program (i.e., LOOP_END)
	breq DONE
	
	sbrs r16, 6
	rjmp FAILED_CHECK1;
	rjmp CHECK_1;

	; if EOT was not encountered, perform the first specified 
	; overall conditional check on loaded value (CONDITION_1)
CHECK_1:
	; check if the CONDITION_1 is met (bit 6 is set); if not, branch to 
	; FAILED_CHECK1
	
	; since the CONDITION_1 is met, perform the specified operation
	lsr r16

	; check if CONDITION_2a is met (>= 55); if so, do the specified operation 
	cp r18, r16
	brlo SUB_	
	;	and then store the relevant value; if not, do not store anything
	; NEED TO FIX THIS CAUSE IT WILL STORE REGARDLESS
	; the program should jump back to the beginning of the relevant loop
	
	rjmp LOOP
SUB_:
	subi r16, 8
	st X+, r16
	rjmp LOOP

FAILED_CHECK1:
	; since the CONDITION_1 is NOT met, perform the second specified operation
	lsl r16
	; check if CONDITION_2b is met (<114); if so, do the specified operation 
	; and then store the relevant value; if not, don't store anything
	cp r19, r16
	brsh ADD_
	
	; the program should jump back to the beginning of the relevant loop
	rjmp LOOP
ADD_:
	add r16, r17
	st X+, r16
	rjmp LOOP
; end of program (infinite loop)
DONE: 
rjmp DONE
;*****************************END OF MAIN PROGRAM *****************************
