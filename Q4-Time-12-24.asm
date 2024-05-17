; Este programa tem por objetivo usar a interrupção por hardware de "tique", a qual é definida como Int 8
; O sistema utiliza uma fonte de relogio de ~18.2 Hz, ou seja, a cada ~0.0549 segundos ou ~54.9 ms, o sistema é interrumpido

segment code
..start:
		MOV 	AX,data						; Inicializa o registrador de Segmento de Dados DS
		MOV 	DS,AX
		MOV 	AX,stack					; Inicializa o registrador de Segmento de Pilha SS
		MOV 	ss,AX
		MOV 	sp,stacktop					; Inicializa o apontador de Pilha SP
	
		
	
escreveNum:
		CLI								; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas	
        XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
        MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [ES:INT9*4]			; Carrega em AX o valor do IP do vector de INTerrupção 9 
        MOV     [offset_dos9], AX    	; Salva na variável offset_dos o valor do IP do vector de INTerrupção 9
        MOV     AX, [ES:INT9*4+2]   	; Carrega em AX o valor do CS do vector de INTerrupção 9
        MOV     [cs_dos9], AX			; Salva na variável cs_dos o valor do CS do vector de INTerrupção 9     
        MOV     [ES:INT9*4+2], CS		; Atualiza o valor do CS do vector de INTerrupção 9 com o CS do programa atual 
        MOV     WORD [ES:INT9*4],keyINT	; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "keyINT" do programa atual
        STI								; Habilita INTerrupções por hardware - pin INTR SIM atende INTerrupções externas

L1:
        MOV     AX,[p_i]				; loop - se não tem tecla pulsada, não faz nada! p_i só é atualizado (p_i = p_i + 1) na Rotina de Serviço de INTerrupção (ISR) "keyINT" 
        CMP     AX,[p_t]
        JE      L1
        INC     word[p_t]				; p_t - se atualiza (p_t = p_t + 1) só se p_i foi atualizado, ou seja, se teve tecla pulsada
        AND     word[p_t],7				
        MOV     BX,[p_t]				; Carrega em BX o valor de p_t
        XOR     AX, AX
        MOV     AL, [BX+tecla]			; Carrega em AL o valor da variável tecla (variável atualizada durante a ISR) mais o offset BX, AL <- [BX+tecla]  
        MOV     [tecla_u],al			; Transfere o valor de AL (no caso o valor da tecla - Código Make/Break) para variável "tecla_u"
        
		MOV     BL, 16					; Como AL contem o valor do código Make da tecla pulsada ou código Break da tecla liverada carrega BL com 16
        DIV     BL						; para dividir por 16 e representar em Hexa o valor do código Make/Break - "Lembrar que Cociente fical em AL e residuo em AH"
        ADD     Al, 30h					; Acrecenta 0x30 a AL para converter em ascii, por exemplo se for Make = 1, o ascii de 1 é 0x31			
        CMP     AL, 3Ah                 ; Se a tecla pulsada for differente de número, ou seja, se for uma letra o valor é superior a 0x3A. Ver tabela ascii
										; 
        JB      continua				; Se for numero de 0 até 9, daria 0x30 até 0x39, então pula para "continua"
        ADD     AL, 07h					; Se não for numero, acrescenta 7 para pular os carateres - ver tabela ascii

continua:        
        MOV     [teclasc], AL			; O cociente da divisão é transferido à variável "teclasc"
        ADD     AH, 30h					; Repete o processo com o ressiduo: Acrescenta 0x30 para converter em ascii,
        CMP     AH, 3Ah					; Verifica se é maior do que 0x39, ou seja, se é letra!
        JB      continua1				; Se não, então é numero (0x30 até 0x39) e pula para "continua1"
        ADD     AH, 07h					; Se não for numero, então é letra e acrescenta 7 para pular os carateres - ver tabela ascii

continua1:
        MOV     [teclasc+1], AH			; O ressiduo da divisão é transferido à variável "teclasc+1"
		
        CMP     BYTE [tecla_u], 0XAF	; Se for pulsada a tecla D 
        JE      L2						; Ele pula para L2 e usa o modo 12 horas
		CMP BYTE [tecla_u], 0xA0		; Se vor selecionado V, ele usa o modo 24 horas
		JE 		L3
        JMP     L1						; Se não, pula para L1 e começa tudo de novo!

L2:										; Ao sair do programa temos que restaurar o CS:IP da INTerrupção 9, que incialmente alteramos nas linhas 26 e 27
        CLI								; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
        XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
        MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
        MOV     AX, [cs_dos9]			; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
        MOV     [ES:INT9*4+2], AX		; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
        MOV     AX, [offset_dos9]		; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
        MOV     [ES:INT9*4], AX 		; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
		MOV		AX, 12
		MOV		[modoDeHora], AX
		JMP 	lerNum

L3:
	CLI								; Deshabilita INTerrupções por hardware - pin INTR NÃO atende INTerrupções externas
	XOR     AX, AX					; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"				
	MOV     ES, AX					; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
	MOV     AX, [cs_dos9]			; Carrega em AX o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos -> linha 25
	MOV     [ES:INT9*4+2], AX		; Atualiza o valor do CS do vector de INTerrupção 9 que foi salvo na variável cs_dos
	MOV     AX, [offset_dos9]		; Carrega em AX o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos -> linha 23
	MOV     [ES:INT9*4], AX 		; Atualiza o valor do IP do vector de INTerrupção 9 que foi salvo na variável offset_dos
	MOV		AX, 24
	MOV		[modoDeHora], AX
	JMP 	lerNum


lerNum:
		XOR 	AX, AX						; Limpa o registrador AX, é equivALente a fazer "MOV AX,0"
		MOV 	ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [ES:INTr*4]				; Carrega em AX o vALor do IP do vector de INTerrupção 8
		MOV     [offset_dos], AX    		; Salva na variável offset_dos o vALor do IP do vector de INTerrupção 8
		MOV     AX, [ES:INTr*4+2]   		; Carrega em AX o vALor do CS do vector de INTerrupção 8
		MOV     [cs_dos], AX  				; Salva na variável cs_dos o vALor do CS do vector de INTerrupção 8   
		MOV     [ES:INTr*4+2], CS			; Atualiza o valor do CS do vector de INTerrupção 8 com o CS do programa atuAL
		MOV     WORD [ES:INTr*4],ClockINT	; Atualiza o valor do IP do vector de INTerrupção 8 com o offset "ClockINT" do programa atuAL
		STI									; Habilita INTerrupções por harDWare - pin INTR SIM atende INTerrupções externas


volta:											; No loop principal l1, a função converte só é chamada se a variável tique for iguAL a 0, se não, verifica se ALguma tecla foi acionada para sair do programa
		CMP 	byte [tique], 0				; Compara variável tique com zero
		JNE 	ab							; Pula a ab se tique for diferente de zero	
		CALL 	converte					; Chama função converte se ab for iguAL a zero

ab:
		MOV 	AH,0Bh						; Carrega em AH o valor de 0Bh, parâmetro para ler o teclado com interrupção por software "INT 21h"	
		INT 	21h							; Le buffer de teclado e armazena em AL "0" se nehuma tecla foi acionada ou "1" se qualquer tecla foi acionada
		CMP 	AL,0						; Se o buffer está vacio, ou seja, nehuma tecla foi acionada pula para "l1", se não, pula para "fim"
		JNE 	fim							; Salto condicional -> se o teclado foi acionado pula para "fim"	
		JMP 	volta							; Salta para l1 se nehuma tecla foi acionada, ou seja, se a clausula do salto condicionla "linha 31" não foi acionada

fim:										; Ao sair do programa temos que restaurar o CS:IP da Interrupção 8, que INCialmente alteramos nas linhas 19 e 20
		CLI									; Deshabilita Interrupções por harDWare - pin INTR NÃO atende Interrupções externas							
		XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
		MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [cs_dos]				; Carrega em AX o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos -> linha 16
		MOV     [ES:INTr*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     AX, [offset_dos]			; Carrega em AX o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos				
		MOV     [ES:INTr*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos
		MOV     AH, 4Ch						; Carrega em AH o valor de 4Ch, parametro para INT 21h
		INT     21h							; Chama Interrupção 21h para RETornar o controle ao sistema operacional -> sai de forma segura da execução do programa

ClockINT:									; Este segmento de código só será executado se um pulso de relojio está ativo, ou seja, se a INT 8h for acionada!
		PUSH	AX							; Salva contexto na pilha							
		PUSH	DS
		MOV     AX,data						; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
		MOV     DS,AX						; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!	
    
		INC		byte [tique]				; Incremente variável tique toda vez que entra na interrupção
		CMP		byte[tique], 18				; Compara variável "teique" com 18, isso para alterar os valores do relogio a cada segundo -> 18/18.2 ~1 segundo!
		JB		Fimrel						; Se for menor que 18 pula para Fimrel
		MOV 	byte [tique], 0				; Se não, limpa variável tique e  
		INC 	byte [segundo]				; Incrementa variável segundo
		CMP 	byte [segundo], 60			; Compara variável "segundo" com 60
		JB   	Fimrel						; Se segundo for menor do que 60, pula para Fimrel
		MOV 	byte [segundo], 0			; Se não, limpa segundo e
		INC 	byte [minuto]				; Incrementa variável minuto
		CMP 	byte [minuto], 60			; Compara variável "minuto" com 60
		JB   	Fimrel						; Se minuto for menor do que 60, pula para Fimrel
		MOV 	byte [minuto], 0			; Se não, limpa minuto e
		INC 	byte [hora]					; Incrementa variável hora
		MOV		AH, byte[mode]
		CMP 	byte [hora], AH				; Compara variável "hora" com 24
		JB   	Fimrel						; Se hora for menor do que 24, pula para Fimrel
		MOV 	byte [hora], 0				; Se não, limpa hora	
Fimrel:
		MOV		AL,eoi						; Carrega o AL com a byte de End of Interruption, -> 20h por default						
		OUT		20h,AL						; Livera o PIC que está na porta 20h
		POP		DS							; Reestablece os registradores salvos na pilha na linha 46
		POP		AX
		IRET								; Retorna da interrupção
		
converte:									; Esta função conver os valores binarios/decimais para ascii, ou seja acrecenta 0x30 a cada numero
		PUSH 	AX							; Salva contexto na pilha
		PUSH    DS
		MOV     AX, data					; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
		MOV     DS, AX						; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
		
		XOR 	AH, AH						; Limpa AH, pois será utilizado na operação de divisão 
		MOV     BL, 10						; Carrega o operando da divisão
		MOV 	AL, byte [segundo]			; Carrega em AL o valor da variável segundo de 0 até 59
		DIV     BL							; Divide AL por BL, ou seja, AL/10. Como 10 é um byte, o cociente fica armacenado em AL e o residuo em AH 
		ADD     AL, 30h 					; Acrecenta 0x30 ao cociente para converter em ascii                                                                                          
		MOV     byte [horario+6], AL		; Atualiza a variável "horario" ná posição decenas de segundos
		ADD     AH, 30h						; Acrecenta 0x30 ao residuo para converter em ascii
		MOV 	byte [horario+7], AH		; Atualiza a variável "horario" ná posição unidades de segundos
											
		XOR 	AH, AH						; Repete o processo anterior para minutos
		MOV 	AL, byte [minuto]
		DIV     BL
		ADD     AL, 30h                                                                                          
		MOV     byte [horario+3], AL
		ADD     AH, 30h
		MOV 	byte [horario+4], AH
	
		XOR 	AH, AH						; Repete o processo anterior para horas
		MOV 	AL, byte [hora]
		DIV     BL
		ADD     AL, 30h                                                                                          
		MOV     byte [horario], AL
		ADD     AH, 30h
		MOV 	byte [horario+1], AH
		
		MOV 	AH, 09h						; Imprime o valor de horario com a interrupção 21h
		MOV 	dx, horario
		INT 	21h
		
		POP     DS							; Recupera contexto salvo nas linhas 75 e 76
		POP     AX
		RET 								; Retorna da função 

keyINT:									; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX						; Salva contexto na pilha
        PUSH    BX
        PUSH    DS
        MOV     AX,data					; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
        MOV     DS,AX					; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
        IN      AL, kb_data				; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        INC     WORD [p_i]				; Incrementa p_i para indicar no loop principal que uma tecla foi acionada!
        AND     WORD [p_i],7			
        MOV     BX,[p_i]				; Carrega p_i em BX
        MOV     [BX+tecla],al			; Transfere o valor Make/Break da tecla armacenado em AL "linha 84" para o segmento de dados com offset DX, na variável "tecla"
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Livera o PIC
		
		POP     DS						; Reestablece os registradores salvos na linha 79 
        POP     BX
        POP     AX
        IRET							; Retorna da interrupção

segment data
		kb_data 	EQU 60h  				; PORTA DE LEITURA DE TECLADO
        kb_ctl  	EQU 61h  				; PORTA DE RESET PARA PEDIR NOVA INTERRUPCAO
        pictrl  	EQU 20h					; PORTA DO PIC DE TECLADO
		eoi     	EQU 20h					; Byte de final de interrupção PIC - resgistrador OCW2 do 8259A
		INTr	   	EQU 08h					; Interrupção por hardware do tick
		INT9    	EQU 09h
		char		DB	0
		cs_dos9  	DW  1					; Variável de 2 bytes para armacenar o CS da INT 9
        offset_dos9 DW	1					; Variável de 2 bytes para armacenar o IP da INT 9
		offset_dos	DW	0					; Variável de 2 bytes para armacenar o IP da INT 8
		cs_dos		DW	0					; Variável de 2 bytes para armacenar o CS da INT 8
		tique		DB  0					; Variável de 2 bytes que é incrementada a cada tick do clock ~54.9 ms 
		segundo		DB  0					; Variável para os segundos
		minuto 		DB  0					; Variável para os minutos
		hora 		DB  0					; Variável para as horas
		horario		DB  0,0,':',0,0,':',0,0,' ', 13,'$' ; Variável typo string para printar o relogio
		modoDeHora	DB  0
		tecla_u db 0
        tecla   resb  8					; Variável de 8 bytes para armacenar a tecla presionada. Só precisa de 2 bytes!	 
        p_i     dw  0   				; Indice p/ Interrupcao (Incrementa na ISR quando pressiona/solta qualquer tecla)  
        p_t     dw  0   				; Indice p/ Interrupcao (Incrementa após retornar da ISR quando pressiona/solta qualquer tecla)    
        teclasc DB  0,0,13,10,'$'		; Variável tipo char para printar o código Make/Break em hexadecimal

segment stack stack							; Segmento da pilha -> SS
		resb 256							; Reserva 256 bytes para a pilha
stacktop:									; Define ponteiro do topo da pilha -> SP