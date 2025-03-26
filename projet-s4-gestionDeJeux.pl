/*Joue toujours 4*/
joue(tjrs4,[],4).

/*aleatoire*/
joue(aleatwar,_,N):-random_between(1,5,N).

/*coup précédent de l'adversaire
*/
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).


gestionDeJeux(equipe1, equipe2, nbDeParties, FinalScore1, FinalScore2) :-
    jeuxV1(equipe1, equipe2, [], nbDeParties, 0, 0, FinalScore1, FinalScore2).

jeuxV1(_, _, L, NbDeParties, Score1, Score2, Score1, Score2) :-
    length(L, Z),
    write('Checking base case: '), write(Z), write(' == '), write(NbDeParties), nl,
    Z == NbDeParties.

jeuxV1(equipe1, equipe2, L, nbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(equipe1, L, E1),
    joue(equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    E2 + 1 =:= E1,
    NouvScore is E1 + E2 + Score2,
    write('Case 1: Updating Score2 -> NouvScore: '), write(NouvScore), nl,
    jeuxV1(equipe1, equipe2, [[E1, E2]|L], nbDeParties, Score1, NouvScore, FinalScore1, FinalScore2), !.

jeuxV1(equipe1, equipe2, L, nbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(equipe1, L, E1),
    joue(equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    E1 + 1 =:= E2,
    NouvScore is E1 + E2 + Score1,
    write('Case 2: Updating Score1 -> NouvScore: '), write(NouvScore), nl,
    jeuxV1(equipe1, equipe2, [[E1, E2]|L], nbDeParties, NouvScore, Score2, FinalScore1, FinalScore2), !.

jeuxV1(equipe1, equipe2, L, nbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(equipe1, L, E1),
    joue(equipe2, L, E2),
    write('E1: '), write(E1), write(', E2: '), write(E2), nl,
    S1 is Score1 + E1,
    S2 is Score2 + E2,
    write('Case 3: Updating both scores -> S1: '), write(S1), write(', S2: '), write(S2), nl,
    jeuxV1(equipe1, equipe2, [[E1, E2]|L], nbDeParties, S1, S2, FinalScore1, FinalScore2).
