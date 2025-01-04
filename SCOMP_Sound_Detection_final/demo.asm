; Project Demonstration

org 0

Begin:
	LOADI 	1
	OUT 	Perph
	IN 		Switches
	JZERO 	Begin
	JUMP 	ChSwitch
	
	
; Switch 1 = Attendence
; Switch 2 = Average Length of Stay
; Switch 3 = Sound Pollution Detector
; Anything else causes cycle back into chSwitch
ChSwitch:
	LOADI 	0
	OUT 	LEDs
	OUT 	Hex0

	IN Switches
	STORE swtch
	; check for switch 1
	LOAD swtch
	SUB one
	JZERO Attend

	; check for switch 2
	LOAD swtch
	SUB two
	JZERO Time

	; check for switch 3
	LOAD swtch
	SUB four
	JZERO Meter

	JUMP ChSwitch


; Attendence ceiling
Attend:
	LOAD 	one
	OUT  	Perph
	IN 		Perph
	SHIFT 	-1
	OUT 	Hex0

	IN		switches
	Sub 	swtch
	JPOS 	ChSwitch
	JNEG	ChSwitch
	JZERO 	Attend
	
Time:
	IN		switches
	Sub 	swtch
	JPOS 	ChSwitch
	JNEG	ChSwitch
	LOADI	3
	;Pass 1 to Peripheral, Counts
	OUT   	Perph
	IN    	Perph
	OUT   	Hex0
	OUT   	Timer
	WaitingLoop:
	IN    	Timer
	;20 timer counts is 1.3s
	ADDI  	-13
	JNEG  	WaitingLoop
	JUMP  	Time
	
Meter:
	; Get data from the audio peripheral
	IN 		Switches
	Sub		swtch
	JPOS	ChSwitch
	JNEG	ChSwitch
	LOADI 	2
	IN     	Perph
	OUT 	Perph
	OUT    	Hex0
	JUMP  	Meter


	
; Useful Variables
swtch: 		DW 0
one:		DW 1
two:		DW 2
four: 		DW 4 

Count: 		DW 0

; DE10 Variables
Switches:   EQU 0
LEDs:       EQU 001
Timer:      EQU 002
Hex0:       EQU 004
Hex1:       EQU 005
Perph: 		EQU &H50 ; Subject to Change

; Peripheral Variables