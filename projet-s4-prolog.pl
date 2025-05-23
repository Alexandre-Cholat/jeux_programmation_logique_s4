/* Version 2 */
joue(tjrs4,[],4).

joue(aleatwar,_,N):-random_between(1,5,N).

joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).

/* Main game handler*/
gestionDeJeuxV2(Equipe1, Equipe2, NbDeParties, FinalScore1, FinalScore2) :-
    jeuxV2(Equipe1, Equipe2, [], [], NbDeParties, 0, 0, FinalScore1, FinalScore2),!.

/* Cas de base*/
jeuxV2(_, _, History, _, NbDeParties, Score1, Score2, Score1, Score2) :-
    length(History, NbDeParties).

/*Case 1: E2 + 1 = E1 (cas consecutive pas de repetitions, E2 gange)*/
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E2 + 1 =:= E1,
    E1 =\= LastE1,
    E2 =\= LastE2,
    NouvScore2 is E1 + E2 + Score2,
    write('Consecutive case: E1='), write(E1), write(', E2='), write(E2),
    write(', Score2 becomes '), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, Score1, NouvScore2, FinalScore1, FinalScore2).

/* Case 2: E1 + 1 = E2 (cas consecutive pas de repetitions, E1 gagne) */
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E1 + 1 =:= E2,
    E1 =\= LastE1,
    E2 =\= LastE2,
    NouvScore1 is E1 + E2 + Score1,
    write('Consecutive case: E1='), write(E1), write(', E2='), write(E2),
    write(', Score1 becomes '), write(NouvScore1), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, Score2, FinalScore1, FinalScore2).

/*Case 1.2 : E2 + 1 = E1 (special consecutive case AND loser E1 repeats number)*/
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E1 =:= LastE1,
    E2 =\= LastE2,
    E2 + 1 =:= E1,
    NouvScore2 is E1*E1 + E2 + Score2,
    write('Consecutive case: E1='), write(E1), write(', E2='), write(E2),
    write(', Score2 becomes '), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, Score1, NouvScore2, FinalScore1, FinalScore2).

/* Case 2.2 : E1 + 1 = E2 (special consecutive case AND loser E2 repeats number)*/
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E2 =:= LastE2,
    E1 =\= LastE1,
    E1 + 1 =:= E2,
    NouvScore1 is E1 + E2*E2 + Score1,
    write('Consecutive case: E1='), write(E1), write(', E2='), write(E2),
    write(', Score1 becomes '), write(NouvScore1), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, Score2, FinalScore1, FinalScore2).


/* Case 3: Player 1 repeats their number (and no consecutive case) */
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E1 =:= LastE1,
    E2 =\= LastE2,

    abs(E1 - E2) =\= 1,
    NewPoints1 is E1 * E1,
    NewPoints2 is E2,
    NouvScore1 is Score1 + NewPoints1,
    NouvScore2 is Score2 + NewPoints2,
    write('Player 1 repeats: E1='), write(E1), write(' (x'), write(E1), write('), E2='), write(E2),
    write(', Scores become '), write(NouvScore1), write('-'), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, NouvScore2, FinalScore1, FinalScore2).

/* Case 4: Player 2 repeats their number (and no consecutive case) */
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E2 =:= LastE2,
    E1 =\= LastE1,
    abs(E1 - E2) =\= 1,
    NewPoints1 is E1,
    NewPoints2 is E2 * E2,
    NouvScore1 is Score1 + NewPoints1,
    NouvScore2 is Score2 + NewPoints2,
    write('Player 2 repeats: E1='), write(E1), write(', E2='), write(E2),
    write(' (x'), write(E2), write('), Scores become '), write(NouvScore1), write('-'), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, NouvScore2, FinalScore1, FinalScore2).

/* Case 5: Both players repeat their numbers (and no consecutive case) */
jeuxV2(Equipe1, Equipe2, History, [LastE1, LastE2], NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    E1 =:= LastE1,
    E2 =:= LastE2,
    abs(E1 - E2) =\= 1,
    NewPoints1 is E1 * E1,
    NewPoints2 is E2 * E2,
    NouvScore1 is Score1 + NewPoints1,
    NouvScore2 is Score2 + NewPoints2,
    write('Both players repeat: E1='), write(E1), write(' (x'), write(E1),
    write('), E2='), write(E2), write(' (x'), write(E2),
    write('), Scores become '), write(NouvScore1), write('-'), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, NouvScore2, FinalScore1, FinalScore2).

/* Case 6: Default case (no repeats, no consecutive) */
jeuxV2(Equipe1, Equipe2, History, _, NbDeParties, Score1, Score2, FinalScore1, FinalScore2):-
    joue(Equipe1, History, E1),
    joue(Equipe2, History, E2),
    abs(E1 - E2) =\= 1,
    NouvScore1 is Score1 + E1,
    NouvScore2 is Score2 + E2,
    write('Normal case: E1='), write(E1), write(', E2='), write(E2),
    write(', Scores become '), write(NouvScore1), write('-'), write(NouvScore2), nl,
    jeuxV2(Equipe1, Equipe2, [[E1, E2]|History], [E1, E2], NbDeParties, NouvScore1, NouvScore2, FinalScore1, FinalScore2).
