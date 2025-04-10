% Licence MIASHS, Université Grenoble-Alpes, 2025.
% Ajouter les noms des joueurs dans la liste du prédicat inscrits/1.
% Ajouter le code de votre stratégie dans la section JOUEURS
% Lancer le tournoi avec la requête: go.
%
% Liste des joueurs inscrits au tournoi
inscrits([fivespammer, titfortat, avantage2, aleatwar234, catch5spam]).

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
