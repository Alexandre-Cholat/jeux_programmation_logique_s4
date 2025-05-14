/* Version 1 */

/*Joue toujours 4*/
joue(tjrs4,_,4).
joue(tjrs5,_,5).

/*comment determiner de quelle cote de la liste nous jouons?*/

joue(strat2,[[E1,E2]|_],Rep):-E1 + 1 =:= E2, Rep = 4.
joue(strat2,[[E1,E2]|_],Rep):-E1 > E2, Rep = 4.
joue(strat2,[[X,X]|_],4).
joue(strat2,_,N):-random_between(2,4,N).

/*Detection de l'adversaire qui joue toujours titfortat.*/
joue(antititfortat,[[E1,E2]|L], R):- titfortat(L, E2 ,3), write('titfortat detected'),E1>2, R = E1 -1.
joue(antititfortat,[[_,E2]|L], 5):- titfortat(L, E2 ,3), write('titfortat detected').
/*cas ou il ne joue pas titfortat*/
joue(antititfortat,L, R):-joue(aleatwar234,L,R).

/*aleatoire*/
joue(aleatwar,_,N):-random_between(1,5,N).

/*aleatoire entre 2 et 5, inferieure a aleatwar234 */
joue(aleatwar25,_,N):-random_between(2,5,N).

/*aleatoire entre 3 et 5, marche bien contre tit for tat*/
joue(aleatwar35,_,N):-random_between(3,5,N).

/*aleatoire entre 2 et 4, bat aleatwar35 ET titfortat*/
joue(aleatwar234,_,N):-random_between(2,4,N).

/*aleatoire entre 3 et 4, marche tres mal contre tit for tat*/
joue(aleatwar34,_,N):-random_between(3,4,N).

/*coup precedent de l'adversaire*/
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).

/*pour antititfortat*/
titfortat(_,_,0).
titfortat([[E1,E2]|L], Avant,Compte):-Avant =:= E2, C1 is Compte - 1, titfortat(L,E1,C1).

/*joue(metastrat): selection de strat. calcul de score chaque 10 parties [[C1,Adv1],[C2,Adv2],[C3,Adv3]|L]*/
joue(metastrat,[],R):-metastrat(L,0,R).
joue(metastrat,L,R):- Multiple is Length // 10, metastrat(L,Multiple,R).
/*pour quand Liste et une multiple de 10, nous voulons evaluer perf*/
joue(metastrat,L,R):-length(L,Length), 0 is Length mod 10, Multiple is Length // 10, metastratEval(L,Multiple,R).

metastrat(L,0,R):-ScorePosD10(L), joue(aleatwar234,_,N).
metastrat(L,0,R):-not(ScorePosD10(L)), metastrat(L,1,R).
metastrat(L,1,R):- joue(tjrs5,_,5).

ScorePosD10().

/*si adversaire ne joue jamais 1, exploitons et multiplions par 2. Sinon aleatoire entre 2, 3, et 4*/
joue(avantage2,[[_,A],[_,B],[_,C],[_,D],[_,E],[_,F],[_,G],[_,H],[_,I],[_,J],[_,K]|_],R):- A=\=1, B=\=1, C=\=1,D=\=1,E=\=1,F=\=1,G=\=1,H=\=1,I=\=1,K=\=1, R = 2.
joue(avantage2,_,N):-random_between(2,4,N).


joue(fivespammer,_,C):-random(N),(N<0.2,C=random_between(1,5,C);5).

joue(catch5spam,[[_,A],[_,B],[_,C],[_,D],[_,E],[_,F],[_,G],[_,H],[_,I],[_,J],[_,K]|_],4):-fivespam([A,B,C,D,E,F,G,H,I,J,K]).
fivespam([5|[]]).
fivespam([X|L]):- X = 5, fivespam(L).



/* ce programme de gestion de jeux est donc seulement pour Equipe 1*/
gestionDeJeux(Equipe1, Equipe2, NbDeParties, FinalScore1, FinalScore2) :-
    jeuxV1(Equipe1, Equipe2, [], NbDeParties, 0, 0, FinalScore1, FinalScore2),!.

jeuxV1(_, _, L, NbDeParties, Score1, Score2, Score1, Score2) :-
    length(L, Z),
    /*write('Verifions cas de base: '), write(Z), write(' == '), write(NbDeParties), nl,*/
    Z == NbDeParties.

jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1),
    joue(Equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    E2 + 1 =:= E1,
    NouvScore is E1 + E2 + Score2,
    write('Cas 1: Mise a jour du Score2 -> S1: '), write(Score1), write(', S2: '), write(NouvScore), nl,
    jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, Score1, NouvScore, FinalScore1, FinalScore2).

jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1),
    joue(Equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    E1 + 1 =:= E2,
    NouvScore is E1 + E2 + Score1,
    write('Cas 2: Mise a jour du Score1 -> S1: '), write(NouvScore), write(', S2: '), write(Score2), nl,
    jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, NouvScore, Score2, FinalScore1, FinalScore2).

jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1),
    joue(Equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    S1 is Score1 + E1,
    S2 is Score2 + E2,
    write('Cas 3: Mise a jour des scores -> S1: '), write(S1), write(', S2: '), write(S2), nl, jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, S1, S2, FinalScore1, FinalScore2).



