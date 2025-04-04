/* Version 1 */

/*Joue toujours 4*/
joue(tjrs4,_,4).
joue(tjrs5,_,5).

/*comment determiner de quelle cote de la liste nous jouons?*/

joue(strat2,[[E1,E2]|_],Rep):-E1 + 1 =:= E2, Rep = 4.
joue(strat2,[[E1,E2]|_],Rep):-E1 > E2, Rep = 4.
joue(strat2,[[X,X]|_],4).
joue(strat2,_,N):-random_between(2,4,N).

/*D�tection de l'adversaire qui joue toujours titfortat.*/
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




/*coup prÃ©cÃ©dent de l'adversaire
*/
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).



/*pour antititfortat*/
titfortat(_,_,0).
titfortat([[E1,E2]|L], Avant,Compte):-Avant =:= E2, C1 is Compte - 1, titfortat(L,E1,C1).



/*Vos coups pr�c�dents sont toujours en premi�re position*/
/* ce programme de gestion de jeux est donc seulement pour Equipe 1*/

gestionDeJeux(Equipe1, Equipe2, NbDeParties, FinalScore1, FinalScore2) :-
    jeuxV1(Equipe1, Equipe2, [], NbDeParties, 0, 0, FinalScore1, FinalScore2),!.

jeuxV1(_, _, L, NbDeParties, Score1, Score2, Score1, Score2) :-
    length(L, Z),
    /*write('Checking base case: '), write(Z), write(' == '), write(NbDeParties), nl,*/
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
