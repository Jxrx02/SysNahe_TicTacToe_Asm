;-------------------------------------------------
;TicTacToe, 2 Spieler
; Eingabe: Matrix-Keypad an P0 (P0.0-P0.3, für 9 Felder), Eingabe bestätigen P0.7 ; Wertebereich: [1-9]
; Ausgabe: 8x8-LED-Matrix an P1, P2
;
; -------------------------------------------------
;-----------------------------------------------------------------------
; Voreingestellungen 
;-----------------------------------------------------------------------
ORG 0H   ; Startadresse des Programms
MOV P1, #00H  ; Konfiguriere Port 1 als Ausgangsport für LED-Matrix
MOV P2, #00H  ; Konfiguriere Port 2 als Ausgangsport für LED-Matrix

;-----------------------------------------------------------------------
; Logik
;-----------------------------------------------------------------------

call INIT_BOARD
INIT_BOARD:
    	mov r7, #00000000b	;00 0 00 0 10
				;00 0 00 0 10    	wenn x < 3 -> R7
				;00 0 00 0 00
	mov r6, #00000000b	;11 0 10 0 00
				;11 0 10 0 00   	wenn x < 6 -> R6
				;00 0 00 0 00
	mov r5, #00000000b	;11 0 00 0 00
				;11 0 00 0 00		sonst R5


call MAIN_LOOP
MAIN_LOOP:
	;-----------------------------------------------------------------------
	    ; ON_INPUT: Wird P0.7 betätigt, so wird Port P0 (P0.0-P0.3) eingelesen -> liefert Dezimalwert in R0
	;-----------------------------------------------------------------------
   	JB P0.7, ON_INPUT 


	call DISPLAY_BOARD
    	JMP MAIN_LOOP 


ON_INPUT:
    	MOV a, P0
    	ANL a, #00FH ; bitweise &-Verknüpfung, um nur die letzten 4 Bits (P0.0-P0.3) auszuwerten
    	MOV R0, a
	;-----------------------------------------------------------------------
	    ; Mappe Feld auf 8x8 Matrix
	    ; => R0 enthält den Wert des zu setztenden Feldes
	;-----------------------------------------------------------------------
	; x < 3
	SUBB A, #03h; Idee: 8-3 >0; 5-3>0; 2-3 = -1 Setze Carry oder wenn akku leer, springe auf schleife === if a<b 
	JC LESS_THAN_3 ; x<3 -> schreibe in R7
	JZ LESS_THAN_3
	
	; 3 < x < 6
	SUBB A, #03h
	JC LESS_THAN_6 ; x<6 -> schreibe in R6
	JZ LESS_THAN_6
	; 6< x < 9
	SUBB A, #03h
	JC LESS_THAN_9 ; x<6 -> schreibe in R6
	JZ LESS_THAN_9

	; x < 3
	LESS_THAN_3: 
		MOV R2, A; register für zähler der foor loop
		MOV A, #00000011b
		xch A,R2		; dopppelte Vertauschung notwendig!!
		JBC C,SUM_LOOP_3
		
		JoaNhBinZuUnkreativ1:
			xch A,R2		;tausche A mit R2
			ORL A, R7		;schreibe wert in TicTacToeFeld mit |-Verknüpfung
			MOV R7, A 		;speichere Wert in Register zwischen
			JMP MAIN_LOOP 

	SUM_LOOP_3:
	  	xch A,R2
		INC R2          	; Inkrementiere den Zählerwert für die nächste Iteration
		RL A 		;rotiere akku um 3 Stellen je übertrag
		RL A 
		RL A 
		xch A,R2		;tausche A(kku) mit R2
		JNZ SUM_LOOP_3  	; springe zurück zur Schleife, wenn r2 != 0
		JZ JoaNhBinZuUnkreativ1
		
	;-----------------------------------------------------------------------
	; 3 < x < 6
	LESS_THAN_6: 
		MOV R2, A
		MOV A, #00000011b
		xch A,R2		
		JBC C,SUM_LOOP_6

		JoaNhBinZuUnkreativ2:
			xch A,R2		
			ORL A, R6	
			MOV R6, A 		
			JMP MAIN_LOOP 
				
	SUM_LOOP_6:
	  	xch A,R2
		INC R2        
		RL A 		
		RL A 
		RL A 
		xch A,R2		
		JNZ SUM_LOOP_6  	
		JZ JoaNhBinZuUnkreativ2


		
	;-----------------------------------------------------------------------
	; 6< x < 9
	LESS_THAN_9: 
		MOV R2, A
		MOV A, #00000011b
		xch A,R2	
		JBC C,SUM_LOOP_9

		JoaNhBinZuUnkreativ3:
			xch A,R2	
			ORL A, R5	
			MOV R5, A 		
			JMP MAIN_LOOP 
				
	SUM_LOOP_9:
	  	xch A,R2
		INC R2   
		RL A 
		RL A 
		RL A 
		xch A,R2		
		JNZ SUM_LOOP_9  	
		JZ JoaNhBinZuUnkreativ3

	



DISPLAY_BOARD:
	;-----------------------------------------------------------------------
	    ; Zeige R7,R6,R5 nacheinander gemultiplext an
	    ; R7, R6, R5 spiegeln das Feld wider, x die Eingabe aus R0 von Funktion ON_INPUT (Wird auch beim Mappen in der Funktion behandelt)
	;-----------------------------------------------------------------------



    	MOV P1, #00000000b ;setze p1 standardgemäß auf 0
	;display0:
	    	MOV P2, R7
	    	setb P1.0
	    	JBC P1.0,display1
	display1: 
	    	;MOV P2, R7
	    	setb P1.1
		JBC P1.1,display2
	display2:
	    	MOV P2, #00000000b
	    	setb P1.2
		JBC P1.2,display3
	display3: MOV P2, R6
	    	setb P1.3
		JBC P1.3,display4
	display4:
	    	setb P1.4
		JBC P1.4,display5
	display5:
		MOV P2, #00000000b
	    	setb P1.5
		JBC P1.5,display6
	display6:
		MOV P2, R5
	    	setb P1.6
		JBC P1.6,display7
	display7:
	    	setb P1.7


		call main_loop	



END



