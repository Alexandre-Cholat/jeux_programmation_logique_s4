/*Joue toujours 4*/
joue(tjrs4,_,4).
joue(tjrs5,_,5).

/*comment determiner de quelle cote de la liste nous jouons?
joue(strat2,[[X,Y]|_],Rep):-*/


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
    write('Cas 1: Mise a jour du Score2 -> NouvScore: '), write(NouvScore), nl,
    jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, Score1, NouvScore, FinalScore1, FinalScore2).

jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1),
    joue(Equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    E1 + 1 =:= E2,
    NouvScore is E1 + E2 + Score1,
    write('Cas 2: Mise a jour du Score1 -> NouvScore: '), write(NouvScore), nl,
    jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, NouvScore, Score2, FinalScore1, FinalScore2).

jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1),
    joue(Equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    S1 is Score1 + E1,
    S2 is Score2 + E2,
    write('Cas 3: Mise a jour des scores -> S1: '), write(S1), write(', S2: '), write(S2), nl, jeuxV1(Equipe1, Equipe2, [[E1, E2]|L], NbDeParties, S1, S2, FinalScore1, FinalScore2).
