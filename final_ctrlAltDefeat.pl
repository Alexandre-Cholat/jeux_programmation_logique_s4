joue(ctrlAltDefeat, Historique, R):-
    c_listeCoupsPreced(Historique,L1),
    c_catchSpam(L1,SpamNb),
    write('SPAM '),
    R is SpamNb -1,
    R > 0.

joue(ctrlAltDefeat, Historique, R):-
    c_listeCoupsPreced(Historique,L1),
    c_catchSpam(L1,SpamNb),
    write('SPAM '),
    Opp is SpamNb -1,
    Opp < 1, R = 5.


joue(ctrlAltDefeat, Historique, R):-
    \+member(1,Historique),
    c_avantage2(Historique, R),
    write('ADVANTAGE 2 ').

joue(ctrlAltDefeat, Historique, R):-
    c_randSpam(Historique, R),
    write('DEFAULT ').


c_avantage2(L,R):- length(L,Length), Length < 15, random(N),(N<0.5,random_between(2,5,R);R=2).
c_avantage2(L,2):- length(L,Length), Length > 14, Length < 90.

c_randSpam([[]],X):-random_between(2,4,X).
c_randSpam([[A,_],[B,_],[C,_]|_], Rep):-
    C=:=A,
    A=:=B,
    repeat,
        random_between(2, 5, Rep),
        Rep =\= A,
    !.

c_randSpam([[X,_]|_],X].

c_catchSpam([A,B,C|L],A):- A =:= B, B =:= C.

c_listeCoupsPreced([], []).  %Cas de base: liste vide
c_listeCoupsPreced([[_, X]|Rest], [X|Xs]) :-
    c_listeCoupsPreced(Rest, Xs).

