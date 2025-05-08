joue('ctrl+alt+defeat', History, Move) :-
    (   joue(catchSpam, History, SpamMove)
    ->  Move = SpamMove
    ;   default_move(History, Move)
    ).

joue(catchSpam, L, R):-
    listeCoupsPreced(L,L1),
    catchSpam(L1,SpamNb),
    R is SpamNb -1.

default_move(History, Move) :-
    length(History, L),
    ( L < 30 ->
         random_between(2,4, Move)
    ;   findall(Opp, (member([_,Opp], History), integer(Opp)), OppList),
         sort(OppList, UniqueOpp),
         adjust_range(UniqueOpp, AdjustedRange),
         random_member(Move, AdjustedRange)
    ).
adjust_range([], []).
adjust_range([H|T], [Adj|R]) :-
    Temp is H - 1,
    ( Temp < 1 -> Adj = 1 ; Adj = Temp ),
    adjust_range(T, R).

catchSpam([A,B,C|L],A):- A = B, B = C.

listeCoupsPreced([], []).
listeCoupsPreced([[_, X]|Rest], [X|Xs]) :-
    listeCoupsPreced(Rest, Xs).

