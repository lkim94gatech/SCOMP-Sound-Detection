; AudioTest.asm
; Displays the value from the audio peripheral

ORG 0
	; Get data from the audio peripheral
	; IN     Sound
	; Display value on Hex 0
	; OUT    Hex0
    ; Display most-significant 10 bits of the magnitude on LEDs
    ; CALL   Abs
    ; SHIFT  -6
    ; OUT    LEDs
	; Do it again
	; JUMP   0
	
; Subroutine to get the absolute value.
; Additional subroutine for negation is made available,
; since that's required for absolute value anyway.
; Abs:
	; JNEG   Negate
    ; RETURN ; positive or zero; just return
; Negate:
	; STORE  NegTemp
    ; SUB    NegTemp
    ; SUB    NegTemp
	; RETURN
; NegTemp: DW 0
	
  AND 0
  ;Reset Audio Peripheral
  OUT   Sound
Game:
  AND   0
  ADDI  3
  ;Pass 1 to Peripheral, Counts
  OUT   Sound
  IN    Sound
  OUT   Hex0
  OUT   Timer
  WaitingLoop:
  IN    Timer
  ;20 timer counts is 1.3s
  ADDI  -13
  JNEG  WaitingLoop
  JUMP  Game	

count: DW 0

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Sound:     EQU &H50
