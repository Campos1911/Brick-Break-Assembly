[org 0x0100]

jmp start

startWAit: db 1
startkey: db 1
startMessege: db 'press a key to start'
borderc: db '*'
arr1: db 'level:'
arr2 : db 'score:'
arr3 : db 'lives:'
level : db 1
score : db 0
lives : db 3
oldisr : dd 0
ball : db 'O'
bxpos: db 15
bypos: db 39
right : db 1 
space: db ' ' 
tile: db 0
left : db 0
roof : db 0
board : dw 3584                 ;board is not used anymore replace it accordingly
boardposx: dw 22               ;new addition
boardposy: dw 32               ;new addition
boardy:db 0
boardarr: times 14 dw 0x0020       ; strings used to print and remove board using biosprint
boardspace: times 1 dw 0x0020
brickarr : times 14 dw 0x0020      ; brick string printed using biosprint
brickshow : db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
brickstart: db 4,22,42,62 
brickend: db 17,35,55,75
brickrow:db 4,6,8,10
tickcount: db 0
GameOver:db 0
brickCOLOR: db 0x60,0x20,0x30,0x40
brickNumbers: db 4,8,12,16
brickCounter:db 0
changeLevel : db 1
GameOverMessage: db'Game Over'
;ballMovement: db 1,0,0,0 ;start,left,right,Board touch
changeFactors:db 1,0;row,col
addORsub:db 1,2;if 0 sub , 1 add, 2 do nothing             ;row ,col

printnum: push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 mov ax, [bp+4] ; load number in ax
 mov bx, 10 ; use base 10 for division
 mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
 div bx ; divide by 10
 add dl, 0x30 ; convert digit into ascii value
 push dx ; save ascii value on stack
 inc cx ; increment count of values
 cmp ax, 0 ; is the quotient zero
 jnz nextdigit ; if no divide it again
 mov di, [bp+6]
 
 nextpos: pop dx ; remove a digit from the stack
 mov dh, 0x07 ; use normal attribute
 mov [es:di], dx ; print char on screen
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
 ret 4

 
Printball:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

push 7
mov ax,0
mov al,[bxpos]
push ax
mov al,[bypos]
push ax
push 1
push ball
call biosprint

pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret

clrscr:

push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov ax,0xb800
mov es,ax
mov di,0

loop1:                       
mov ax,0x0720
mov [es:di],ax
add di,2
cmp di,4000
jne loop1

pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret

border:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

push 0xb800
pop es
mov al,[borderc]
mov ah,0x07
mov cx,80
xor di,di
rep stosw

mov cx,25
mov di,160


left1:
mov [es:di],ax
add di,160
loop left1


mov di,318
mov cx,25

right1:
mov [es:di],ax
add di,160
loop right1



pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret

;BIOS print takes row,col,length,offset inorder as parameters
biosprint:

push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov ah, 0x13 ; service 13 - print string
 mov al, 0 ; subservice 01 – update cursor
 mov cx, [bp+12] ; normal attrib
 mov bh, 0 ; output on page 0
 mov bl,cl

 mov cx,0
 mov cx,[bp+10];row
 mov dh,cl  
 mov cx,0
 mov cx,[bp+8];cols
 mov dl,cl 
 mov cx, [bp+6] ; length of string
 push cs
 pop es ; segment of string
 mov bp, [bp+4] ; offset of string
 int 0x10 ; call BIOS video service
 
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret 10

brickprint:     ; to print bricks using biosprint

push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

push word[bp+8]
push word[bp+6]     ;row
push word[bp+4]      ;col
push 14    ;size of array
push brickarr
call biosprint

pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 6

eraseBRICK:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

push 0x07
push word[bp+6]     ;row
push word[bp+4]      ;col
push 14    ;size of array
push boardspace
call biosprint

pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret 4

print:

call border


push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov ax,0xb800
mov es,ax
mov di,3892

; printing level 

push 7
push 24
push 20
push 6
push arr1
call biosprint

 
mov al,[level]
add al,0x30
mov ah,0x02
mov [es:di],ax
add di,20

;  printing score
push 7
push 24
push 30
push 6
push arr2
call biosprint

mov ah,0
mov al,[score]

push di
push ax
call printnum
add di,20


; printing lives
push 7
push 24
push 40
push 6
push arr3
call biosprint


;printing board
push 0x10
push word[boardposx]
push word[boardposy]
push 14
push boardarr
call biosprint

;print lives
mov al,[lives]
add al,0x30
mov ah,0x02
mov [es:di],ax



mov ax,0
mov bp,0
mov bl,[level]
mov si,0
;printing bricks
LeveLLOOP:
mov cx,4
mov di,0
BrickLoop:
cmp byte[brickshow+si],0
je DONTprintBRICK


mov al,[brickCOLOR+bp]
push ax
mov al,[brickrow+bp]
push ax
mov al,[brickstart+di]
push ax
call brickprint
DONTprintBRICK:
inc di
inc si
 loop BrickLoop
 
 dec bl
 inc bp
 cmp bl,0
 jne LeveLLOOP



pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret

RetainBricks:

push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov cx,16
mov di,0
RetainBricksLoop:
mov byte[brickshow+di],1
inc di
loop RetainBricksLoop

pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret




BRICKremovals:
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di
push es

mov di,0
mov ax,0
mov dx,0
mov si,[bp+6]
mov cx,4

removalsL1:


mov dx,[bp+4]
mov al,[brickstart+di]
mov bl,[brickstart+di]
mov bh,[brickend+di]
;
;push di
;mov di,

cmp byte[brickshow+si],1
je leftS
jmp BRICKremovalsEXIT1
leftS:;;right side
cmp byte[bxpos],dl
jne rightS

add bh,1
cmp byte[bypos],bh
jne rightS
cmp byte[addORsub+1],0
jne rightS
mov byte[addORsub+1],1
mov byte[brickshow+si],0
mov dx,[bp+4]
push dx
push ax
call eraseBRICK
add byte[score],5
inc byte[brickCounter]

jmp BRICKremovalsEXIT

rightS:
mov dx,[bp+4]
mov bh,[brickend+di]
cmp byte[bxpos],dl
jne upS

sub bl,1
cmp byte[bypos],bl
jne upS
cmp byte[addORsub+1],1
jne upS
mov byte[addORsub+1],0
mov byte[brickshow+si],0
mov dx,[bp+4]
push dx
push ax
call eraseBRICK
add byte[score],5
inc byte[brickCounter]

jmp BRICKremovalsEXIT

upS:
mov dx,[bp+4]
mov bl,[brickstart+di]
dec dl
cmp byte[bxpos],dl
jne downS
cmp byte[addORsub],1
jne downS
upSCOL1:
cmp byte[bypos],bl
jb upSCOL2
cmp byte[bypos],bh

jna upSCHANGES
upSCOL2:
dec bl
cmp byte[bypos],bl
jb upSCOL3
cmp byte[addORsub+1],1
jne upSCOL3
cmp byte[bypos],bh

jna upSCHANGES
upSCOL3:
inc bl
inc bh
cmp byte[bypos],bl
jb downS
cmp byte[bypos],bh
ja downS
cmp byte[addORsub+1],0
jne downS
upSCHANGES:
mov byte[addORsub],0
mov byte[brickshow+si],0
mov dx,[bp+4]
push dx
push ax
call eraseBRICK
inc byte[brickCounter]

add byte[score],5
jmp BRICKremovalsEXIT

downS:
mov bl,[brickstart+di]
mov bh,[brickend+di]
mov dx,[bp+4]
inc dl
cmp byte[bxpos],dl
jne BRICKremovalsEXIT1
cmp byte[addORsub],0
jne BRICKremovalsEXIT1
downSCOL1:
cmp byte[bypos],bl
jb downSCOL2
cmp byte[bypos],bh
jna downchanges
downSCOL2:
dec bl
cmp byte[bypos],bl
jb downSCOL3
cmp byte[addORsub+1],1
jne downSCOL3
cmp byte[bypos],bh
jna downchanges
downSCOL3:
inc bl
inc bh
cmp byte[bypos],bl
jb BRICKremovalsEXIT1
cmp byte[bypos],bh
ja BRICKremovalsEXIT1
cmp byte[addORsub+1],0
jne BRICKremovalsEXIT1
downchanges:
mov byte[addORsub],1
mov byte[brickshow+si],0
mov dl,[bp+4]
push dx
push ax
call eraseBRICK
inc byte[brickCounter]
add byte[score],5
jmp BRICKremovalsEXIT


BRICKremovalsEXIT1:
inc di
inc si
dec cx
cmp cx,0
je BRICKremovalsEXIT
jmp removalsL1
;loop removalsL1

BRICKremovalsEXIT:

mov ax,0

mov dl,[level]
mov al,0
calculatebrickNumbers:
add al,4
dec dl
cmp dl,0
jne calculatebrickNumbers

cmp byte[brickCounter],al
jne EXitSimplely
add byte[level],1
;

mov byte[brickCounter],0
mov byte[lives],3
call RetainBricks
mov byte[changeLevel],1
mov byte[startWAit],1
mov byte[startkey],1
mov byte[bxpos],15
mov byte[bypos],39
mov word[boardposy],32
mov byte[addORsub+1],2
mov byte[addORsub],1
mov byte[changeFactors],1
mov byte[changeFactors+1],0
call clrscr
cmp byte[level],5
jne EXitSimplely
mov byte[changeLevel],0
mov byte[GameOver],1
EXitSimplely:
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp

ret 4



kbisr:

push ax
push bx
push cx
push dx
 
in al,0x60
cmp byte[changeLevel],1
je exit1
cmp byte[startWAit],1
je FirstExit1
cmp byte[startkey],1
je FirstKey1

cmp al,0x4b
jne nextcmp

cmp word[boardposy],1        ;left border condition
je exit1

push 0x07
push word[boardposx]
mov dx,[boardposy]
add dx,13                 ;printing space to erase end of board using biosprint
push dx
push 1
push boardspace
call biosprint
mov dx,[boardposy]
dec dl
cmp byte[bxpos],22
jne gonow1
cmp byte[bypos],dl
jne gonow1
cmp byte[addORsub+1],2
jne gonow1
;mov byte[addORsub+1],0
mov byte[bxpos],23

gonow1:
sub word[boardposy],1      ;changing board y position by 1
call print
jmp exit

FirstExit1:
jmp FirstExit
FirstKey1:
jmp FirstKey
exit1:
jmp exit

nextcmp:
cmp al,0x4d
jne exit

cmp word[boardposy],65   ;right border condition 65+14 = 79 as boardposy starts from 65 and is 14 bytes/words long 
je exit



push 0x07             ; printing space to erase start of board using biosprint
push word[boardposx]
mov dx,[boardposy]
push dx
push 1
push boardspace
call biosprint

mov dx,[boardposy]
add dl,14
cmp byte[bxpos],22
jne gonow2
cmp byte[bypos],dl
jne gonow2
cmp byte[addORsub+1],2
jne gonow2
;mov byte[addORsub+1],1
mov byte[bxpos],23

gonow2:
add word[boardposy],1      ;changing board y position by 1
call print
jmp exit

FirstExit:


mov byte[startWAit],0
jmp exit

FirstKey:
call clrscr
call print
mov byte[startkey],0


exit:
pop dx
pop cx
pop bx
pop ax
jmp far [cs:oldisr]

uball:
push ax
push dx
push cx
mov dx,0

;;ball is not in range;lost

uballcmp0:
cmp byte[bxpos],22
jne uballcmp1
cmp01:
mov dx,[boardposy]
dec dl
cmp dl,[bypos]
jne cmp02
cmp byte[addORsub+1],1
jne cmp02
mov byte[addORsub+1],0
jmp uballExit
cmp02:
mov dx,0
mov dx,[boardposy]
add dl,14
cmp dl,[bypos]
jne uballcmp1
cmp byte[addORsub+1],0
jne uballcmp1
mov byte[addORsub+1],1
jmp uballExit


uballcmp1:
cmp byte[bxpos],23
jnae cornerCASES
mov byte[startWAit],1
mov byte[startkey],1
mov byte[bxpos],15
mov byte[bypos],39
mov byte[addORsub+1],2
mov byte[addORsub],1
mov byte[changeFactors],1
mov byte[changeFactors+1],0
sub byte[lives],1
cmp byte[lives],0
jne NEXT1
mov byte[GameOver],1
jmp uballExit

NEXT1:
jmp uballExit

cornerCASES:
c1:
cmp byte[bxpos],1
jne c2
cmp byte[bypos],1
jne c2
mov byte[addORsub],1
mov byte[addORsub+1],1
jmp uballExit
c2:
cmp byte[bxpos],21
jne c3
cmp byte[bypos],1
jne c3
mov dx,0
mov dx,[boardposy]
cmp dl,1
jne c3
mov byte[addORsub],0
mov byte[addORsub+1],0
jmp uballExit 
c3:
cmp byte[bxpos],1
jne c4
cmp byte[bypos],78
jne c4
mov byte[addORsub],1
mov byte[addORsub+1],0
jmp uballExit 
c4:
cmp byte[bxpos],21
jne uballcmp2
cmp byte[bypos],78
jne uballcmp2
cmp byte[boardposy],65
jne uballcmp2
mov byte[addORsub],0
mov byte[addORsub+1],0
jmp uballExit 


uballcmp2:  ;thouches the right wall
cmp byte[bypos],78
jb uballcmp3

mov byte[addORsub+1],0
jmp uballExit

uballcmp3;thouches the left wall
cmp byte[bypos],1
jg uballcmp4

mov byte[addORsub+1],1
jmp uballExit

uballcmp4:;thouches the upper wall
cmp byte[bxpos],1
jnle uballcmp5

mov byte[addORsub],1
jmp uballExit


uballcmp5:  
cmp byte[bxpos],21
jne uballExit2
BOARDcmp1:;most left board

mov ax,[boardposy]
mov ah,0
cmp byte[addORsub],1
jne cmp001
cmp byte[addORsub+1],1
jne cmp001
mov dl,[bypos]
cmp dl,al
jae cmp001
;mov bl,dl
;add bl,13
;cmp bl,[bypos]
;jbe cmp001

add dl,[changeFactors+1]
cmp dl,al
jae task1
cmp001:

cmp [bypos],al
je task1
add al,1
cmp [bypos],al
je task1
add al ,1
cmp [bypos],al
je task1
jmp BOARDcmp2
task1:
mov byte[addORsub],0
mov byte[addORsub+1],0
mov byte[changeFactors+1],1
jmp uballExit

uballExit2:
 jmp uballExit
BOARDcmp2:;;centre
add al ,1
cmp [bypos],al
jb uballExit
add al ,7
cmp [bypos],al
ja BOARDcmp3
;jmp BOARDcmp3
task2:

mov byte[addORsub],0

jmp uballExit


BOARDcmp3:
add al,1
cmp [bypos],al
je task3
add al,1
cmp [bypos],al
je task3
add al ,1
cmp [bypos],al
je task3

cmp byte[addORsub],1
jne uballExit
cmp byte[addORsub+1],0
jne uballExit
mov dl,[bypos]
cmp dl,al
jbe uballExit
sub dl,[changeFactors+1]
cmp dl,al
jbe task3

jmp uballExit
task3:
mov byte[addORsub],0
mov byte[addORsub+1],1
mov byte[changeFactors+1],1
;jmp uballExit
uballExit:
call ApplyBAllCHanges
uballExitANDdont:
pop cx
pop dx
pop ax
ret

ApplyBAllCHanges:
push ax
mov ax,0
cmp byte[addORsub],1
jne ROWCMP2
mov al,[changeFactors]
add [bxpos],al

jmp colcmp1
ROWCMP2:
mov al,[changeFactors]
sub [bxpos],al



colcmp1:
cmp byte[addORsub+1],0
jne colCMP2
mov al,[changeFactors+1]
sub [bypos],al
cmp byte[bypos],1
jnl ApplyBAllCHangesEXIT
mov byte[bypos],1
jmp ApplyBAllCHangesEXIT
colCMP2:
cmp byte[addORsub+1],1
jne ApplyBAllCHangesEXIT
mov al,[changeFactors+1]
add [bypos],al
cmp byte[bypos],78
jna ApplyBAllCHangesEXIT
mov byte[bypos],78

ApplyBAllCHangesEXIT:
pop ax

ret

BRICKremovalsLevel:
push ax
push cx
push di
push bx
push si
push dx

mov ax,0
mov al,4
mov cx,0
mov cl,[level]
mov bx,0
BRICKremovalsLevelLOOP:

push bx
push ax
call BRICKremovals
add al,2

add bx,4
loop BRICKremovalsLevelLOOP

pop dx
pop si
pop bx
pop di
pop cx
pop ax

ret




timer:

;cli
push ax
push cx
push di
push bx

cmp byte[GameOver],1
je GameOverExit1
cmp byte[changeLevel],1
je GototimerExit2
cmp byte[level],5
je GameOverExit1
cmp byte[startWAit],1
je GototimerExit1
 cmp byte[tickcount],1
 jb skipTimer
call print
push 7
push word[bxpos]
push word[bypos]
push 1
push space
call biosprint
cmp byte[startkey],1
je GototimerExit
call uball
call Printball
call BRICKremovalsLevel



mov byte[tickcount],0
;call ApplyBAllCHanges
jmp timerExit
GototimerExit2:
jmp timerExit2
skipTimer:
add byte[tickcount],1
jmp timerExit
GototimerExit1:
jmp timerExit1
GameOverExit1:

call RetainBricks
mov byte[startWAit],1
mov byte[startkey],1
mov byte[GameOver],0
mov byte[lives],3
mov byte[changeLevel],0
mov word[boardposy],32
cmp byte[level],5
je SkipTHISshi
mov al,byte[brickCounter]
mov bl,5
mul bl
sub byte[score],al
mov byte[brickCounter],0
jmp GototimerExit
SkipTHISshi:
mov byte[brickCounter],0
mov byte[score],0
mov byte[level],1
call clrscr
GototimerExit:
push 7
push 15
push 35
push 9
push GameOverMessage
call biosprint

jmp timerExit
timerExit1:
push 7
push 17
push 30
push 20
push startMessege
call biosprint
jmp timerExit

timerExit2:
push 0x30
push 13
push 34
push 6
push arr1
call biosprint
mov ax,34
mov bl,80
mul bl
add ax,13
mov bl,12
mul bl
add ax,86
push ax
mov ax,0
mov al,[level]
push ax
call printnum


;jmp timerExit
cmp byte[tickcount],20
jne timerExit3
mov byte[changeLevel],0
mov byte[tickcount],0
call clrscr
jmp timerExit
timerExit3:
add byte[tickcount],1
jmp timerExit
timerExit:
mov al, 0x20
 out 0x20, al ; end of interrupt
 pop bx
 pop di
 pop cx
 pop ax
 iret ; return from interrupt

start:

call clrscr
;call print




mov ax,0
mov es,ax
mov ax,[es:9*4]
mov bx,[es:9*4+2]
mov [oldisr],ax
mov [oldisr+2],bx

cli
mov word[es:8*4],timer
mov [es:8*4+2],cs
sti



cli
mov word[es:9*4],kbisr
mov [es:9*4+2],cs
sti



l1: 
;cmp byte[level],2
jmp l1

cli
mov ax,[oldisr]
mov bx,[oldisr+2]
mov word[es:9*4],ax
mov [es:9*4+2],bx
sti

mov ax,0x4c00
int 0x21