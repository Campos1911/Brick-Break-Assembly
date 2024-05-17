segment code
..start:
		MOV 	AX,dados	; Inicialização de Registradores
		MOV 	DS,AX
		MOV 	AX,stack
		MOV 	SS,AX
		MOV 	SP,stacktop 
		
; AQUI COMECA A EXECUCAO DO PROGRAMA PRINCIPAL
		MOV 	DX,mensini 	; Carrega em DX o offset da mensagem de inicio
		MOV 	AH,9		; Parametro para imprimir uma string no DOS
		INT 	21h			; Chama interrupção 21h do DOS para imprimir string [mensini] 
					
		MOV 	AX,0 		; Primeiro elemento da série
		MOV 	BX,1 		; Segundo elemento da série
L10:
		MOV 	DX,AX		; Carrega em AX o primeiro elemento da série
		
		CALL	PrintNumb	; Chama a função PrintNumb para imprimir o número na tela
							; Depois de retornar da função PrintNumb o programa retorna na seguinte instrução
		ADD 	DX,BX 		; Calcula novo elemento da série DX = DX+BX
		MOV 	AX,BX		; Transfere o elemento anterior BX para AX
		MOV 	BX,DX		; Atualiza o valor atual (novo) da série em BX
		
		CMP 	DX, 1000		; Compara o valor atual da série DX com 100
		JB 		L10			; Se for menor pula para L10, se não, ele continua com a próxima linha

; AQUI TERMINA A EXECUCAO DO PROGRAMA PRINCIPAL
exit:
		MOV 	DX,mensfim 	; Carrega em DX o offset de Mensagem final
		MOV 	AH,9		; Parametro para imprimir uma string no DOS
		INT	 	21h			; Chama interrupção 21h do DOS para imprimir string
quit:
		MOV 	AH,4CH 		; retorna o controle para o DOS com código 0
		INT 	21h

;*****************************************************************

PrintNumb:
		PUSHF 					; Save the context
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH 	DX
				
		MOV 	DI,saida		; Carrega em DI o offset da mensagem saida
		MOV		CX,5
		MOV 	SI,0
		MOV 	BX,10000
		CALL 	bin2ascii		; Converte o valor decimal em ascii	

		MOV 	DX,saida		; Carrega em DX o offset da mensagem de saída, ou seja, o número convertido pela função bin2ascii
		MOV 	AH,9h			; Parametro para imprimir uma string no DOS
		INT 	21h         	; Chama o DOS para imprimir o valor da serie
		
; Upgrade the context
		POP 	DX
		POP 	CX
		POP		BX
		POP 	AX
		POPF
		RET

bin2ascii:	
	XOR 	DX,DX				; DX <- DX XOR DX. Zera o registrador DX.
	DIV 	BX					; AX <- (DX AX) / BX | DX <- Resto. Divide DX:AX por BX.
	ADD	 	AL,0x30				; AL <- AL+0x30. Soma 0x30 em AL (0x30 = '0').
	MOV 	byte[saida+SI],AL	; [saida] <- AL. Salva o número em ASCII na variavel 'saida'.
	
	PUSH	DX					; Empilha DX, Resto da divisão
	XOR 	DX,DX				; É necessário limpar o registrador para fazer a operação de divisão
	MOV		AX,BX				; Divide o Dividendo, ou seja 10000/10, 1000/10, 100/10 ou 10/10
	MOV 	BX,10
	DIV		BX
	MOV		BX,AX				; Atualiza o dividendo
	POP		DX					; Desempilha DX, Resto da divisão do valor en conversão
	INC		SI					; SI <- SI+1. Incrementa o offset da variável saída 
	MOV 	AX,DX				; AX <- DX. Passa valor de DX (Resto) para AX (novo valor a ser dividido). Atualiza o valor da conversão
	LOOP	bin2ascii
	RET
		
segment dados ;segmento de dados inicializados
CR 		EQU		13			; Define simbolos de 
LF 		EQU		10
mensini: 	db 'Programa que calcula a Serie de Fibonacci. ',CR,LF,'$'
mensfim: 	db 'Fim da serie!!',CR,LF,'$'
;saida: 		db '00000',CR,LF,'$'
saida: 		resb 5 
			db CR,LF,'$'

segment stack stack
resb 256 					; Reserva 256 bytes para formar a pilha
stacktop: