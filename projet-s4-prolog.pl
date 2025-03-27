/*Joue toujours 4*/
joue(tjrs4,[],4).

/*aleatoire*/
joue(aleatwar,_,N):-random_between(1,5,N).

/*coup précédent de l'adversaire 
*/
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).


% Main predicate to start the game
gestionDeJeux(Equipe1, Equipe2, NbDeParties) :- 
    jeuxV1(Equipe1, Equipe2, [], NbDeParties, 0, 0, Score1, Score2), 
    format("Final Score: Joueur 1 - ~w, Joueur 2 - ~w~n", [Score1, Score2]).

% Base case: stop when the number of rounds is reached
jeuxV1(_, _, L, NbDeParties, Score1, Score2, Score1, Score2) :- 
    length(L, Z), Z == NbDeParties.

% Case when the numbers are consecutive
jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1), 
    joue(Equipe2, L, E2),
    abs(E1 - E2) =:= 1,
    (E1 < E2 -> NewScore1 is Score1 + E1 + E2, NewScore2 is Score2
    ; NewScore1 is Score1, NewScore2 is Score2 + E1 + E2),
    jeuxV1(Equipe1, Equipe2, [[E1, E2] | L], NbDeParties, NewScore1, NewScore2, FinalScore1, FinalScore2).

% Case when the numbers are not consecutive
jeuxV1(Equipe1, Equipe2, L, NbDeParties, Score1, Score2, FinalScore1, FinalScore2) :-
    joue(Equipe1, L, E1), 
    joue(Equipe2, L, E2),
    abs(E1 - E2) =\= 1,
    NewScore1 is Score1 + E1, 
    NewScore2 is Score2 + E2,
    jeuxV1(Equipe1, Equipe2, [[E1, E2] | L], NbDeParties, NewScore1, NewScore2, FinalScore1, FinalScore2).





















