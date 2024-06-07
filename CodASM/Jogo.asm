segment code
..start:
    	mov 		ax,data
    	mov 		ds,ax
		mov 		ax,stack
		mov 		ss,ax
		mov 		sp,stacktop

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
		mov  		ah,0Fh
		int  		10h
		mov  		[modo_anterior],al   

; alterar modo de video para gráfico 640x480 16 cores
    	mov     	al,12h
   		mov     	ah,0
    	int     	10h
		

reset_game:
; Desenhando o campo (bordas brancas)
		mov		byte[cor],branco_intenso
		mov		ax, 0
		push 	ax
		mov		ax, 0
		push	ax
		mov		ax, 0
		push 	ax
		mov		ax, 479
		push	ax
		call	line

		mov		ax, 0
		push 	ax
		mov		ax, 479
		push	ax
		mov		ax, 639
		push 	ax
		mov		ax, 479
		push	ax
		call	line
		
		mov		ax, 639
		push 	ax
		mov		ax, 479
		push	ax
		mov		ax, 639
		push 	ax
		mov		ax, 0
		push	ax
		call	line

		; Carregando cx para fazer o loop e printar os quadrados (a cor é definida fora para ser incrementada dentro do loop)
		mov		cx, 6
		mov		byte[cor], azul
	
; Primeira linha de quadrados (linha superior)
fazQuadrado1:
		inc		byte[cor]
		mov		ax, word[x1A]
		push 	ax
		mov		ax, 477
		push	ax
		mov		ax, word[x2A]
		push 	ax
		mov		ax, 477
		push	ax
		call	line
		
		mov		ax, word[x2A]
		push 	ax
		mov		ax, 477
		push	ax
		mov		ax, word[x2A]
		push 	ax
		mov		ax, 437
		push	ax
		call	line
		
		mov		ax, word[x2A]
		push 	ax
		mov		ax, 437
		push	ax
		mov		ax, word[x1A]
		push 	ax
		mov		ax, 437
		push	ax
		call	line
		
		mov		ax, word[x1A]
		push 	ax
		mov		ax, 437
		push	ax
		mov		ax, word[x1A]
		push 	ax
		mov		ax, 477
		push	ax
		call	line
		add		word[x2A], 105
		add		word[x1A] , 105
		loop 	fazQuadrado1
		
		; Carregando cx para fazer o loop e printar os quadrados (a cor é definida fora para ser incrementada dentro do loop)
		mov		cx, 6
		mov		byte[cor], cinza
		
fazQuadrado2: ; Segunda linha de quadrados (linha inferior)
		inc		byte[cor]
		mov		ax, word[x1B]
		push 	ax
		mov		ax, 427
		push	ax
		mov		ax, word[x2B]
		push 	ax
		mov		ax, 427
		push	ax
		call	line
		
		mov		ax, word[x2B]
		push 	ax
		mov		ax, 427
		push	ax
		mov		ax, word[x2B]
		push 	ax
		mov		ax, 387
		push	ax
		call	line
		
		mov		ax, word[x2B]
		push 	ax
		mov		ax, 387
		push	ax
		mov		ax, word[x1B]
		push 	ax
		mov		ax, 387
		push	ax
		call	line
		
		mov		ax, word[x1B]
		push 	ax
		mov		ax, 387
		push	ax
		mov		ax, word[x1B]
		push 	ax
		mov		ax, 427
		push	ax
		call	line
		add		word[x2B], 105
		add		word[x1B] , 105
		loop 	fazQuadrado2


delay: ; Esteja atento pois talvez seja importante salvar contexto (no caso, CX, o que NÃO foi feito aqui).

continua:
    	call limpa_bola

        mov bx, [vx]
        add [px], bx
        mov bx, [vy]
        add [py], bx

		mov		byte[cor],	branco_intenso ; Bola branca
		mov		ax,[px]
		push		ax
		mov		ax,[py]
		push		ax
		mov		ax,16
		push		ax
		call	full_circle

		mov		ax, [player_x1] ; Desenhando a raquete
		push 	ax
		mov		ax, 10
		push	ax
		mov		ax, [player_x2]
		push 	ax
		mov		ax, 10
		push	ax
		call	line

        pop cx ; Recupera cx da pilha
        loop del1 ; No loop del1, cx é decrementado até que volte a ser zero
        loop del2 ; No loop del2, cx é decrementado até que seja zero
        ret

del2:
        push cx ; Coloca cx na pilha para usa-lo em outro loop
        mov cx, 0800h ; Teste modificando este valor

del1:
		mov	ax, 12
		cmp	word[pontuacao], ax
		je	intermediateWin
        mov bx, 615 ;Limita o campo na parte da direita
        cmp [px], bx
        jge moveesquerda

        mov bx, 20 ; Limita o campo na parte da esquerda
        cmp [px], bx
        jle movedireita

        mov bx, 364 ; Limita o campo na parte de cima
		mov	word[yToDelete1], 427
		mov	word[yToDelete2], 387
        cmp [py], bx
		jge intermediateMoveBaixo2

sobe_mais:
		mov	bx, 414
		mov	word[yToDelete1], 477
		mov	word[yToDelete2], 437
		cmp	[py], bx
		jge	intermediateMoveBaixo2

sobe_tudo:
		mov	bx, 450
		cmp	[py], bx
		jge	intermediateNaoApaga

        mov bx, 10 ; Limita o campo na parte de baixo
        cmp [py], bx
        jle movecima

        mov ah, 0bh      
        int 21h
        cmp al,0
        jne intermediateVerifTeclas
		call calcular_colisao_raquete
        jmp continua

		call delay
		call del1
		call del2

limpa_bola:
        mov     byte[cor],preto ; limpa bola
        mov     ax,[px]
        push        ax
        mov     ax,[py]
        push        ax
        mov     ax,20
        push        ax
        call    full_circle
        ret

intermediateWin
	jmp win_mensage

moveesquerda:
        call limpa_bola
		mov ax, [vx]
        neg ax
        mov bx, ax
        mov [vx], bx
        jmp continua

movedireita:
		call limpa_bola
        mov ax, [vx]
        neg ax
        mov bx, ax
        mov [vx], bx
        jmp continua

intermediateMoveBaixo2
	jmp movebaixo2

movecima:
        mov ax, [vy]
        neg ax
        mov bx, ax
        mov [vy], bx
        jmp continua

;  PONTOS INTERMEDIÁRIOS PARA AS FUNÇÕES

intermediateNaoApaga
	jmp	nao_apaga

intermediateVerifTeclas: ;	Função intermediária para pular para outra parte do código
	jmp verificar_teclas

intermediateSobeMais:
	jmp	sobe_mais

intermediateSobeTudo:
	jmp	sobe_tudo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

movebaixo2:
		mov ax, 5 ; Quadrado 1
		cmp [px], ax
		jge	verifica_quad1 ; Pula para verificar se acertou no limite do quadrado (todos repetem essa lógica)
volta1:
		mov ax, 110 ; Quadrado 2
		cmp [px], ax
		jge	verifica_quad2
volta2:
		mov ax, 215 ; Quadrado 3
		cmp [px], ax
		jge	intermediateVerificaQuad3
volta3:
		mov ax, 320 ; Quadrado 4
		cmp [px], ax
		jge	intermediateVerificaQuad4
volta4:
		mov ax, 425 ; Quadrado 5
		cmp [px], ax
		jge	intermediateVerificaQuad5
volta5:
		mov ax, 530 ; Quadrado 6
		cmp [px], ax
		jge	intermediateVerificaQuad6

intermediateVolta2
	jmp volta2

intermediateSobeTudo4
	jmp sobe_tudo

verifica_quad1:
		mov ax, 105
		cmp	[px], ax
		jg volta1 ; Se não acertou, volta para verificar o próximo quadrado
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado1]
		je	intermediateSobeTudo
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado1
		mov	ax, 1
		cmp ax, word[bloco_quebrado1]
		je	intermediateSobeMais
ignora1:
		mov word[apaga1], 5
		mov word[apaga2], 105
		mov	ax, 1
		mov	word[bloco_quebrado1], ax
		jmp	apaga_quad ; Se acertou no limite, apaga o quadrado e rebate a bola
cima_quebrado1:
	mov	ax, 1
	mov	word[bloco_cima_quebrado2], ax
	jmp	ignora1

intermediateSobeMais2:
	jmp intermediateSobeMais

intermediateSobeTudo2:
	jmp intermediateSobeTudo

intermediateVerificaQuad3:
	jmp verifica_quad3

intermediateVerificaQuad4:
	jmp verifica_quad4

intermediateVerificaQuad5:
	jmp verifica_quad5

intermediateVerificaQuad6:
	jmp verifica_quad6

verifica_quad2:
		mov ax, 210
		cmp	[px], ax
		jg intermediateVolta2
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado2]
		je	intermediateSobeTudo4
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado2
		mov	ax, 1
		cmp ax, [bloco_quebrado2]
		je	intermediateSobeMais2
ignora2:
		mov word[apaga1], 110
		mov word[apaga2], 210
		mov ax, 1
		mov	word[bloco_quebrado2], ax
		jmp	apaga_quad
cima_quebrado2:
	mov	ax, 1
	mov	word[bloco_cima_quebrado2], ax
	jmp	ignora2


;	Funções intermediárias para resolver o 'short jump
intermediateVolta4:
	jmp	volta4

intermediateVolta3:
	jmp	volta3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

verifica_quad3:
		mov ax, 315
		cmp	[px], ax
		jg intermediateVolta3
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado3]
		je	intermediateSobeTudo3
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado3
		mov	ax, 1
		cmp ax, [bloco_quebrado3]
		je	intermediateSobeMais3
ignora3:
		mov word[apaga1], 215
		mov word[apaga2], 315
		mov	ax, 1
		mov	word[bloco_quebrado3], ax
		jmp	apaga_quad

intermediateVolta5:
	jmp	volta5

cima_quebrado3:
	mov	ax, 1
	mov	word[bloco_cima_quebrado3], ax
	jmp	ignora3



verifica_quad4:
		mov ax, 420
		cmp	[px], ax
		jg intermediateVolta4
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado4]
		je	intermediateSobeTudo3
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado4
		mov	ax, 1
		cmp ax, [bloco_quebrado4]
		je	intermediateSobeMais3
ignora4:
		mov word[apaga1], 320
		mov word[apaga2], 420
		mov	ax, 1
		mov	word[bloco_quebrado4], ax
		jmp	apaga_quad
cima_quebrado4:
	mov	ax, 1
	mov	word[bloco_cima_quebrado4], ax
	jmp	ignora4



intermediateSobeMais3
	jmp intermediateSobeMais2

intermediateSobeTudo3
	jmp intermediateSobeTudo2

verifica_quad5:
		mov ax, 525
		cmp	[px], ax
		jg intermediateVolta5
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado5]
		je	intermediateSobeTudo3
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado5
		mov	ax, 1
		cmp ax, [bloco_quebrado5]
		je	intermediateSobeMais3
ignora5:
		mov word[apaga1], 425
		mov word[apaga2], 525
		mov	ax, 1
		mov	word[bloco_quebrado5], ax
		jmp	apaga_quad
cima_quebrado5:
	mov	ax, 1
	mov	word[bloco_cima_quebrado5], ax
	jmp	ignora5

verifica_quad6:
		mov ax, 630
		cmp	[px], ax
		jg intermediateNaoApaga2
		mov	ax, 1
		cmp ax, [bloco_cima_quebrado6]
		je	intermediateSobeTudo3
		mov	ax, 477
		cmp ax, word[yToDelete1]
		je	cima_quebrado6
		mov	ax, 1
		cmp ax, [bloco_quebrado6]
		je	intermediateSobeMais3
ignora6:
		mov word[apaga1], 530
		mov word[apaga2], 630
		mov	ax, 1
		mov	word[bloco_quebrado6], ax
		jmp	apaga_quad
cima_quebrado6:
	mov	ax, 1
	mov	word[bloco_cima_quebrado6], ax
	jmp	ignora6

intermediateNaoApaga2
	jmp nao_apaga

apaga_quad:
		inc		word[pontuacao]
		mov		byte[cor], preto
		mov		ax, word[apaga1]
		push 	ax
		mov		ax, word[yToDelete1]
		push	ax
		mov		ax, word[apaga2]
		push 	ax
		mov		ax, word[yToDelete1]
		push	ax
		call	line
		
		mov		ax, word[apaga2]
		push 	ax
		mov		ax, word[yToDelete1]
		push	ax
		mov		ax, word[apaga2]
		push 	ax
		mov		ax, word[yToDelete2]
		push	ax
		call	line
		
		mov		ax, word[apaga2]
		push 	ax
		mov		ax, word[yToDelete2]
		push	ax
		mov		ax, word[apaga1]
		push 	ax
		mov		ax, word[yToDelete2]
		push	ax
		call	line
		
		mov		ax, word[apaga1]
		push 	ax
		mov		ax, word[yToDelete2]
		push	ax
		mov		ax, word[apaga1]
		push 	ax
		mov		ax, word[yToDelete1]
		push	ax
		call	line

nao_apaga:
        mov ax, [vy]
        neg ax
        mov bx, ax
        mov [vy], bx
        jmp continua

sai:
        mov ah,0 ; set video mode
        mov al,[modo_anterior] ; recupera o modo anterior
        int 10h
        mov ax,4c00h
        int 21h

ganhou:
	    mov ah, 08h
        int 21h
		cmp al, 71h ;Compara a tecla com a letra 'q', fica parado aqui até apertar 'q' novamente
		jne ganhou
		jmp sai

verificar_teclas: ;Estrutura para decidir o que será feito durante o jogo
        push bp
        mov bp, sp
        mov ah, 08h
        int 21h
		cmp al, 70h ; Código ASCII para a tecla 'p'
		je	pausa
        cmp al, 71h ; Código ASCII para a tecla 'q'
        je sai
        cmp al, 64h ; Código ASCII para a tecla 'd'
        jne verificar_baixo
        call limpa_raquete ;Se 'd' não for pressionado, ele pula para baixo e mexe a raquete
        mov ax, 20 ;deslocamento de 20 em 20 da raquete
        mov bx, 630 ;testa se já chegou no limite
        cmp [player_x2], bx
        jge fim_verificar_teclas
        add ax, [player_x1]
        mov [player_x1], ax
        mov ax, 20
        add ax, [player_x2]
        mov [player_x2], ax
        jmp fim_verificar_teclas


pausa:
        mov ah, 08h
        int 21h
		cmp al, 70h ;Compara a tecla com a letra 'p', fica parado aqui até apertar 'p' novamente
		jne pausa
		jmp continua

verificar_baixo:
        cmp al, 61h
        jne fim_verificar_teclas
        call limpa_raquete
        mov ax, -20
        mov bx, 10
        cmp [player_x1], bx
        jle fim_verificar_teclas
        add ax, [player_x1]
        mov [player_x1], ax
        mov ax, -20
        add ax, [player_x2]
        mov [player_x2], ax
        jmp fim_verificar_teclas

fim_verificar_teclas:
        pop bp
        jmp continua

calcular_colisao_raquete:
        mov ax, 30
        cmp [py], ax
        je verifica_colisao_raquete
		jl game_over
        ret

verifica_colisao_raquete:
        mov bx, [player_x2]
        add bx, 16
        cmp [px], bx
        jle rebate_cima1
        mov bx, [player_x1]
        sub bx, 16
        cmp [px], bx
        jge rebate_baixo1
        ret

;FUNÇÕES RESPONSÁVEIS POR REBATER A BOLA E ALTERAR A DIREÇÃO (ESQUERDA OU DIREITA)
rebate_cima1:
		mov bx, [player_x1]
		sub bx, 16
		cmp [px], bx
		jge rebate_cima2
        ret

rebate_cima2:
        mov ax, [vy]
        neg ax
        mov bx, ax
		mov [vy], bx
        ret

rebate_baixo1:
        mov bx, [player_x2]
        add bx, 16
        cmp [px], bx
        jle rebate_baixo2
        ret

rebate_baixo2:
        mov ax, [vy]
        neg ax
        mov bx, ax
        mov [vy], bx
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

limpa_raquete: ;FUNÇÃO UTILIZADA PARA ATUALIZAR A POSIÇÃO DA RAQUETE 
        mov     byte[cor], preto
        mov     ax,[player_x1]
        push    ax
        mov     ax,10
        push    ax
        mov     ax,[player_x2]
        push    ax
        mov     ax,10
        push    ax
        call    line
        ret

game_over: ;;Escreve a mensagem na tela e espera a tecla do jogador
		mov     	cx,35			;número de caracteres
    	mov     	bx,0
    	mov     	dh,10			
    	mov     	dl,10
		mov		byte[cor],branco_intenso

repete_para_escrever:
		call	cursor
    	mov     al,[bx+mens_3]
		call	caracter
    	inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		loop repete_para_escrever

verfica_continua_ou_nao:
		push bp
        mov bp, sp

		mov ah, 08h
        int 21h
		cmp al, 6eh
		je	acaba
		cmp al, 79h
		je limpa_tudo
		RET

win_mensage: ;;Escreve a mensagem na tela e espera a tecla do jogador
		mov     	cx,31			;número de caracteres
    	mov     	bx,0
    	mov     	dh,12			
    	mov     	dl,12
		mov		byte[cor],branco_intenso

repete_para_escrever_win:
		call	cursor
    	mov     al,[bx+mens_4]
		call	caracter
    	inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
    	loop    repete_para_escrever_win
		jmp		ganhou

acaba: ;Finalizando o programa
		mov    	ah,08h
		int     21h
	    mov  	ah,0   					; set video mode
	    mov  	al,[modo_anterior]   	; modo anterior
	    int  	10h
		mov     ax,4c00h
		int     21h

limpa_tudo: ;FUNÇÃO PARA LIMPAR O CAMPO TODO E VOLTAR PARA O ZERO

	;Apagar as antigas funções (jogo passado)
	call limpa_bola
	call limpa_raquete

	;Redefinindo os parametros do jogo
	mov	ax, 0
	mov	word[bloco_quebrado1], ax
	mov	ax, 0
	mov	word[bloco_quebrado2], ax
	mov	ax, 0
	mov	word[bloco_quebrado3], ax
	mov	ax, 0
	mov	word[bloco_quebrado4], ax
	mov	ax, 0
	mov	word[bloco_quebrado5], ax
	mov	ax, 0
	mov	word[bloco_quebrado6], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado1], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado2], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado3], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado4], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado5], ax
	mov	ax, 0
	mov	word[bloco_cima_quebrado6], ax
	mov	ax, 0
	mov	word[apaga1], ax
	mov	ax, 0
	mov	word[apaga2], ax
	mov	ax, 0
	mov	word[pontuacao], ax
	mov	ax, 0
	mov	word[yToDelete1], ax
	mov	ax, 0
	mov	word[yToDelete2], ax
	mov	ax, 5
	mov	word[x1A], ax
	mov	ax, 105
	mov	word[x2A], ax
	mov	ax, 5
	mov	word[x1B], ax
	mov	ax, 105
	mov	word[x2B], ax
	mov	ax, 270
	mov	word[player_x1], ax
	mov	ax, 370
	mov	word[player_x2], ax
	mov	ax, 320
	mov	word[px], ax
	mov	ax, 30
	mov	word[py], ax
	mov	ax, 5
	mov	word[vx], ax
	mov	ax, 5
	mov	word[vy], ax
	mov al, ' '
	mov [bx+mens_3], al
	
	call reset_game

	call movebaixo2
	call volta1
	call volta2
	call volta3
	call volta4
	call volta5
	call verifica_quad1
	call ignora1
	call verifica_quad2
	call ignora2
	call verifica_quad3
	call ignora3
	call verifica_quad4
	call ignora4
	call verifica_quad5
	call ignora5
	call verifica_quad6
	call ignora6
	call apaga_quad

    ;Chamar as funções que desenham o jogo
	call reset_game

	;Pular para a função principal do jogo
	call continua


;***************************************************************************
;
;   função cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
    	mov     	ah,9
    	mov     	bh,0
    	mov     	cx,1
   		mov     	bl,[cor]
    	int     	10h
		pop			bp
		pop			di
		pop			si
		pop			dx
		pop			cx
		pop			bx
		pop			ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov			bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub			dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop			di
		pop			si
		pop			dx
		pop			cx
		pop			bx
		pop			ax
		popf	
		pop			bp
		ret			4
;_____________________________________________________________________________
;    fun��o circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di
		
		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r
		
		mov 	dx,bx	
		add		dx,cx       ;ponto extremo superior
		push    ax			
		push	dx
		call plot_xy
		
		mov		dx,bx
		sub		dx,cx       ;ponto extremo inferior
		push    ax			
		push	dx
		call plot_xy
		
		mov 	dx,ax	
		add		dx,cx       ;ponto extremo direita
		push    dx			
		push	bx
		call plot_xy
		
		mov		dx,ax
		sub		dx,cx       ;ponto extremo esquerda
		push    dx			
		push	bx
		call plot_xy
			
		mov		di,cx
		sub		di,1	 ;di=r-1
		mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
		
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
		mov		si,di
		cmp		si,0
		jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
		mov		si,dx		;o jl � importante porque trata-se de conta com sinal
		sal		si,1		;multiplica por doi (shift arithmetic left)
		add		si,3
		add		di,si     ;nesse ponto d=d+2*dx+3
		inc		dx		;incrementa dx
		jmp		plotar
inf:	
		mov		si,dx
		sub		si,cx  		;faz x - y (dx-cx), e salva em di 
		sal		si,1
		add		si,5
		add		di,si		;nesse ponto d=d+2*(dx-cx)+5
		inc		dx		;incrementa x (dx)
		dec		cx		;decrementa y (cx)
	
plotar:	
		mov		si,dx
		add		si,ax
		push    si			;coloca a abcisa x+xc na pilha
		mov		si,cx
		add		si,bx
		push    si			;coloca a ordenada y+yc na pilha
		call plot_xy		;toma conta do segundo octante
		mov		si,ax
		add		si,dx
		push    si			;coloca a abcisa xc+x na pilha
		mov		si,bx
		sub		si,cx
		push    si			;coloca a ordenada yc-y na pilha
		call plot_xy		;toma conta do s�timo octante
		mov		si,ax
		add		si,cx
		push    si			;coloca a abcisa xc+y na pilha
		mov		si,bx
		add		si,dx
		push    si			;coloca a ordenada yc+x na pilha
		call plot_xy		;toma conta do segundo octante
		mov		si,ax
		add		si,cx
		push    si			;coloca a abcisa xc+y na pilha
		mov		si,bx
		sub		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do oitavo octante
		mov		si,ax
		sub		si,dx
		push    si			;coloca a abcisa xc-x na pilha
		mov		si,bx
		add		si,cx
		push    si			;coloca a ordenada yc+y na pilha
		call plot_xy		;toma conta do terceiro octante
		mov		si,ax
		sub		si,dx
		push    si			;coloca a abcisa xc-x na pilha
		mov		si,bx
		sub		si,cx
		push    si			;coloca a ordenada yc-y na pilha
		call plot_xy		;toma conta do sexto octante
		mov		si,ax
		sub		si,cx
		push    si			;coloca a abcisa xc-y na pilha
		mov		si,bx
		sub		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do quinto octante
		mov		si,ax
		sub		si,cx
		push    si			;coloca a abcisa xc-y na pilha
		mov		si,bx
		add		si,dx
		push    si			;coloca a ordenada yc-x na pilha
		call plot_xy		;toma conta do quarto octante
		
		cmp		cx,dx
		jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
		jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
		
fim_circle:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
		push 	bp
		mov	 	bp,sp
		pushf                        ;coloca os flags na pilha
		push 	ax
		push 	bx
		push	cx
		push	dx
		push	si
		push	di

		mov		ax,[bp+8]    ; resgata xc
		mov		bx,[bp+6]    ; resgata yc
		mov		cx,[bp+4]    ; resgata r
		
		mov		si,bx
		sub		si,cx
		push    ax			;coloca xc na pilha			
		push	si			;coloca yc-r na pilha
		mov		si,bx
		add		si,cx
		push	ax		;coloca xc na pilha
		push	si		;coloca yc+r na pilha
		call line
		
			
		mov		di,cx
		sub		di,1	 ;di=r-1
		mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
		
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
		mov		si,di
		cmp		si,0
		jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
		mov		si,dx		;o jl � importante porque trata-se de conta com sinal
		sal		si,1		;multiplica por doi (shift arithmetic left)
		add		si,3
		add		di,si     ;nesse ponto d=d+2*dx+3
		inc		dx		;incrementa dx
		jmp		plotar_full

inf_full:	
		mov		si,dx
		sub		si,cx  		;faz x - y (dx-cx), e salva em di 
		sal		si,1
		add		si,5
		add		di,si		;nesse ponto d=d+2*(dx-cx)+5
		inc		dx		;incrementa x (dx)
		dec		cx		;decrementa y (cx)
	
plotar_full:	
		mov		si,ax
		add		si,cx
		push	si		;coloca a abcisa y+xc na pilha			
		mov		si,bx
		sub		si,dx
		push    si		;coloca a ordenada yc-x na pilha
		mov		si,ax
		add		si,cx
		push	si		;coloca a abcisa y+xc na pilha	
		mov		si,bx
		add		si,dx
		push    si		;coloca a ordenada yc+x na pilha	
		call 	line
		
		mov		si,ax
		add		si,dx
		push	si		;coloca a abcisa xc+x na pilha			
		mov		si,bx
		sub		si,cx
		push    si		;coloca a ordenada yc-y na pilha
		mov		si,ax
		add		si,dx
		push	si		;coloca a abcisa xc+x na pilha	
		mov		si,bx
		add		si,cx
		push    si		;coloca a ordenada yc+y na pilha	
		call	line
		
		mov		si,ax
		sub		si,dx
		push	si		;coloca a abcisa xc-x na pilha			
		mov		si,bx
		sub		si,cx
		push    si		;coloca a ordenada yc-y na pilha
		mov		si,ax
		sub		si,dx
		push	si		;coloca a abcisa xc-x na pilha	
		mov		si,bx
		add		si,cx
		push    si		;coloca a ordenada yc+y na pilha	
		call	line
		
		mov		si,ax
		sub		si,cx
		push	si		;coloca a abcisa xc-y na pilha			
		mov		si,bx
		sub		si,dx
		push    si		;coloca a ordenada yc-x na pilha
		mov		si,ax
		sub		si,cx
		push	si		;coloca a abcisa xc-y na pilha	
		mov		si,bx
		add		si,dx
		push    si		;coloca a ordenada yc+x na pilha	
		call	line
		
		cmp		cx,dx
		jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
		jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
			
fim_full_circle:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1

line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles

line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		
		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx
		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		
		sub		ax,si
		sub		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
segment data

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso


cor				db		branco_intenso
preto			equ		0
azul			equ		1
verde			equ		2
cyan			equ		3
vermelho		equ		4
magenta			equ		5
marrom			equ		6
branco			equ		7
cinza			equ		8
azul_claro		equ		9
verde_claro		equ		10
cyan_claro		equ		11
rosa			equ		12
magenta_claro	equ		13
amarelo			equ		14
branco_intenso	equ		15
deltax			dw		0
deltay			dw		0
modo_anterior	db		0

x1A				dw		5	;Usados para printar os quadrados
x2A				dw		105
x1B 			dw		5
x2B  			dw		105

apaga1			dw		0	;Variáveis para pegar qual quadrado apagar
apaga2			dw		0

player_x1    	dw      270	;Posição da raquete
player_x2    	dw      370

px      		dw      320	;Posição da bola
py      		dw      30

bloco_quebrado1	dw		0	;Variável para testar se a bola pode subir mais
bloco_quebrado2	dw		0
bloco_quebrado3	dw		0
bloco_quebrado4	dw		0
bloco_quebrado5	dw		0
bloco_quebrado6	dw		0

bloco_cima_quebrado1	dw		0 ;Variável para testar se a bola pode bater no 'teto'
bloco_cima_quebrado2	dw		0
bloco_cima_quebrado3	dw		0
bloco_cima_quebrado4	dw		0
bloco_cima_quebrado5	dw		0
bloco_cima_quebrado6	dw		0

pontuacao				dw		0

yToDelete1		dw		0
yToDelete2		dw		0

vx      		dw      5	;Velocidade que a bola anda
vy      		dw      5
mens_3      	db          'GAME OVER. Deseja continuar? Y ou N'
mens_4      	db          'FIM DE JOGO. Aperte Q para sair'

;*************************************************************************
segment stack stack
    		resb 		512
stacktop: