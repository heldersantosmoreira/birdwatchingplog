:-use_module(library(random)).
:-use_module(library(clpfd)).
:-use_module(library(lists)).

remove_at(X,[X|Xs],1,Xs).
remove_at(X,[Y|Xs],K,[Y|Ys]) :- K > 1, 
   K1 is K - 1, remove_at(X,Xs,K1,Ys).

insert_at(X,L,K,R) :- remove_at(X,R,K,L).

getPos(X,Y, Pos) :-
	Pos is Y*11+X.

tabuleiro(T) :-
	T = [0,0,0,0,0,0,0,0,0,0,0,
		 0,1,1,2,1,1,3,1,1,1,0,
		 0,1,0,1,0,1,0,1,0,1,1,
		 0,1,1,1,1,1,4,4,1,1,0,
		 0,0,1,0,1,0,2,0,1,0,0,
		 0,0,1,1,1,1,1,1,5,0,0,
		 0,0,1,0,1,0,6,0,1,0,0,
		 0,1,1,1,3,2,5,1,4,1,0,
		 1,1,0,1,0,1,0,3,0,1,0,
		 0,1,5,1,1,6,1,1,6,1,0,
		 0,0,0,0,0,0,0,0,0,0,0].
		 		 
		
/* 
   Verde = A
   Vermelho = B
   Azul = C
   Amarelo = D
   Roxo = E
*/
		
oneBird(PosicoesEscolhidas) :-
	tabuleiro(T),
	Caminho = [A,B,C,D,E],
	Posicoes = [P1,P2,P3,P4,P5],
	PosicoesEscolhidas = [X1,X2,X3,X4,X5],
	all_distinct(PosicoesEscolhidas),
	
	domain(Caminho,1,5),
	element(A,[15,51,83],P1),
	element(B,[18,96,82],P2),
	element(C,[40,41,86],P3),
	element(D,[64,84,102],P4),
	element(E,[73,105,108],P5),
	
	member(X1, Posicoes),
	labeling([],[X1]),
	existeCaminho(89, X1, T, T1),
	member(X2, Posicoes),
	labeling([],[X2]),
	existeCaminho(X1, X2, T1, T2),
	member(X3, Posicoes),
	labeling([],[X3]),
	existeCaminho(X2, X3, T2, T3),
	member(X4, Posicoes),
	labeling([],[X4]),
	existeCaminho(X3, X4, T3, T4),
	member(X5, Posicoes),
	labeling([],[X5]),
	existeCaminho(X4, X5, T4, T5),
	existeCaminho(X5,33,T5,_).
	
/*element(B,[18,96,82],P2),
element(C,[40,41,86],P3),
element(D,[64,84,102],P4),
element(E,[73,105,108],P5),
existeCaminho(89,P5,T, T1),
existeCaminho(P5, P1,T1, T2),
existeCaminho(P1, P2,T2, T3),
existeCaminho(P2, P4,T3, T4),
existeCaminho(P4, P3,T4, T5),
existeCaminho(P3, 33,T5, _),*/
		 
	
adjacente(Inicial,Final, Tabuleiro):- Inicial >= 0, Inicial < 121, Final is Inicial-1, nth1(Final, Tabuleiro,1).
adjacente(Inicial,Final, Tabuleiro):- Inicial >= 0, Inicial < 121, Final is Inicial+1, nth1(Final, Tabuleiro,1).
adjacente(Inicial,Final, Tabuleiro):- Inicial =< 110, Final is Inicial+11, nth1(Final, Tabuleiro,1) .
adjacente(Inicial,Final, Tabuleiro):- Inicial >= 11, Final is Inicial-11,  nth1(Final, Tabuleiro,1).

adjacente2(Inicial,Final, Tabuleiro):- Inicial >= 0, Inicial < 121, Final is Inicial-1, \+ nth1(Final, Tabuleiro,0).
adjacente2(Inicial,Final, Tabuleiro):- Inicial >= 0, Inicial < 121, Final is Inicial+1, \+ nth1(Final, Tabuleiro,0).
adjacente2(Inicial,Final, Tabuleiro):- Inicial =< 110, Final is Inicial+11, \+ nth1(Final, Tabuleiro,0) .
adjacente2(Inicial,Final, Tabuleiro):- Inicial >= 11, Final is Inicial-11,  \+ nth1(Final, Tabuleiro,0).

existeCaminho(_,Final,T, _) :-
	nth1(Final,T,0),!, fail.

existeCaminho(Inicial,Final, T, TNovo2) :-
	adjacente2(Inicial,Final,T),
	remove_at(_,T,Inicial,TNovo),
	insert_at(0,TNovo,Inicial, TNovo2).
	
existeCaminho(Inicial,Final,T, TRet) :-
	adjacente(Inicial,P,T),
	Pos is Inicial,
	remove_at(_,T,Pos,TNovo),
	insert_at(0,TNovo,Pos, TNovo2),
	existeCaminho(P,Final,TNovo2, TRet).
	
zeroBird(Caminho) :-
	tabuleiro(T),
	length(Caminho,17),
	domain(Caminho,1,6),
	cabecaCaminho(Caminho, T).
	
	
cabecaCaminho([H|_], Tabuleiro) :-
	write(H),
	getPos(1,8,A),
	write(H),
	element(A,Tabuleiro,H).

escolhePosicoes(Pecas,N,L,C):-
	generatePuzzle(T, L, C),
	length(Pecas,N),
	findall(X-Y,verificaPeca(T, X,Y, 1),Sols),
	escolhePosicoesAux(Pecas, Sols).
		
choose([], []).
choose(List, Elt) :-
	length(List, Length),
	random(0, Length, Index),
	nth0(Index, List, Elt).

escolhePosicoesAux([],_).
escolhePosicoesAux([H|T], PecasLivres):-
	choose(PecasLivres, X),
	member(X, [H]),
	delete(PecasLivres, X, PecasLivresNovo),
	escolhePosicoesAux(T, PecasLivresNovo).
	
verificaPeca(T,X,Y,Jogador) :- verificaPecaAux(T,X,Y,Jogador,1).
verificaPecaAux([T|_],X,Y,Jogador,Y) :-
	verificaPecaLinha(T,X,Jogador, 1).
verificaPecaAux([_|R],X,Y,Jogador,Linha) :-
	Linha2 is Linha+1,
	verificaPecaAux(R,X,Y,Jogador,Linha2).

verificaPecaLinha([Jogador|_], X, Jogador, X).
verificaPecaLinha([_|R], X, Jogador, Coluna) :-
	N1 is Coluna+1,
	verificaPecaLinha(R, X, Jogador, N1).
	
limite([], 0).
limite([0|T], M):-
	M > 0,
	M1 is M-1,
	limite(T, M1).

generatePuzzle([H|T], N, M):-
	limite(H, M),
	generatePuzzle2(T, N, M, N).

linhaBranca([0|T], M):-
	M1 is M-1,
	linhaBranca2(T, M1).

linhaBranca2([0], 1).
linhaBranca2([1|T], M):-
	M > 1,
	M1 is M-1,
	linhaBranca2(T, M1).
	
generateExit([1], 1).
generateExit([1|T], M):-
	M > 1,
	Div is M mod 2,
	Div = 0,
	M1 is M-1,
	generateExit(T, M1).
	
generateExit([0|T], M):-
	M > 1,
	Div is M mod 2,
	Div = 1,
	M1 is M-1,
	generateExit(T, M1).

generateEntrance([], 0).
generateEntrance([1|T], M):-
	M > 0,
	Div is M mod 2,
	Div = 0,
	M1 is M-1,
	generateEntrance(T, M1).
	
generateEntrance([0|T], M):-
	M > 0,
	Div is M mod 2,
	Div = 1,
	M1 is M-1,
generateEntrance(T, M1).	
	
generatePuzzle2([T], 1, M, _):-limite(T, M).
generatePuzzle2([[1,1|H]|T], N, M, Norig):-
	N =3,
	M2 is M-2,
	generateEntrance(H, M2),
	N1 is N-1,
	generatePuzzle2(T, N1, M, Norig).
	
generatePuzzle2([H|T], N, M, Norig):-
	N =:= Norig-1,
	generateExit(H, M),
	N1 is N-1,
	generatePuzzle2(T, N1, M, Norig).	
	
generatePuzzle2([H|T], N, M, Norig):-	
	N > 1, N \== 3,N =\= Norig-1,
	Div is N mod 2,
	Div = 0,
	linhaBranca(H, M),
	N1 is N-1,
	generatePuzzle2(T, N1, M, Norig).

generatePuzzle2([H|T], N, M, Norig):-	
	N > 1, N \== 3,N =\= Norig-1,
	Div is N mod 2,
	Div = 1,
	generateLine(H, M),
	N1 is N-1,
	generatePuzzle2(T, N1, M, Norig).	

generateLine([], 0).
generateLine([1|T], M):-
	M > 0,
	Div is M mod 2,
	Div = 0,
	M1 is M-1,
	generateLine(T, M1).
	
generateLine([0|T], M):-
	M > 0,
	Div is M mod 2,
	Div = 1,
	M1 is M-1,
	generateLine(T, M1).	

concatenate([], L, L).
concatenate([X|L1], L2, [X|L3]) :-
	concatenate(L1, L2, L3).	

tabToList(T,Lista):-
	tabToList2(T, Lista, _).
tabToList2([], F, [F|_]).
tabToList2([H|T], Lista, [H3|T3]):-
	concatenate(H3, H, H4),
	tabToList2(T, Lista, [H4|T3]).
	