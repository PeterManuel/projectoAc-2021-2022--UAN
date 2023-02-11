;----------PROJECTO DE ARQUITECTURA DE COMPUTADOR ANO LECTIVO 2022/2023-------
;-----------------------------------Docente: Dr. João Costa------------------------------
;------------------------------Linguagem de Programação:Assembly-------------------------
;--------------------------------------Processador: PEPE---------------------------------

;-----------------------------INTEGRANTES DO GRUPO DE DESENVOLVIMENTO--------------------
;                                      Gun ----- -------
;                                      Mary--------------
;                                      -----------------
;                                      -----------------
;                                      -----------------
;----------------------------------------------------------------------------------------

;------------------------definição de constantes numericas que serão usadas durante o jogo ---------
;----------------------------de modo a facilitar a identificação dos endereços ---------------------

    MATRIX_PIXEL EQU 8000H  ;constante que contem o valor do endereço do ecram
    TECLADO_IN EQU 0C000H   ;constante que contem o valor do endereço da entrada do teclado
    display_contador Equ 0A000H ;constante que contem o valor do endereço do dysplay hexadecimal
    TECLADO_OUT EQU 0E000H  ;constante que contem o valor do endereço da saida do teclado
    testador_de_linha_do_taclado	EQU	1 ;constante usada para iniciar  a testar apartir da linha 1 do teclado
    filtro_3_0	EQU	000FH ; máscara para isolar os 4 bits de menor peso	

PLACE		1000H ; definiu-se convencionalmente o espaço 
                  ;reservado para pilha apartir do endereço 1000H

pilha:		TABLE 100H	;reservando um tamanho de 256 bytes para pilha

FIM_PILHA:	; fazendo com que a etiqueta FIM_PILHA aponte para o topo da pilha

PLACE 2000H ; definiu-se convencionalmente o espaço 
            ;reservado para variaveis  apartir do endereço 2000H

stdin:WORD -1 ;espaço reservado de 2 bytes (16 bits) para armazernar qualquer tecla
              ; que for premida


buffer_mortos:string 0 ;espaço reservado de 1 byte (8 bits) para o numero de inimigos acertados
                       ;pelos torpedos
;------------------------valores de linha do teclado-----------------------------------

linha1:STRING -1,0,1,-1,2,-1,-1,-1,3  ;(contem valor 0,1,2,3)
linha2:STRING -1,4,5,-1,6,-1,-1,-1,7  ;(contem valor 4,5,5,7)
linha3:STRING -1,8,9,-1,0ah,-1,-1,-1,0ch  ;(contem valor 8,9,a,b)
linha4:STRING -1,0ch,0dh,-1,0eh,-1,-1,-1,0fh  ;(contem valor c,d,e,f)


;----valores usados para ativar pixel apartir de uma coordenada dada

valor_activo:STRING 80H,40H,20H,10H,08H,04H,02H,01H

;----valores usados para desativar pixel apartir de uma coordenada dada

valor_inativo:STRING 7FH,0BFH,0DFH,0EFH,0F7H,0FBH,0FDH,0FEH


;--------seccão na qual definimos os espaços em memoria que são usadas para
;--------armazenar cada objecto do jogo (tanques, balas e torpedos)

balaC :STRING 17
balaL :STRING 0
bala_estado :STRING 01h

torpedoC :STRING 0
torpedoL :STRING 0
torpedo_estado :STRING 01h

tanqueC :STRING 11
tanqueL :STRING 26
tanque_estado :STRING 01H

tanque_inimigo1C :STRING 3
tanque_inimigo1L :STRING 3
tanque_inimigo1_estado :STRING 1


tanque_inimigo2C :STRING 22
tanque_inimigo2L :STRING 4
tanque_inimigo2_estado :STRING 1

;--------fim da seccão na qual definimos os espaços em memoria que são usadas para
;--------armazenar cada objecto do jogo (tanques, balas e torpedos)


int0: STRING 0 ;espaço na qual é armazenada valor(0,1) para sinalizar a ocorrência de interrupcão 0
int1: STRING 0 ;espaço na qual é armazenada valor(0,1) para sinalizar o ocorrência de interrupcão 1


; tabela de palavra na qual é armazenada as direcções do tanque
vector_de_movimentacao_do_tanque: 
    WORD mover_tanque_esquerda   ;tecla 0
    WORD mover_tanque_direita ;tecla 1
    WORD mover_tanque_cima; tecla 2
    WORD mover_tanque_baixo;tecla 3
    WORD mover_tanque_superior_direito ;tecla 4
    WORD mover_tanque_superior_esquerdo;tecla 5
    WORD mover_tanque_inferior_direito;tecla 6
    WORD mover_tanque_inferior_esquerdo;tecla 7

;TABELAS PARA INTERRUPÇÕES
place 3000h
interrupcoes: WORD movimentacao_tanques
 WORD movimentacao_bala

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       PROGRAMA PRINCIPAL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
PLACE 0
main:
    mov	SP, FIM_PILHA
    MOV BTE,interrupcoes
    MOV R11,3

call desenha_tudo
    JMP game

    game:

    EI0 ;habilita interrupcão 0
    EI1 ;habilita interrupcão 1

    CALL pressionar_tecla ; chama o processo do teclado
    CALL movimenta_tanque ;chama o processo que permite movimentar o tanque assim 
                            ; que uma tecla(0--7) é pressionada

    CALL mover_tanqueinimigos ;chama o processo para movimentar tanques inimigos
                            ; assim que  ocorrer interrupcão 0

    CALL mover_bala_torpedo ;chama o processo para movimentar bala e torpedo
                            ; assim que  ocorrer interrupcão 1

    CALL averiguar_colisao_tanque2 ;chama o  processo para verificar se ocorreu uma colisão entre
                                    ; o torpedo e o tanque inimigo 2

    CALL averiguar_colisao_tanque1 ;chama o  processo para verificar se ocorreu uma colisão entre
                                    ; o o torpedo e o tanque inimigo 1

    call averiguar_colisao_tanque1_e_tamqueJogador ;chama o  processo para verificar se ocorreu uma colisão entre
                                    ; o tanque e o tanque inimigo 1

    call averiguar_colisao_tanque2_e_tamqueJogador ;chama o  processo para verificar se ocorreu uma colisão entre
                                    ; o tanque e o tanque inimigo 2
    CALL averiguar_bala_tanque ;chama o  processo para verificar se ocorreu uma colisão entre
                                    ; o tanque e a bala
    CALL contador_inimigos_mortos ;chama o processo que faz a contagem assim que um tanque inimigo
                                    ; é acertado pelo torpedo

    jmp game ;faz o loop infinito  do jogo

    fim_programa: JMP fim_programa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-------ROTINA DE APRESENTAÇÃO--------;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;rotina responsavel por fazer a apresentação dos objectos do jogo(tanque,tanques inimigos)
desenha_tudo:
    EI
    CALL desenha_taque
    CALL desenha_taque_inimigo1
    CALL desenha_taque_inimigo2
ret

;a rotina system_out é a rotina responsavel por ativar/desactivar(dependendo do valor de R3) 
;um determidado pixel dadas por coordenadas em linha e coluna armazenados em R1 e R2 

system_out:
    push R0
    push R1
    push R2
    push R3
    push R4

    mov R4,MATRIX_PIXEL ; faz com que R4 aponte para a endereço 8000h isto é na qual localizado
                        ;o PIXEL SCREEN

   ;faz o calculo do endereços  
    SHL R1,2  ;(R1<-r1*4)
    ADD R1,R4 ;(R1<-R1+R4)

    MOV R0,8 ;(R0<-8)
    MOV R4,R2 ;(R4<-R2)
    DIV R4,R0 ;(R4<-R4/R0)

    ;formula endereço=8000h + 4*linha(0..31) + byte(0..3)

    ESCREVA:
    ADD R1,R4 ; (R4«1<-R4)
    MOV R4,8 ; (R4<-8)
    MOD R2,R4 ;(R2<-R2%R4)

;compara o que se quer fazer(acender ou apagar pixel)

    CMP R3,1 ;se colocarmos valor 1 em R3 então é para desativar o pixel
    JZ APAGA ;(se R3==1 salta par APAGA)

    ;significa que se estiver um valor qualquer diferente de 1 em R3
    ;então supõe-se activar(acender um pixel)

;quando se quer acender
    ACENDE:
        MOV R4,valor_activo ;referencia o valor_activo cujos os valores servem para activar pixeis
        ADD R4,R2 ;acessa a posição do valor necessário para activar um determidado pixel

        MOVB R0,[R4] ;faz a leitura do valor  que se deseja escrever
        MOVB R2,[R1] ;faz a leitura do valor que já está presente na memória que se deseja escrever

        OR R0,R2 ; operação or de modo a manter a integridade da posição de memória na qual se deseja alterar
        JMP PIXEL

;quando se quer apagar
    APAGA:
        MOV R4,valor_inativo ;referencia o valor_inactivo cujos os valores servem para desactivar pixeis
        ADD R4,R2 ;acessa a posição do valor necessário para desactivar um determidado pixel

        MOVB R0,[R4]  ;faz a leitura do valor  que se deseja escrever
        MOVB R2,[R1]  ;faz a leitura do valor que já está presente na memória que se deseja escrever

        AND R0,R2 ; operação or de modo a manter a integridade da posição de memória na qual se deseja alterar
        JMP PIXEL

;passa o valor na matrix de pixel
    PIXEL:
    MOVB [R1], R0 ;escreve o valor independentemente do que se quer fazer (apagar ou acender)  que 
        ;deve ser escrito para memória alvo

    pop R4
    pop R3
    pop R2
    pop R1
    pop R0

    ret
;;;;;;FIM ROTINA DE APRESENTAÇÃO

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;FUNÇÕES DESENHO-TANQUES;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;TANQUE DO JOGADOR;;;;;;;;;;;;;;,
desenha_taque:
PUSH R1
PUSH R2

PUSH R4

MOV R4,tanqueL

MOVB R1,[R4]

MOV R4,tanqueC
MOVB R2,[R4]

call system_out

ADD R2,1
call system_out

ADD R1,1
call system_out

sub r2,3
add r1,1
mov r4,6

base_tanque:
CMP r4,0
jz fim_tanque

call system_out
add r2,1
sub r4,1
JMP base_tanque

fim_tanque:

POP R4
POP R2
POP R1
RET

;;;;; FIM DESENHAR TANQUE DO JOGADOR ;;;;;;;;;


;;;;;;  DESENHAR TANQUE INIMIGO1 ;;;;;;;;;

desenha_taque_inimigo1:
PUSH R1
PUSH R2
PUSH R4

MOV R4,tanque_inimigo1L

MOVB R1,[R4]

MOV R4,tanque_inimigo1C
MOVB R2,[R4]

call system_out

ADD R2,1

ADD R1,1
call system_out
ADD R1,1
call system_out
sub r2,2
add r1,1
mov r4,8

base1_tanque_inimigo1:
CMP r4,0
jz base2_tanque_inimigo1


call system_out
add r2,1
sub r4,1
JMP base1_tanque_inimigo1


base2_tanque_inimigo1:
sub r2,7
add r1,1
mov r4,6

loop1_tanque1:
CMP r4,0
jz base3_tanque_inimigo1
call system_out
add r2,1
sub r4,1
JMP loop1_tanque1

base3_tanque_inimigo1:
sub r2,5
add r1,1
mov r4,4

loop2_tanque1:
CMP r4,0
jz fim_tanque_inimigo1
call system_out
add r2,1
sub r4,1
JMP loop2_tanque1

fim_tanque_inimigo1:

POP R4
POP R2
POP R1
RET
;;;;;;;;; FIM TANQUE INIMIGO1 ;;;;;;;;;;;;;;

;;;;;;;;; DESENHAR TANQUE INIMIGO2 ;;;;;;;;;;

desenha_taque_inimigo2:
PUSH R1
PUSH R2
PUSH R4

MOV R4,tanque_inimigo2L

MOVB R1,[R4]

MOV R4,tanque_inimigo2C
MOVB R2,[R4]

call system_out

ADD R2,1

ADD R1,1
call system_out
ADD R1,1
call system_out

sub r2,2
add r1,1
mov r4,6

base1_tanque_inimigo2:
CMP r4,0
jz base2_tanque_inimigo2
call system_out
add r2,1
sub r4,1
JMP base1_tanque_inimigo2
base2_tanque_inimigo2:
sub r2,5
add r1,1
mov r4,4

loop1_tanque2:
CMP r4,0
jz fim_tanque_inimigo2
call system_out
add r2,1
sub r4,1
JMP loop1_tanque2

fim_tanque_inimigo2:

POP R4
POP R2
POP R1
RET
;;;;;;;;;;;;;; fim desenho tanque inimigo2 ;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; FUNÇÕES ACENDER TANQUES ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;; ACENDER e APAGAR TANQUE DO JOGADOR ;;;;;;;

acender_tanque:
PUSH R3
MOV R3,0
CALL desenha_taque
POP R3
RET
;;;;; fim acender tanque do jogador ;;;;;;

apagar_tanque:
PUSH R3
MOV R3,1
CALL desenha_taque
POP R3
RET
;;;;; fim apagar tanque do jogador ;;;;;;;

;;;;;;;;;;;;; ACENDER e APAGAR TANQUE INIMIGO1 ;;;;;;;;;;

acender_tanque1:
PUSH R3
MOV R3,0
CALL desenha_taque_inimigo1
POP R3
RET
;;;;;;;;;;;;;;;;;;fim acender tanque inimigo1 ;;;;;;;;;;;

apagar_tanque1:
PUSH R3
MOV R3,1
CALL desenha_taque_inimigo1
POP R3
RET
;;;;;;;;;;;;;;;;;fim apagar tanque inimigo1 ;;;;;;;;;;;;;;

;;;;;;;;;;;;; ACENDER e APAGAR TANQUE INIMIGO2 ;;;;;;;;;;;
acender_tanque2:
PUSH R3
MOV R3,0
CALL desenha_taque_inimigo2
POP R3
RET
;;;;;;;;;;;;;;;; fim acender tanque inimigo2 ;;;;;;;;;;;;;;

apagar_tanque2:
PUSH R3
MOV R3,1
CALL desenha_taque_inimigo2

POP R3
RET
;;;;;;;;;;;;;;;; fim apagar tanque inimigo2 ;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; FUNÇÕES MOVIMENTAR TANQUE DO JOGADOR ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; INICIO BAIXAR TANQUE ;;;;;;;;;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo na posição mais a baixo

mover_tanque_baixo:

PUSH R4
PUSH R5

MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,29
CMP R5,R4
JZ fim_mover_baixo

call apagar_tanque 
                    
MOV R4,tanqueL        
MOVB R5,[R4]        

ADD R5,1            
MOVB [R4],R5        

CALL acender_tanque

fim_mover_baixo:

POP R5
POP R4

RET
;;;;;;;;;;;;;;;;;;;; fim baixar tanque ;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;; INICIO SUBIR TANQUE ;;;;;;;;;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo na posição mais acima

mover_tanque_cima:

PUSH R4
PUSH R5
; restringir o movimento de cima para o tanque
MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,0
CMP R5,R4
JZ fim_mover_cima
; fim restringir o movimento de cima para o tanque


call apagar_tanque

MOV R4,tanqueL
MOVB R5,[R4]

SUB R5,1

MOVB [R4],R5

CALL acender_tanque
fim_mover_cima: 

POP R5
POP R4

RET
;;;;;;;;;;;;;;;; fim subir tanque ;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; INICIO MOVER TANQUE A DIREITA ;;;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo na posição mais a direita

mover_tanque_direita:

PUSH R4
PUSH R5

MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,28
CMP R5,R4
JZ fim_mover_direita

call apagar_tanque

MOV R4,tanqueC
MOVB R5,[R4]

ADD R5,1

MOVB [R4],R5

CALL acender_tanque

fim_mover_direita:


POP R5
POP R4

RET
;;;;;;;;;;;;;;;; fim mover tanque direita ;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;; INICIO MOVER TANQUE A ESQUERDA ;;;;;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo na posição mais a direita

mover_tanque_esquerda:

PUSH R4
PUSH R5
MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,2
CMP R5,R4
JZ fim_mover_esquerda
call apagar_tanque

MOV R4,tanqueC
MOVB R5,[R4]

SUB R5,1

MOVB [R4],R5

CALL acender_tanque

fim_mover_esquerda:

POP R5
POP R4

RET
;;;;;;;;;;;;;;;; fim mover tanque a esquerda ;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;; INICIO MOVER TANQUE AO CANTO SUPERIOR DIREITO ;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo no seu correspondente canto superior direito

mover_tanque_superior_direito:


PUSH R4
PUSH R5

MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,28
CMP R5,R4
JZ fim_canto_superior_directo

MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,0
CMP R5,R4
JZ fim_canto_superior_directo

call apagar_tanque

;coluna
MOV R4,tanqueC
MOVB R5,[R4] ;faz a leitura da coluna do tanque

ADD R5,1

MOVB [R4],R5

;linha

MOV R4,tanqueL
MOVB R5,[R4] ;faz a leitura lnha do tanque

SUB R5,1

MOVB [R4],R5

CALL acender_tanque

fim_canto_superior_directo:

POP R5
POP R4

RET
;;;;;;;;;;;;; fim mover tanque ao canto superior direito ;;;;;;;;


;;;;;;;;;;;;;; INICIO MOVER TANQUE AO CANTO SUPERIOR ESQUERDO ;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo no seu correspondente canto superior esquerdo

mover_tanque_superior_esquerdo:

PUSH R4
PUSH R5

MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,2
CMP R5,R4
JZ fim_canto_superior_esquerdo

MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,0
CMP R5,R4
JZ fim_canto_superior_esquerdo


call apagar_tanque

;coluna
MOV R4,tanqueC
MOVB R5,[R4] ;faz a leitura da coluna do tanque

SUB R5,1

MOVB [R4],R5

;linha

MOV R4,tanqueL
MOVB R5,[R4] ;faz a leitura lnha do tanque

SUB R5,1

MOVB [R4],R5

CALL acender_tanque
fim_canto_superior_esquerdo:

POP R5
POP R4

RET
;;;;;;;;;;;; fim mover tanque ao canto superior esquerdo ;;;;;;;;

;;;;;;;;;;;;;; INICIO MOVER TANQUE AO CANTO INFERIOR DIREITO ;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo no seu correspondente canto inferior direito

mover_tanque_inferior_direito:

PUSH R4
PUSH R5

MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,28
CMP R5,R4
JZ fim_canto_inferior_direito

MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,29
CMP R5,R4
JZ fim_canto_inferior_direito


call apagar_tanque


;coluna
MOV R4,tanqueC
MOVB R5,[R4] ;faz a leitura da coluna do tanque

ADD R5,1

MOVB [R4],R5

;linha

MOV R4,tanqueL
MOVB R5,[R4] ;faz a leitura lnha do tanque

ADD R5,1

MOVB [R4],R5

CALL acender_tanque
fim_canto_inferior_direito:


POP R5
POP R4

RET
;;;;;;;;;;;; fim mover tanque ao canto inferior direito ;;;;;;;;

;;;;;;;;;;;;;; INICIO MOVER TANQUE AO CANTO INFERIOR DIREITO ;;;;;;;;;;
; resume-se em apagar o tanque na posição actual  
; para acendê-lo no seu correspondente canto inferior esquerdo

mover_tanque_inferior_esquerdo:

PUSH R4
PUSH R5

MOV R4,tanqueC        
MOVB R5,[R4]  
MOV R4,2
CMP R5,R4
JZ fim_canto_inferior_esquerdo

MOV R4,tanqueL        
MOVB R5,[R4]  
MOV R4,29
CMP R5,R4
JZ fim_canto_inferior_esquerdo


call apagar_tanque

;coluna
MOV R4,tanqueC
MOVB R5,[R4] ;faz a leitura da coluna do tanque

SUB R5,1

MOVB [R4],R5

;linha
MOV R4,tanqueL
MOVB R5,[R4] ;faz a leitura lnha do tanque

ADD R5,1

MOVB [R4],R5

CALL acender_tanque
fim_canto_inferior_esquerdo:

POP R5
POP R4

RET
;;;;;;;;;;;; fim mover tanque ao canto inferior esquerdo ;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;  FUNÇÕES MOVER TANQUES INIMIGOS ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; resume-se em mover os tanques do topo para a base  
; os tanques vão surgindo/desenhados acendidos no topo
; e posteriormento apagados para voltarem a ser acendidos
; em posições mais baixas

;;;;;;;;;;;  INICIO MOVER TANQUE INIMIGO 1;;;;;;;;;;;;;;;;;;;;;
mover_tanqueinmigo1_baixo:

PUSH R1
PUSH R2
PUSH R4

call apagar_tanque1

MOV R2,32

MOV R4,tanque_inimigo1L
MOVB R1,[R4]

continua1:
ADD R1,1
MOVB [R4],R1

CMP R1,R2
JNZ keep
CALL inicializa_tanqueinmigo1_posicao


keep:
CALL acender_tanque1

POP R4
POP R2
POP R1
RET
;;;;;;;;;;;; fim mover tanque inimigo1 ;;;;;;;;

;;;;;;;;;;;  INICIO MOVER TANQUE INIMIGO 2;;;;;;;;;;;;;;;;;;;;;
mover_tanqueinmigo2_baixo:

PUSH R1
PUSH R2
PUSH R4

call apagar_tanque2

MOV R2,32

MOV R4,tanque_inimigo2L
MOVB R1,[R4]

continua2:
ADD R1,1
MOVB [R4],R1

CMP R1,R2
JNZ keep2
CALL inicializa_tanqueinmigo2_posicao


keep2:
CALL acender_tanque2

POP R4
POP R2
POP R1
RET



inicializa_tanqueinmigo1_posicao:

PUSH R1
PUSH R2
PUSH R4



MOV R4,tanque_inimigo1L
MOV R1,0
MOVB [R4],R1


MOV R4,tanque_inimigo1C
MOV R1,3
MOVB [R4],R1


POP R4
POP R2
POP R1
RET


inicializa_tanqueinmigo2_posicao:

PUSH R1
PUSH R2
PUSH R4



MOV R4,tanque_inimigo2L
MOV R1,0
MOVB [R4],R1


MOV R4,tanqueC
MOVB R1,[R4]

MOV R4,tanque_inimigo2C

SUB R1,2

MOVB [R4],R1


POP R4
POP R2
POP R1
RET

mover_tanqueinimigos:

PUSH R1
PUSH R4

DI0

MOV R1,int0
MOVB R4,[R1]
CMP R4,1
JNZ fim_mover_tanqueinimigos

CALL mover_tanqueinmigo1_baixo
CALL mover_tanqueinmigo2_baixo

MOV R1,int0
MOV R4,0
MOVB [R1],R4


fim_mover_tanqueinimigos:



POP R4
POP R1
RET


mover_bala_torpedo:

PUSH R1
PUSH R4

DI1

MOV R1,int1
MOVB R4,[R1]
CMP R4,1
JNZ fim_bala_torpedo

CALL controle_para_torpedo
CALL controle_para_bala

MOV R1,int1
MOV R4,0
MOVB [R1],R4

fim_bala_torpedo:

POP R4
POP R1
RET

;;;;;;;;;;;; fim mover tanque inimigo1 ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; TRATAMENTO DO TECLADO ;;;;;;;;;;;
; resume-se em descobrir que tecla foi primida 
; e fazer a correspondência da função determinada para a tecla
;!!! requer teória do funcionamento do teclado


pressionar_tecla:
PUSH  R1
PUSH R5
PUSH R6
PUSH R7
PUSH R9

MOV	R5, TECLADO_IN ;referencia a saida do teclado
MOV	R6, TECLADO_OUT ;referencia a entrada do teclado
MOV R9,stdin ;referencia o endereço de memória na qual será armazenada a tecla que for pressionada

MOV	R1, testador_de_linha_do_taclado ;passa o valor 0001 em R1( valor para testar a 1ª linha do teclado)
                                
testa_linha:                        
CMP R1,7 ;(verifica se já testou todas as linhar)
          
JGT nenhuma_tecla_primida ;caso R1 tenha valor maior que 7 então todas as linhas foram testadas
                            ; e nenhuma tecla foi premida

MOVB [R5], R1	;activar a linha a ser testada
	MOVB 	R7, [R6]	; ler a saida do teclado
	MOV R10,filtro_3_0
	AND R7,R10 ;sendo que para o teclado somente entra ou sai 4bits então deve filtrar de modo a evitar
               ;interferência
	AND R7, R7	;fazendo a operação and de modo a saber se o valor diferente de zero	
	JNZ guardar		; caso for diferente de zero então alguma tecla foi premida e deve guardar na memoria
	
	SHL R1,1 ; faz o deslocamento de bit de modo a testar outra linha
JMP testa_linha ;repete o pocesso de teste de linha do teclado

nenhuma_tecla_primida: ;seccão em todas linhas foram testada isto é até a 4ª e nenhuma
                        ; foi premida sendo assim deve armazernar -1
	MOV R7,-1
	MOV [R9],R7
	JMP fim_tecla
	guardar:
	CALL descodifica_tecla_primida ;se alguma tecla foi premida então deve
                                    ; chamar a função de modo a decofificar a tecla premida

	fim_tecla:

POP R9
POP R7
POP R6
POP R5
POP R1
RET	

;;;;;;;; fim tratamento do teclado ;;;;;;;;;;;;

;;;;;;;; Descodificando a tecla primida ;;;;;;;;;
descodifica_tecla_primida:
PUSH R1
PUSH R7
PUSH R9
; faz a verificão para saber que linha cuja tecla foi activa
   cmp r1,1 
    jz linha_teclado1

    cmp r1,2
    jz linha_teclado2

    cmp r1,4
    jz linha_teclado3

    jz linha_teclado4
	
; fim da verificão para saber que linha cuja tecla foi activa

    linha_teclado1:

    mov r1,linha1
    add r1,r7 ; acessa o indice da tecla premida
    jmp salvar_tecla

    linha_teclado2:

    mov r1,linha2
    add r1,r7 ; acessa o indice da tecla premida
    jmp salvar_tecla

    linha_teclado3:

    mov r1,linha3
    add r1,r7 ; acessa o indice da tecla premida
    jmp salvar_tecla

        linha_teclado4:

    mov r1,linha4
    add r1,r7 ; acessa o indice da tecla premida

salvar_tecla:
MOVB R7,[R1] ; acessa o valor da lecla em uma da linha que foi activa
MOV [R9],R7 ; armazena o valor da tecla que é premida
POP R9
POP R7
POP R1
RET
;;;;;;;;;;;; fim descodificar tecla comprimida ;;;;;;;;

movimenta_tanque:
PUSH R0
PUSH R1
PUSH R2
PUSH R3

MOV R0,stdin 
MOV R1,tanque_estado
MOVB R3,[R1]

CMP R3,2
JZ tanque_estado2

tanque_estado1:
    MOV R1,[R0]
    CMP R1,-1
    JZ fim_movimento_tanque
    CMP R1,7
    JGT fim_movimento_tanque    ; se for > 7 fim, movimentamos apenas com 7 teclas

    MOV R2,vector_de_movimentacao_do_tanque
    SHL R1,1
    ADD R2,R1
    MOV R1,[R2]
    CALL R1
    MOV R1,2
    MOV R3,tanque_estado
    MOVB [R3],R1
    JMP fim_movimento_tanque

tanque_estado2:
    MOV R1,[R0]
    CMP R1,-1
    JNZ fim_movimento_tanque
    MOV R1,1
    MOV R3,tanque_estado
    MOVB [R3],R1

fim_movimento_tanque:

POP R3
POP R2
POP R1
POP R0
RET

;;;;;;Tratamento do torpeto;;;;;;;;
; resume-se em disparar torpedos enquadrados na matriz
; de acordo as coordenadas principais do tanque do jogador

carregar_torpedo:
push r1
push r2
push r4

MOV R4,tanqueL
MOVB R1,[R4]
SUB R1,3
MOV R4,torpedoL
MOVB [R4],R1

MOV R4,tanqueC
MOVB R2,[R4]
SUB R2,2
MOV R4,torpedoC
MOVB [R4],R2

MOV R4,torpedo_estado
MOV R1,1
MOVB [R4],R1

pop r4
pop r2
pop r1

ret
;;;;;;;; fim tratamento do torpedo ;;;;;;;;;;;;;

;;; tratamento da imagem do torpedo ;;;;
; resume-se em apresentar na tela a imagem do torpedo

desenha_torpedo:
PUSH R1
PUSH R2
PUSH R4

init_torp:

MOV R4,torpedoL
MOVB R1,[R4]

MOV R4,torpedoC
MOVB R2,[R4]
MOV R4,3
loop_torpedo:
CMP R4,0
JZ fim_torpedo
call system_out
SUB R1,1
SUB R4,1
JMP loop_torpedo

fim_torpedo:

POP R4
POP R2
POP R1
RET
;;;;;;;; fim desenhar torpedo ;;;;;;;;;;;

;;;;;; Acender torpedo ;;;;;;;;;;;;;;;;;
acender_torpedo:
PUSH R3
MOV R3,0
CALL desenha_torpedo
POP R3
RET
;;;;;;;;;; fim acender torpedos ;;;;;;;;;;;;;

;;;;;;;;;;;; Apagar Torpedos ;;;;;;;;;;;;;;;;;
apagar_torpedo:
PUSH R3
MOV R3,1
CALL desenha_torpedo
POP R3
RET
;;;;;;;;;; fim apagar torpedos ;;;;;;;;;;;;;;;

;;;;;;;;;;;;; DISPARAR TORPEDO;;;;;;;;;;;;;;;;;;;;;
; resume-se em movimentar o torpedo  para comprimida

mover_torpedo_cima:

PUSH R1
PUSH R2
PUSH R3
PUSH R4

;MOV R3,stdin

;MOVB R2,[R3]
;MOV R3,8
;CMP R2,R3
;JZ  

draw_torp:
call apagar_torpedo

MOV R4,torpedoL
MOVB R1,[R4]

SUB R1,1

MOVB [R4],R1

CALL acender_torpedo


POP R4
POP R1
RET

controle_para_torpedo: 
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5
PUSH R6
PUSH R8
PUSH R9


init_stat:

MOV R2,torpedo_estado
MOVB R1,[R2]
CMP R1,1
JZ torp_proc1
CMP R1,2
JZ torp_proc2

CMP R1,3
JZ torp_proc3

CMP R1,5
JZ torp_proc5

torp_proc1:

MOV R8,0
MOV R5,8
MOV R0,stdin
MOV R1,[R0]

CMP R1,R5
JNZ sair_torp_proc
CALL carregar_torpedo
MOV R5,2
MOVB [R2],R5
JMP sair_torp_proc

torp_proc2:
CALL acender_torpedo
MOV R5,3
MOVB [R2],R5
MOV R8,torpedoL
MOVB R1,[R8]
MOV R8,0
CMP R1,R8
JNZ sair_torp_proc
MOV R2,torpedo_estado
MOV R5,5
MOVB [R2],R5
JMP sair_torp_proc

torp_proc3:

CALL apagar_torpedo
CALL movimentar_o_torpedo_para_cima
MOV R2,torpedo_estado
MOV R5,2
MOVB [R2],R5
JMP sair_torp_proc

torp_proc5:
MOV R2,torpedo_estado
MOV R5,8
MOV R0,stdin
MOV R1,[R0]
CMP R1,R5
JZ sair_torp_proc
MOV R5,1
MOVB [R2],R5

sair_torp_proc:

POP R9
POP R8
POP R6
POP R5
POP R4
POP R3
POP R2
POP R1
POP R0

RET

movimentar_o_torpedo_para_cima:
PUSH R1

PUSH R4

MOV R4,torpedoL
MOVB R1,[R4]
SUB R1,1
MOVB [R4],R1
POP R4

POP R1
RET

reinicia_torpedo:
PUSH R1

PUSH R4

MOV R4,torpedoL
MOV R1,0
MOVB [R4],R1

MOV R4,torpedoC
MOV R1,0
MOVB [R4],R1


MOV R4,torpedo_estado
MOV R1,5
MOVB [R4],R1

POP R4

POP R1
RET

;;;;;;;;; fim disparar torpedo ;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; TRATAMENTO DAS BALAS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; desenhamos as balas, acendendo, apagando
; e  movendos de forma a criar disparos 

;;;;;;;;;;;;; Desenhar Balas ;;;;;;;;;;;;;;
desenha_bala:
PUSH R1
PUSH R2
PUSH R4

MOV R4,balaL
MOVB R1,[R4]

MOV R4,balaC
MOVB R2,[R4]

CALL system_out

fim_bala:

POP R4
POP R2
POP R1
RET
 ;;;;;;;; fim desenhar controle_para_bala ;;;;;;;;;;;;;;;

 ;;;;;;;;;;; Acender Balas ;;;;;;;;;;;;;;;;
acender_bala:
PUSH R3
MOV R3,0
CALL desenha_bala
POP R3
RET
;;;;;;; fim acender balas;;;;;;;;;;;;;;;;;

;;;;;; Apagar Balas;;;;;;;;;;;;;;;;;;;;;;;
apagar_bala:
PUSH R3
MOV R3,1
CALL desenha_bala
POP R3
RET
;;;;;; fim apagar balas;;;;;;;;;;;;;;;

;;;;;;; Moveimentar Balas - Disparos ;;;;;;;
; resume-se em desnhar as balas acender 
; e apagar e posições consecutivas cima-baixo

mover_bala_baixo:

PUSH R1
PUSH R4

call apagar_bala

MOV R4,balaL
MOVB R1,[R4]

ADD R1,1

MOVB [R4],R1

CALL acender_bala

POP R4
POP R1
RET

restaura_bala:
PUSH R1
PUSH R2
PUSH R3

MOV R3,bala_estado
MOV R1,1
MOVB [R3],R1
POP R3
POP R2
POP R1

RET

movimentar_a_bala_para_baixo:
PUSH R1
PUSH R2
PUSH R4
MOV R4,balaL
MOVB R1,[R4]
MOV R2,31
CMP R1,R2
JZ init_bala
ADD R1,1
MOVB [R4],R1
JMP d_fim

init_bala:
CALL restaura_bala
MOV R4,tanqueC
MOVB R2,[R4]

MOV R4,balaC
MOVB [R4],R2

MOV R2,0
MOV R4,balaL
MOVB [R4],R2
JMP d_fim

d_fim:
CALL acender_tanque1
CALL acender_tanque2
POP R4
POP R2
POP R1
RET

controle_para_bala:
PUSH R0
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5

MOV R2,bala_estado ;verifica o estado do process
MOVB R1,[R2]
CMP R1,1
JZ bala_proc1
CMP R1,2
JZ bala_proc2
CMP R1,3
JZ bala_proc2

bala_proc1:
CALL acender_bala
MOV R5,2
MOVB [R2],R5
JMP sair_bala_proc

bala_proc2:
CALL apagar_bala
CALL movimentar_a_bala_para_baixo
MOV R5,1
MOVB [R2],R5
JMP sair_bala_proc


sair_bala_proc:
POP R5
POP R4
POP R3
POP R2
POP R1
POP R0
RET


averiguar_bala_tanque:
PUSH R1
PUSH R2
PUSH R3
PUSH R4
PUSH R5

MOV R5,tanqueL
MOVB R1,[R5]

MOV R5,tanqueC
MOVB R2,[R5]

MOV R5,balaL
MOVB R3,[R5]

MOV R5,balaC
MOVB R4,[R5]

ADD R2,3
CMP R4,R2
JGT fim_colisao

SUB R2,6
CMP R4,R2
JLT fim_colisao

CMP R3,R1 
JZ colidiu_com_tanque ;salta para o estado de tratamento de colisão

jmp fim_colisao

colidiu_com_tanque:

CALL restaura_bala
CALL fim_jogo

fim_colisao:
POP R5
POP R4
POP R3
POP R2
POP R1
ret


fim_jogo:
push r0
push r1
push r2
DI
CALL apagar_tanque
CALL apagar_tanque1
CALL apagar_tanque2
CALL apagar_torpedo
CALL apagar_bala
call inicializa_objectos
call acender_mensagem_de_fim

game_over:

call pressionar_tecla
mov r0,stdin
mov r1,[r0]
mov r2,12
cmp r1,r2;quando nenhuma tecla é premida a variavel que armazenda a tecla primida contem o valor -1
jz reinicia_jogo
jmp game_over 

reinicia_jogo:
call apgar_mesagem_de_fim
call desenha_tudo

pop r2
pop r1
pop r0
ret

inicializa_objectos:
PUSH R1

PUSH R4

MOV R4,tanqueL
MOV R1,22
MOVB [R4],R1

MOV R4,tanqueC
MOV R1,11
MOVB [R4],R1

MOV R4,tanque_inimigo1L
MOV R1,3
MOVB [R4],R1

MOV R4,tanque_inimigo1C
MOV R1,3
MOVB [R4],R1

MOV R4,tanque_inimigo2L
MOV R1,4
MOVB [R4],R1

MOV R4,tanque_inimigo2C
MOV R1,22
MOVB [R4],R1

MOV R2,0
MOV R4,balaL
MOVB [R4],R2

POP R4
POP R1
ret

;rotina que activa os dysplay fazendo a contagem dos inimigos mortos

contador_inimigos_mortos:
push r0
push r1
push r2
push r3

mov r1,buffer_mortos ;faz a referência do endereço na qual é armazedo 
                     ; a quantidade de tanques acertado pelo torpedo
movb r2,[r1] ;faz atribução do valor contido nessa referência
mov r0,10       ;atribui o valor 10 ao r0 será usado para fazer a dezena
mov r1,r2       ;atribui o valor actual do dysplay em r1 de modo não perder-lo
mov r3,r2       ;atribui o valor actual do dysplay em r1 de modo não perder-lo
div r1,r0       ;divide de modo a obter o valor da dezena
mod r3,r0       ;divide de modo a obter o valor da unidade
mov r0,display_contador
shl r1,4
or r1,r3
movB [r0],r1

pop r3
pop r2
pop r1
pop r0
ret

averiguar_colisao_tanque2:
push r0
push r1
push r2
push r3
push r4
push r5

MOV R0,tanque_inimigo2L
MOV R1,tanque_inimigo2C

MOVB R2,[R0]
MOVB R3,[R1]

ADD R2,4

MOV R0,torpedoL
MOV R1,torpedoC

; colisão com tanque2
MOVB R4,[R0]
MOVB R5,[R1]
CMP R4,R2
JNZ fim_colisao_tanque2
CMP R5,R3
JLT fim_colisao_tanque2
CMP R5,R3
ADD R3,4
CMP R5,R3
JLE colidiu_com_tanque2
jmp fim_colisao_tanque2

colidiu_com_tanque2:
CALL apagar_tanque2
CALL apagar_torpedo
CALL reinicia_torpedo

CALL inicializa_tanqueinmigo2_posicao
CALL acender_tanque2
MOV R0,buffer_mortos
MOVB R1,[R0]
ADD R1,1
MOVB [R0],R1

fim_colisao_tanque2:
pop r5
pop r4
pop r3
pop r2
pop r2
pop r0
ret

averiguar_colisao_tanque1:
push r0
push r1
push r2
push r3
push r4
push r5

MOV R0,tanque_inimigo1L
MOV R1,tanque_inimigo1C

MOVB R2,[R0]
MOVB R3,[R1]

ADD R2,4

MOV R0,torpedoL
MOV R1,torpedoC

; colisão com tanque1
MOVB R4,[R0]
MOVB R5,[R1]
CMP R4,R2
JNZ fim_colisao_tanque1
CMP R5,R3
JLT fim_colisao_tanque1
CMP R5,R3
ADD R3,4
CMP R5,R3
JLE colidiu_com_tanque1
jmp fim_colisao_tanque1

colidiu_com_tanque1:
CALL apagar_tanque1
CALL apagar_torpedo
CALL reinicia_torpedo

CALL inicializa_tanqueinmigo1_posicao
CALL acender_tanque1
MOV R0,buffer_mortos
MOVB R1,[R0]
ADD R1,1
MOVB [R0],R1

fim_colisao_tanque1:
pop r5
pop r4
pop r3
pop r2
pop r2
pop r0
ret

averiguar_colisao_tanque2_e_tamqueJogador:
push r0
push r1
push r2
push r3
push r4
push r5

MOV R0,tanque_inimigo2L
MOV R1,tanque_inimigo2C

MOVB R2,[R0]
MOVB R3,[R1]

ADD R2,4

MOV R0,tanqueL
MOV R1,tanqueC

MOVB R4,[R0]
MOVB R5,[R1]
CMP R4,R2
JNZ fim_colisao_tanque2_jogador
CMP R5,R3
JLT fim_colisao_tanque2_jogador
CMP R5,R3
ADD R3,4
CMP R5,R3
JLE colidiu_com_tanque2_jogador
jmp fim_colisao_tanque2_jogador

colidiu_com_tanque2_jogador:
call fim_jogo

fim_colisao_tanque2_jogador:
pop r5
pop r4
pop r3
pop r2
pop r2
pop r0
ret

averiguar_colisao_tanque1_e_tamqueJogador:
push r0
push r1
push r2
push r3
push r4
push r5

MOV R0,tanque_inimigo1L
MOV R1,tanque_inimigo1C

MOVB R2,[R0]
MOVB R3,[R1]

ADD R2,4

MOV R0,tanqueL
MOV R1,tanqueC

MOVB R4,[R0]
MOVB R5,[R1]
CMP R4,R2
JNZ fim_colisao_tanque1_jogador
CMP R5,R3
JLT fim_colisao_tanque1_jogador
CMP R5,R3
ADD R3,4
CMP R5,R3
JLE colidiu_com_tanque1_jogador
jmp fim_colisao_tanque1_jogador

colidiu_com_tanque1_jogador:
call fim_jogo

fim_colisao_tanque1_jogador:
pop r5
pop r4
pop r3
pop r2
pop r2
pop r0
ret

escreva_mensagem_de_fim:
push r1
push r2
push r4

mov r1,8
mov r2,6
mov r4,7
call escreva_barra

braco_f1:           
                
                add r2,1
                call system_out
                add r2,1
                call system_out

                add r1,3
                call system_out
                sub r2,1
                call system_out           

i:      
                add r2,3
                mov r4,5
                call escreva_barra
                sub r1,2
                call system_out

                mov r4,7
                add r2,2
                call escreva_barra
                add r1,2
                add r2,1
                call system_out
                add r1,1
                call system_out

                sub r1,3
                add r2,1
                call escreva_barra

pop r4
pop r2
pop r1

ret


;------------------------------

escreva_barra:
push r1
push r2
push r4

call system_out

imprimindo:
                cmp r4,0
                jz fim_imprimir_barra
                call system_out
                add r1,1
                sub r4,1
                JMP imprimindo

fim_imprimir_barra: 


pop r4
pop r2
pop r1

ret

acender_mensagem_de_fim:
PUSH R3
MOV R3,0
CALL escreva_mensagem_de_fim

POP R3
RET

apgar_mesagem_de_fim:
PUSH R3
MOV R3,1
CALL escreva_mensagem_de_fim

POP R3
RET

;;;;;;;; fim disparar balas ;;;;;;;;;;;;;;;;

