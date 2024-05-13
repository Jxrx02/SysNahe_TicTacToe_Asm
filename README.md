## ⚒TODOs🛠: 
* Interrupt für Eingabe von Feld -> Anzeige vom Display soll unterbrochen werden
* 2 Spieler -> Spieler 1 hat das ganze Feld ausgemalt und Spieler 2 diagonale (sowas /)
* Timer zum reagieren?
  

## 1. Virtuelle HW laden
![image](https://github.com/Jxrx02/SysNahe_TicTacToe_Asm/assets/131343499/b1dd774a-7980-465d-ba0a-8773562c07ea)

## 2. Input und LED-Matrix-Layout laden
Soll ein Feld gesetzt werden, so muss P0.7 aktiv sein! Nun sind die Ports P0.0 bis P0.3 zu wählen (Binär -> wird dann in Dec 'gewandelt').
P0.4-P0.6 werden herausgefiltert.


![image](https://github.com/Jxrx02/SysNahe_TicTacToe_Asm/assets/131343499/3b2beae3-c09c-4f5e-889f-79ff68200532)
![image](https://github.com/Jxrx02/SysNahe_TicTacToe_Asm/assets/131343499/f4aedf33-dce5-4575-bf0f-f76f5df3f5a1)



Da virtuelle HW verwendet wird sollte man nach 1x Multiplexen ggf. 'Options' -> 'all fade out' klicken
![image](https://github.com/Jxrx02/SysNahe_TicTacToe_Asm/assets/131343499/4a8adade-6ede-4db6-97bb-b4493e985c94)


## 3. Vorlage wählen; sollte im Repo zu finden sein
![image](https://github.com/Jxrx02/SysNahe_TicTacToe_Asm/assets/131343499/997d7338-780e-44c0-bcc3-e910c9204e7e)
