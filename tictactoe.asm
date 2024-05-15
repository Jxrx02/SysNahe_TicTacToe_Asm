;-------------------------------------------------
;TicTacToe, 2 Spieler
; Eingabe: Matrix-Keypad an P0 (P0.0-P0.3, für 9 Felder), Eingabe bestätigen P3.2; P3.2 muss direkt wieder betätigt werden ; Wertebereich: [1-9]
; Ausgabe: 8x8-LED-Matrix an P1, P2
;
; -------------------------------------------------
ORG 0000H   ; Startadresse des Programms
LJMP INIT_BOARD

;-----------------------------------------------------------------------
;ISR 
;-----------------------------------------------------------------------
ORG 0003H ; Einsprungsadresse von interrupt 3.2
LJMP ON_INPUT

ORG 0013H ; Einsprungsadresse von interrupt 3.3
LJMP CLEAR_FIELD

;-----------------------------------------------------------------------
; Logik
;-----------------------------------------------------------------------
INIT_BOARD:
	;Bits für Interrupt
	;SETB IT0	; Externer Interrupt reagiert auf fallende Flanke an P3.2; -> ist für richtige hardware besser geeignet
	CLR IT0		; Externer Interrupt reagiert auf gedrückten Schalter P3.2
	SETB EX0  	; Externen Interrupt aktivieren
	CLR IT1		; Externer Interrupt reagiert auf gedrückten Schalter P3.3
	SETB EX1  	; Externen Interrupt aktivieren
	SETB EA   	; Interrupts generell zulassen
	 ; --- ab hier reagiert der µC auf den externen Interrupt 0 und springt auf Adresse 03H (ISR)
    	mov r7, #00000000b	;00 | 00 | 01
				;00 | 00 | 01    	wenn x < 3 -> R7
				;-- - -- - --
	mov r6, #00000000b	;11 | 01 | 00
				;11 | 01 | 00   	wenn x < 6 -> R6
				;-- | -- | --
	mov r5, #00000000b	;11 | 00 | 00
				;11 | 00 | 00		sonst R5

	MOV P1, #00H  	; Reset Register Port 1 als Ausgangsport für LED-Matrix; Befehl nicht notwendig, aber warum nicht '^^
	MOV P2, #00H  	; Reset Register Port 2 als Ausgangsport für LED-Matrix; Befehl nicht notwendig, aber warum nicht '^^
	
	LJMP MAIN_LOOP


MAIN_LOOP:
	;-----------------------------------------------------------------------
	    ; ON_INPUT: Wird P3.2 betätigt, so wird Port P0 (P0.0-P0.3) eingelesen -> liefert Dezimalwert in R0
	;-----------------------------------------------------------------------
	LCALL DISPLAY_BOARD
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
	SUBB A, #03h; Idee: Angenommen: Eingabe 8  soll auf Feld 8 (mitte unten) gemappt werden -> schreibe in unteres Register (R5) und 
			;bestimme die Mitte durch Bitshifts
			;
			; 8-3 >0; 5-3>0; 2-3 = -1 (^=n) Setze Carry oder wenn akku leer, springe auf schleife und durchlaufe n mal === if a<b 
	JC LESS_THAN_3 ; x<3 -> schreibe in R7
	JZ LESS_THAN_3
	
	; 3 < x < 6
	SUBB A, #03h
	JC LESS_THAN_6 ; x<6 -> schreibe in R6
	JZ LESS_THAN_6
	
	; 6< x < 9
	SUBB A, #03h
	JC LESS_THAN_9 ; x<9 -> schreibe in R5
	JZ LESS_THAN_9

	; x < 3
	LESS_THAN_3: 
		MOV R2, A; register für zähler der foor loop
		; wenn Bit P3.7 gesetzt ist, so schreibe #00000001b (Spieler 2), ansonsten #00000011b (Spieler1)
		JB P3.7, WRITE_PLAYER_2_INTO_FIELD
		JNB P3.7, WRITE_PLAYER_1_INTO_FIELD
		NACH_REGISTER_FÜLLEN1:
		CPL P3.7
		xch A,R2		; dopppelte Vertauschung notwendig!!
		JBC CY,SUM_LOOP_3
		
		JoaNhBinZuUnkreativ1:
			xch A,R2		;tausche A mit R2
			XRL A, R7		;schreibe wert in TicTacToeFeld mit exclusiv-oder-Verknüpfung
			MOV R7, A 		;speichere Wert in Register zwischen
			LCALL CHECK_FOR_WIN
			RETI			;return from interupt; remove interrupt-bit

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
		JB P3.7, WRITE_PLAYER_2_INTO_FIELD2
		JNB P3.7, WRITE_PLAYER_1_INTO_FIELD2
		NACH_REGISTER_FÜLLEN2:
		CPL P3.7
		xch A,R2		
		JBC CY,SUM_LOOP_6

		JoaNhBinZuUnkreativ2:
			xch A,R2		
			XRL A, R6	
			MOV R6, A 		
			LCALL CHECK_FOR_WIN
			RETI		
				
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
		JB P3.7, WRITE_PLAYER_2_INTO_FIELD3
		JNB P3.7, WRITE_PLAYER_1_INTO_FIELD3
		NACH_REGISTER_FÜLLEN3:
		CPL P3.7
		xch A,R2	
		JBC CY,SUM_LOOP_9

		JoaNhBinZuUnkreativ3:
			xch A,R2	
			XRL A, R5	
			MOV R5, A 		
			LCALL CHECK_FOR_WIN
			RETI
				
	SUM_LOOP_9:
	  	xch A,R2
		INC R2   
		RL A 
		RL A 
		RL A 
		xch A,R2		
		JNZ SUM_LOOP_9  	
		JZ JoaNhBinZuUnkreativ3

; Das hier ist bisschen unschön, aber es muss zu der jeweiligen Adresse im 'IF' zurückgesprungen werden; würde bestimmt mit Stack funktionieren aber my brain hurts very bad
WRITE_PLAYER_1_INTO_FIELD:
	MOV A, #00000011b
	JMP NACH_REGISTER_FÜLLEN1
WRITE_PLAYER_2_INTO_FIELD:
	MOV A, #00000001b
	JMP NACH_REGISTER_FÜLLEN1

WRITE_PLAYER_1_INTO_FIELD2:
	MOV A, #00000011b
	JMP NACH_REGISTER_FÜLLEN2
WRITE_PLAYER_2_INTO_FIELD2:
	MOV A, #00000001b
	JMP NACH_REGISTER_FÜLLEN2

WRITE_PLAYER_1_INTO_FIELD3:
	MOV A, #00000011b
	JMP NACH_REGISTER_FÜLLEN3
WRITE_PLAYER_2_INTO_FIELD3:
	MOV A, #00000001b
	JMP NACH_REGISTER_FÜLLEN3


CLEAR_FIELD:
	MOV R7, #00H
	MOV R6, #00H
	MOV R5, #00H
	RETI

CHECK_FOR_WIN:
	LJMP CHECK_HORIZONTAL

	CHECK_HORIZONTAL:
	;Waagerechte
	;a: Für Spieler 2 (Ganzes Feld) für jedes Register (5-7), |-Verknüpfung mit 00100100, addiere 1 und prüfe ob Carry gesetzt wird, wenn Carry, dann add zählerstand
	;b: Für Spieler 1 vorher noch #10101010b mit or-verknüpfung, dann a: mit anderen zählerstand
		;Spieler mit ganzen Feldern
		MOV A, R7
		ORL A, #00100100b
		INC A
		JZ INC_COUNTER_1
		
		MOV A, R6
		ORL A, #00100100b
		INC A
		JZ INC_COUNTER_1
	
		MOV A, R5
		ORL A, #00100100b
		INC A
		JZ INC_COUNTER_1
		
		;Spieler mit halben Feldern
		MOV A, R7
		ORL A, #10110110b
		INC A
		JZ INC_COUNTER_2
		
		MOV A, R6
		ORL A, #10110110b
		INC A
		JZ INC_COUNTER_2
	
		MOV A, R5
		ORL A, #10110110b
		INC A
		JZ INC_COUNTER_2
	
		LJMP CHECK_VERTICAL
		
	CHECK_VERTICAL:
	;Senkrechte
	;a: für Register R7, R6, R5 jeweils &-Verknüpfung #01X00000b; 
	;b: schreibe Register nacheinander (R7 nach R5) in alu; xor mit #01X01X01 -> wenn ALU #00000000, dann add zählerstand
	;c - das gleiche noch mit den anderen reihen dann #00X01X00, dann #00X00X01 &
	
		LJMP CHECK_DIAGONAL
	
		
	
	CHECK_DIAGONAL:
	;Diagonale "/"
	;a: R7 & #01000000, R6 & #00001000, R5 & #00000001
	;b: |-Verknüpfung mit #10110110
	;c: add 1, prüfe ob carry gesetzt wird, wenn dann add zählerstand
	
	;Diagonale "\"
	;selbe, nur Register tauschen
	
	RET
		



INC_COUNTER_1:		; R4 beinhaltet Punktestand von S1 und S2: 0000 | 0000
	INC R4
	JMP MAIN_LOOP
INC_COUNTER_2:
	XCH A, R4
	RL A
	RL A
	RL A
	RL A
	INC A
	RL A
	RL A
	RL A
	RL A
	XCH A, R4

	JMP MAIN_LOOP

	
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
	    	;MOV P2, #00000000b
	    	setb P1.2
		JBC P1.2,display3
	display3: MOV P2, R6
	    	setb P1.3
		JBC P1.3,display4
	display4:
	    	setb P1.4
		JBC P1.4,display5
	display5:
		;MOV P2, #00000000b
	    	setb P1.5
		JBC P1.5,display6
	display6:
		MOV P2, R5
	    	setb P1.6
		JBC P1.6,display7
	display7:
	    	setb P1.7

		RET
		;LJMP main_loop	




END



