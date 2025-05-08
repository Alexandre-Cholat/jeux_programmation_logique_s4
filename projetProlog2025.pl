% Licence MIASHS, Université Grenoble-Alpes, 2025.
% Ajouter les noms des joueurs dans la liste du prédicat inscrits/1.
% Ajouter le code de votre stratégie dans la section JOUEURS
% Lancer le tournoi avec la requête: go.
%
% Liste des joueurs inscrits au tournoi
inscrits([ avantage2, 'ctrl+alt+defeat' ]).

% Affichage ou non des détails de chaque partie (oui/non).
affichageDetails(oui).     % Indiquer oui pour voir les détails

%%%%%%%%%%%
% JOUEURS %
%%%%%%%%%%%

% Random
%%%%%%%%
% joue au hasard entre 1 et 5
joue(random,_,N):-random_between(1,5,N).

% Tit for tat
%%%%%%%%%%%%%
% joue au hasard la première fois puis le coup précédent de l adversaire
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).

% Gambler
%%%%%%%%%
% joue au hasard la première fois puis, soit son coup précédent avec une probabilité de 20% ou au hasard avec une probabilité de 80%
joue(gambler,[],N):-random_between(1,5,N).
joue(gambler,[[Prec,_]|_],C):-random(N),(N<0.2,C=Prec;random_between(1,5,C)).

joue(fivespammer,_,C):-random(N),(N<0.2,random_between(1,5,C);C=5).

joue(catch5spam,[[_,A],[_,B],[_,C],[_,D],[_,E],[_,F],[_,G],[_,H],[_,I],[_,J],[_,K]|_],4):-fivespam([A,B,C,D,E,F,G,H,I,J,K]).
joue(catch5spam,_,R):-joue(aleatwar234,_,R).

joue(catchSpam, L, R):-
    listeCoupsPreced(L,L1),
    catchSpam(L1,SpamNb),
    R is SpamNb -1.


% Strategy for team 'ctrl+alt+defeat'
% (Note: Because the team name contains symbols, it is enclosed in single quotes.)
joue('ctrl+alt+defeat', History, Move) :-
    % First, try the spam catcher from your provided code.
    (   joue(catchSpam, History, SpamMove)
    ->  Move = SpamMove
    ;   default_move(History, Move)
    ).

% Default move: before 30 rounds, pick randomly between 2 and 4.
% After 30 rounds, predict the opponent's range by gathering their unique moves,
% subtracting 1 from each (clamped to a minimum of 1), and then picking randomly from that set.
default_move(History, Move) :-
    length(History, L),
    ( L < 30 ->
         random_between(2,4, Move)
    ;   findall(Opp, (member([_,Opp], History), integer(Opp)), OppList),
         sort(OppList, UniqueOpp),
         adjust_range(UniqueOpp, AdjustedRange),
         random_member(Move, AdjustedRange)
    ).

% adjust_range/2: subtract 1 from each number in the list, but make sure the result is at least 1.
adjust_range([], []).
adjust_range([H|T], [Adj|R]) :-
    Temp is H - 1,
    ( Temp < 1 -> Adj = 1 ; Adj = Temp ),
    adjust_range(T,�R).









% Strategy for team 'ctrl+alt+defeatV2'
% (This is Version 2 incorporating periodic self-spamming and refined frequency analysis)
joue('ctrl+alt+defeatV2', History, Move) :-
    % First, check if catchSpam triggers (using your existing catchSpam code)
    (   joue(catchSpam, History, SpamMove)
    ->  Move = SpamMove
    ;   current_round(History, CR),
        ( CR < 30 ->
             random_between(2,4, Move)
        ;   ( is_spam_phase(CR) ->
                  % Self-spamming phase: spam move 5
                  Move = 5
             ;   % Otherwise, use frequency analysis to determine a counter move:
                  frequency_move(History, Move)
             )
        )
    ).

% Helper: current_round calculates the current round number based on History
current_round(History, CR) :-
    length(History, L),
    CR is L + 1.

% Helper: is_spam_phase(+CurrentRound)
% After round 30, every 15 rounds, the first 3 rounds are a spam phase.
is_spam_phase(CR) :-
    CR >= 30,
    Remainder is (CR - 30) mod 15,
    Remainder < 3.

% Frequency analysis move:
% Analyze the opponent's moves in the last 30 rounds, pick the top (up to three) most frequent moves,
% subtract 1 from each (but if X-1 is less than 3, use 3 as a safeguard) and choose one at random.
frequency_move(History, Move) :-
    last_n(History, 30, Last30),
    listeCoupsPreced(Last30, OppMoves),
    frequency_candidates(OppMoves, CandidateList),
    (   CandidateList = [] ->
            random_between(2,4, Move)
    ;   random_member(Move, CandidateList)
    ).

% last_n(+List, +N, -LastN)
% Returns the last N elements of List (or the entire list if there are fewer than N elements)
last_n(List, N, LastN) :-
    length(List, L),
    (   L =< N ->
            LastN = List
    ;   K is L - N,
        length(Prefix, K),
        append(Prefix, LastN, List)
    ).

% frequency_candidates(+Moves, -CandidateList)
% Computes frequency counts for Moves, selects up to the top 3,
% and maps each move X to a candidate counter: if X-1 is below 3 then candidate = 3, else X-1.
frequency_candidates(Moves, CandidateList) :-
    sort(Moves, Unique),
    findall((X, Count), (member(X, Unique), count_occurrences(Moves, X, Count)), Counts),
    sort(2, @>=, Counts, SortedCounts),
    top_n(3, SortedCounts, TopList),
    findall(Cand,
            ( member((X, _), TopList),
              Temp is X - 1,
              ( Temp < 3 -> Cand = 3 ; Cand = Temp )
            ),
            CandidateList).

% top_n(+N, +List, -Top)
% Takes the first N elements from List (if available); if List has fewer than N elements, Top is List.
top_n(N, List, Top) :-
    length(Top, N), !,
    append(Top, _, List).
top_n(_, List, List).

% count_occurrences(+List, +Element, -Count)
count_occurrences([], _, 0).
count_occurrences([X|T], X, Count) :-
    count_occurrences(T, X, CountT),
    Count is CountT + 1.
count_occurrences([Y|T], X, Count) :-
    X \= Y,
    count_occurrences(T, X, Count).

% listeCoupsPreced/2 is assumed to be defined elsewhere (it extracts the opponent moves)
% For example:
% listeCoupsPreced([], []).
% listeCoupsPreced([[_, X]|Rest], [X|Xs]) :-
%    listeCoupsPreced(Rest,�Xs).


% jouer 4, 5, 5, sans prendre en compte coups
% precedents de ladversaire
strat455([[4,_],[5,_]|L],5).
strat455([[5,_],[5,_]|L],4).
strat455([[5,_],[4,_]|L],5).








joue(avantage2,L,R):-length(L,Length), Length < 5, random(N),(N<0.5,random_between(2,5,R);R=2).
joue(avantage2,[[_,A],[_,B],[_,C],[_,D],[_,E],[_,F],[_,G],[_,H],[_,I],[_,J],[_,K]|_],R):-
    A=\=1,
    B=\=1,
    C=\=1,
    D=\=1,
    E=\=1,
    F=\=1,
    G=\=1,
    H=\=1,
    I=\=1,
    J=\=1,
    K=\=1,
    R = 2.
joue(avantage2,_,N):-random_between(2,4,N).

/*aleatoire entre 2 et 4, bat aleatwar35 ET titfortat*/
joue(aleatwar234,_,N):-random_between(2,4,N).

fivespam([5|[]]).
fivespam([X|L]):- X = 5, fivespam(L).

catchSpam([A,B,C|L],A):- A = B, B = C.





listeCoupsPreced([], []).  %Cas de base: liste vide
listeCoupsPreced([[_, X]|Rest], [X|Xs]) :-
    listeCoupsPreced(Rest, Xs).

%%%%%%%%%%%%%%%%%%%%%%
% GESTION DU TOURNOI %
%%%%%%%%%%%%%%%%%%%%%%

go :- inscrits(L),tournoi(L,R),predsort(comparePairs,R,RSorted),writef("Resultats : %t",[RSorted]).

% Prédicats qui gèrent le tournoi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tournoi([],[]).
tournoi([J|L],R):- inscrits(Ins),member(J,Ins),!,matchs(J,[J|L],R1),tournoi(L,R2),fusionne(R1,R2,R).
tournoi([J|_],_):-writef("Le joueur %t est inconnu.",[J]),fail.

fusionne([],L,L).
fusionne([[J,G]|L],L2,R) :- update(J,G,L2,R2),fusionne(L,R2,R).

matchs(_,[],[]).
matchs(J,[J1|L1],R):-run(J,J1,GainsJ,GainsJ1),matchs(J,L1,R1),update(J,GainsJ,R1,R2),update(J1,GainsJ1,R2,R).

update(J,Gain,[[J,OldTotal]|R],[[J,Total]|R]):-!,Total is OldTotal+Gain.
update(J,Gain,[P|L],[P|LUpdated]):-update(J,Gain,L,LUpdated).
update(J,Gain,[],[[J,Gain]]).

% Affichage des coups et des scores
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
affiche(Joueur1,Joueur2,C1,C2,Score1,Score2,Tscore1,Tscore2):-affichageDetails(oui),!,writef("%t joue %t, %t joue %t : [%t,%t]. Cumul: [%t,%t]\n",[Joueur1,C1,Joueur2,C2,Score1,Score2,Tscore1,Tscore2]).
affiche(_,_,_,_,_,_,_,_).

% Prédicat qui lance 100 parties entre J1 et J2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run(J1,J2,Points1,Points2):-run(100,J1,J2,[],0,0,Points1,Points2).

run(0,J1,J2,_,S1,S2,S1,S2):- !,writef("%t %t - %t %t.\n",[J1,S1,S2,J2]).
run(NbCoups,J1,J2,Prec,Score1,Score2,Points1,Points2):-joue(J1,Prec,C1),!,inversePaires(Prec,InvPrec),joue(J2,InvPrec,C2),score(C1,C2,Prec,NScore1,NScore2),Tscore1 is Score1+NScore1,Tscore2 is Score2+NScore2,affiche(J1,J2,C1,C2,NScore1,NScore2,Tscore1,Tscore2),NbCoups1 is NbCoups-1,run(NbCoups1,J1,J2,[[C1,C2]|Prec],Tscore1,Tscore2,Points1,Points2).

% Calcul des scores
%%%%%%%%%%%%%%%%%%%
score(C1,C2,Prec,Score1,Score2):-computeLongestPreviousSequence(C1,1,Prec,N1),ExpectedGain1 is C1**(N1+1),computeLongestPreviousSequence(C2,2,Prec,N2),ExpectedGain2 is C2**(N2+1),score(C1,C2,ExpectedGain1,ExpectedGain2,Score1,Score2).

computeLongestPreviousSequence(_,_,[],0).
computeLongestPreviousSequence(X,1,[[X,_]|L],R):-!,computeLongestPreviousSequence(X,1,L,N),R is N+1.
computeLongestPreviousSequence(X,2,[[_,X]|L],R):-!,computeLongestPreviousSequence(X,2,L,N),R is N+1.
computeLongestPreviousSequence(_,_,[_|_],0).

% Compute the score from the current move
score(C1,C2,EG1,EG2,Total,0):-C1=:=C2-1,!,Total is EG1+EG2.
score(C1,C2,EG1,EG2,0,Total):-C2=:=C1-1,!,Total is EG1+EG2.
score(_,_,EG1,EG2,EG1,EG2).

% UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inversePaires([],[]).
inversePaires([[X,Y]|R1],[[Y,X]|R2]):-inversePaires(R1,R2).

comparePairs(=,[_,X],[_,X]):-!.   % Predicat utilisé pour le classement
comparePairs(<,[_,X],[_,Y]):-X>Y,!.
comparePairs(>,_,_).
