%on commence par jouer la stratégie avantage2 qui pousse l'adversaire à
% dévoiler s'il joue des 1

joue(ctrlAltDefeat, Historique, C):-
    ctrlaltdefeat_listeCoupsPrecedAdv(Historique,L1),%stocke dans L1 la liste des coups précédents de l'adversaire uniquement
    ctrlaltdefeat_catchSpam2(L1,C), %si un nombre est répété 2 fois de suite dans la liste des coups de l'adversaire C,vaut ce nombre -1
    ctrlaltdefeat_CPT_Spam(L1,NBSpamAdv), %on stocke dans NBSpamAdv le nombre de spams de l'adversaire dans l'historique
    length(Historique,NBCoupsPrec),
    NBSpamAdv<5, NBCoupsPrec>20,%si ce nombre est inférieur à 5 sur les 20 premiers coups on passe à une stratégie plus offensive en commençant par voir si il a un seuil de détection de nos spams
    ctrlaltdefeat_listePourAnalyseSeuil(L),
    ctrlaltdefeat_listeSpamPourSeuil(L,C),
    ctrlaltdefeat_analyseSeuilPDC(Historique,C).



joue(ctrlAltDefeat, Historique, C):-
    ctrlaltdefeat_listeCoupsPrecedAdv(Historique,L1),
    %avantage2 : stratégie mise en place que si l'adversaire ne joue pas 1
    \+member(1,L1), %Si 1 n'a jamais été joué par l'adversaire jusqu'ici
    ctrlaltdefeat_avantage2(Historique, C). %on passe à la stratégie qui joue une majorité de 2
%------------------------------------------------------------------
ctrlaltdefeat_listePourAnalyseSeuil([5,4,4,3,3,3,2,2,2,2,3,3,4,4,2,2,2,2,2,1]). %Fait correspondant à la liste des coups à jouer pour détecter son seuil (des coups 20 à 40)
% ________________________________________________________________________


% Les 14 premiers coups, joue un nombre aléatoire entre 2 et 5 avec une
% chance sur 2, sinon joue 2. Ce prédicat incite l'adversaire à jouer 1
% sur les 15 premiers coups
ctrlaltdefeat_avantage2(L,C):- length(L,Length), Length < 15, random(N),(N<0.5,random_between(2,5,C);C=2).
%Les coups 15 à 90, joue uniquement 2
ctrlaltdefeat_avantage2(L,2):- length(L,Length), Length > 14, Length < 90.

%_______________________________________________

%parcourt la liste donnée comme un fait

ctrlaltdefeat_listeSpamPourSeuil([C|_], C).
ctrlaltdefeat_listeSpamPourSeuil([_|R], C) :-
    ctrlaltdefeat_listeSpamPourSeuil(R, C).


%Spam d'un nombre aléatoire entre 2 et 4, inclus
%Si historique vide on joue un random entre 2 et 4
ctrlaltdefeat_randSpam2_4([],X):-random_between(2,4,X).

%Si l'historique comporte un spam = série de longueur 3
ctrlaltdefeat_randSpam2_4([[A,_],[A,_],[A,_]|_], Rep):-
ctrlaltdefeat_randomDiffdeA(A,Rep). %On veut un random différent de A

% Après randSpam2_4 pendant les coups 14 à 30, on passe à l'analyse des
% seuils
ctrlaltdefeat_randSpam2_4(H, Coup):-
    length(H,NBCoups),
    NBCoups>=30,
    ctrlaltdefeat_analyseSeuilPDC(H,Coup).


%Premier cas : si le nombre généré est différent de A on le garde
ctrlaltdefeat_randomDiffdeA(A,Rand):-
    random_between(2,5,Rand),
    Rand=\=A.

%Deuxième cas : si c'est A, on en génère un autre
ctrlaltdefeat_randomDiffdeA(A,Rand):-
    random_between(2,5,Autre),
    Autre=:=A, %Si le nombre généré vaut A
    ctrlaltdefeat_randomDiffdeA(A,Rand). %Alors on génère un autre random entre 2 et 5

%catchSpam2 s'applique que sur un historique non vide
%Prédicat très défensif : à partir d'une répétition de deux, joue N-1
ctrlaltdefeat_catchSpam2([SpamNb,SpamNb|_],C):-%si un nb est spamé 2 fois de suite par l'adversaire on joue ce nombre -1
 C is SpamNb-1, C > 0. %sauf quand le nombre spamé est 1 car C vaudrait 0

%Cas qui empêche le 0, si nb spamé = 1 on joue 5
ctrlaltdefeat_catchSpam2([SpamNb,SpamNb|_],C):-
    Opp is SpamNb -1,
    Opp < 1, C = 5.

%------------------------------------------------------------------
%Accès aux listes individuelle des coups : adversaire ou nous
%__________________________________________________________________
ctrlaltdefeat_listeCoupsPrecedAdv([], []).  %Cas de base: historique vide = aucun coup

% On construit la liste résultat avec les coups de l'adversaire et on
% poursuit
ctrlaltdefeat_listeCoupsPrecedAdv([[_, X]|Rest], [X|Xs]) :-
    %renvoie la liste des coups de l'adversaire uniquement
    ctrlaltdefeat_listeCoupsPrecedAdv(Rest, Xs).


% Renvoie la liste de nos coups précédents à partir de
% l'historique
% cas de base : historique vide = aucun coup
ctrlaltdefeat_listeCoupsPrecedNous([],[]).
ctrlaltdefeat_listeCoupsPrecedNous([[N,_]|RHistorique],[N|ListeNous]):-
    %on construit avec nos coups et on rappelle sur le reste de l'historique
    ctrlaltdefeat_listeCoupsPrecedNous(RHistorique,ListeNous).


%------------------------------------------------------------------
% Partie dédiée à la détection de la façon dont sont contrés nos spams
% dans l'historique des coups précédents et renvoie le seuil (=nombre de
% répétitions à partir duquel l'adversaire contre notre spam en jouant
% N-1)
% existe_Spam : à appeler uniquement sur la liste de nos coups

%Trouver le seuil de détection de l'adversaire n'a de sens
%qu'au bout de plusieurs fois où il nous a contré
%il y a sinon une chance que ce soit au hasard
% on ajoute la stratégie du seuil qu'au bout d'un certain temps où les
% spams sont contrés de la même manière
%
% Si aucun spam dans l'historique, alors on retourne le nb de contres
% et la liste des seuils
% ATTENTION : ctrlaltdefeat_compteContres/4 à appeler avec 4 arguments :
% listeENC = []
% renvoie le nombre de contres et la liste des seuils

%____________________________________________
% CPT_SpamNous renvoie le nombre des spams joués par nous dans la liste
% de nos coups

%cas de base 0 : si la liste de coups est vide, il
% n'y a aucun spam
ctrlaltdefeat_CPT_Spam([],0).

% cas de base 1 : si la liste de coups contient un seul élément, on
% ne peut pas considérer de spam
ctrlaltdefeat_CPT_Spam([_],0).

% cas récursif dans le cas où un spam est détecté, on continue à compter
% avec le reste de la liste une fois que ce spam a été exclu
ctrlaltdefeat_CPT_Spam([A,A|ResteListe],CptSpam):-
    ctrlaltdefeat_passerSpam(A,ResteListe,ResteSuivant),
    ctrlaltdefeat_CPT_SpamNous(ResteSuivant,CptEnCours),
    CptSpam is CptEnCours +1.


%________________________________________________________________
% prédicat qui d'après une liste contenant des répétitions du même
% nombre renvoie cette liste sans la partie contenant le spam en cours
% (A)
%ctrlaltdefeat_passerSpam(A,L,ResteListe)

%cas de base : si liste vide, liste sans spam vide aussi
ctrlaltdefeat_passerSpam(_,[],[]).

ctrlaltdefeat_passerSpam(A,[A|R],ResteSansSpam):-
    %tant que la tête de la liste est A on continue l'exclut et on continue avec la suite
    ctrlaltdefeat_passerSpam(A,R,ResteSansSpam).

% si la tête de liste est différente de A (le spam en cours, la liste
% retour est la liste d'entrée
ctrlaltdefeat_passerSpam(A,[B|ResteSansSpam],[B|ResteSansSpam]):-
    B\=A.

%------------------------------------------------------------------
%Calcule la somme des éléments d'une liste
%utile pour calcul de la moyenne
%Cas de base : somme de liste vide = 0
ctrlaltdefeat_sommeListe([],0).
%Somme d'une liste = premier élément + somme du reste
ctrlaltdefeat_sommeListe([X|R],Res):-
    ctrlaltdefeat_sommeListe(R,SommeC),Res is X+SommeC.


%Cas de base : somme de liste vide = 0
ctrlaltdefeat_sommeListeCarre([],0).
%Somme des Xi au carré = premier élément au carré + somme du reste
ctrlaltdefeat_sommeListeCarre([X|R],Res):-
    ctrlaltdefeat_sommeListeCarre(R,SommeC),Res is X*X+SommeC.

% _________________________________________________________
%coupsPostSpam renvoie le spam et sa suite dans l'historique
%cas d'arrêt 1
ctrlaltdefeat_coupsPostSpam([[A,B],[A,R]],[[A,B],[A,R]]):-!.

%cas d'arrêt 2 1 seul coup : pas un spam
ctrlaltdefeat_coupsPostSpam([[]],[]):-!.

ctrlaltdefeat_coupsPostSpam([[A,_],[B,Y]|RHistoriqueInv],CoupsPostSpam):-
%si premier coup pas spam on l'ignore et on regarde la suite
A\=B,ctrlaltdefeat_coupsPostSpam([[B,Y]|RHistoriqueInv],CoupsPostSpam).

%Si la tête est un spam on la garde + la suite
ctrlaltdefeat_coupsPostSpam([[A,X],[A,Y]|CoupsPostSpam],[[A,X],[A,Y]|CoupsPostSpam]):-!.

% ________________________________________________________________________
%

% Cas principal : début d’un spam détecté (au moins deux fois le même coup à la suite)
ctrlaltdefeat_listeToSousListe([[A,B],[A,C]|R], [[A, AdvList] | R2]) :-
    ctrlaltdefeat_colspam(A, [[A,B],[A,C]|R], AdvList, RRest),!,
    ctrlaltdefeat_listeToSousListe(RRest, R2).

% Cas de base : fin de la liste ou pas de spam possible
ctrlaltdefeat_listeToSousListe([], []).
ctrlaltdefeat_listeToSousListe([_], []).

% Cas sans spam : passer à la suite
ctrlaltdefeat_listeToSousListe([[A,_],[B,Y]|R], R2) :-
    A \= B,!,
    ctrlaltdefeat_listeToSousListe([[B,Y]|R], R2).

% colspam % Extrait tous les coups de l’adversaire pendant que Nous
% on joue A
% Cas de base : liste vide
ctrlaltdefeat_colspam(_, [], [], []).

% Cas où le premier coup est A : on garde Adv, on continue à filtrer
ctrlaltdefeat_colspam(A, [[A,Adv]|R], [Adv|AdvR], RRest) :-
    ctrlaltdefeat_colspam(A, R, AdvR, RRest).

% Cas où le coup n'est pas A : on ne garde pas Adv, mais on garde le couple dans RRest
ctrlaltdefeat_colspam(A, [[B,Adv]|R], AdvR, [[B,Adv]|RRest]) :-
    A \= B,
    ctrlaltdefeat_colspam(A, R, AdvR, RRest).

% donneListeSeuil prend une liste de type
% [[[CoupSpaméNous,[ListeCoupsRéponse Adv]]|R] et renvoie la liste des
% seuils de contre-spam de l'adversaire :
% -1 si ne contre jamais
% 0 si contre dès le premier coup
% 2,3,4 etc signfie par ex : au bout de 2 coup l'adversaire a contré par
% N-1
%Cas de base : liste vide
ctrlaltdefeat_donneListeSeuil([], _, []).

% Si le spam est contré (on a trouvé A-1), on ajoute le seuil en cours
ctrlaltdefeat_donneListeSeuil([[A, [B|_]]|R2], Seuil, [Seuil|ListeSeuil]) :-
    B =:= A-1,
    !,
    ctrlaltdefeat_donneListeSeuil(R2, 0, ListeSeuil).

% Si l'adversaire n'a jamais contré le spam
ctrlaltdefeat_donneListeSeuil([[_, []]|R2], _, [-1|ListeSeuil]) :-
    !,
    ctrlaltdefeat_donneListeSeuil(R2, 0, ListeSeuil).

% Sinon, on continue à chercher (B \= A-1)
ctrlaltdefeat_donneListeSeuil([[A, [_|R1]]|R2], SeuilEnCours, ListeSeuil) :-
    S2 is SeuilEnCours + 1,
    ctrlaltdefeat_donneListeSeuil([[A, R1]|R2], S2, ListeSeuil).

% ________________________________________________________________________

ctrlaltdefeat_renvoieListeSeuil(HistoriqueInverse,ListeSeuil):-
% il est plus pratique de parcourir l'historique dans l'ordre
% chronologique donc on l'inverse,
    ctrlaltdefeat_coupsPostSpam(HistoriqueInverse,ListeCoupsPostSpam),
    ctrlaltdefeat_listeToSousListe(ListeCoupsPostSpam,ListeSousListe),
    ctrlaltdefeat_donneListeSeuil(ListeSousListe,0,ListeSeuil1),
    %on remet la liste dans l'ordre avant de la retourner
    reverse(ListeSeuil1,ListeSeuil).


% BoolAnalyseSeuil : vaut true si le nombre de nos spams dans
% l'historique est supérieur à 4, false sinon
% Il permet de lancer l'analyse du seuil de l'adversaire
%
ctrlaltdefeat_BoolAnalyseSeuil(Historique,true,HistoriqueInverse):-
    reverse(Historique,HistoriqueInverse),
    %De l'historique dans l'ordre chronologique on extrait la liste de nos coups
    ctrlaltdefeat_listeCoupsPrecedNous(HistoriqueInverse,ListeNosCoups),
    ctrlaltdefeat_CPT_SpamNous(ListeNosCoups,NbSpamsNous),
    NbSpamsNous>4,!.

% Si le nombre de spams de notre part est <= à 4, on ne commence pas
% encore l'analyse du seuil
ctrlaltdefeat_BoolAnalyseSeuil(_,false).

ctrlaltdefeat_analyseSeuilPDC(Historique,C):-
% Prise de décision passage de stratégie défaut à stratégie qui utilise
% séries de longueur n-1
% si BoolAnalyseSeuil est vrai (on a spamé plus de 4 fois)

ctrlaltdefeat_BoolAnalyseSeuil(Historique,true,HistoriqueInv),
    length(Historique,NBCOUPS),
    NBCOUPS>40,
ctrlaltdefeat_renvoieListeSeuil(HistoriqueInv,Liste_Seuils),
    %On récupère la liste des seuils et on en fait l'analyse statistique
 ctrlaltdefeat_lancerAnalyse(Liste_Seuils,C).

%Analyse statistique de la liste des seuils avec disjonctions de cas
%renvoie le coup à jouer et la stratégie à poursuivre

ctrlaltdefeat_lancerAnalyse(ListeSeuils,C):-
    %Si dans la liste, majorité de -1 : l'adversaire ne contre pas nos spams
    %si majorité de 0 : adversaire joue N-1 au premier coup : hasard
    %si majorité de 1 : l'adversaire a une stratégie très défensive, il joue N-1 dès le premier coup, il faut qu'on arrête de spamer !!
    %Nous avons calculé la moyenne mais mesure peu pertinente..
    %si le seuil semble constant et supérieur à 1, on fait des séries de ce nombre -1 puis on joue N-2
    length(ListeSeuils,NbSeuils),
    NbSeuils>0,%on évite la division par zéro si liste des seuils vide
    ctrlaltdefeat_sommeListe(ListeSeuils,Somme),
    Moyenne is Somme/NbSeuils,
   ctrlaltdefeat_sommeListeCarre(ListeSeuils,SommeCarre),
   Variance is (SommeCarre/NbSeuils)-Moyenne*Moyenne,
   ET is sqrt(Variance),
   BorneInf is Moyenne-3*ET,BorneSup is Moyenne+3*ET,%Bornes intervalle de confiance 68%
   Moyenne>=BorneInf,Moyenne=<BorneSup,
   Seuil is round(Moyenne),%On arrondie moyenne au + proche entier, correspondant au seuil de spams estimé de l'adversaire
   ctrlaltdefeat_SpamSeriesSeuil(Seuil,N),
   C is N.


ctrlaltdefeat_SpamSeriesSeuil(X,_) :- X<2,fail. %donc on passe à la stratégie par défaut

      ctrlaltdefeat_SpamSeriesSeuil(Seuil,C):-
    %Si seuil sup à 2 on joue des séries de longueur Seuil-1
    Seuil>=2,random_between(2,5,Random), %random entre 2 et 5 car la multiplication des 1 n'apporte rien
    Longueur_Serie is Seuil-1,%Longueur_Serie=Nb de coups où on spame le même nombre
    ctrlaltdefeat_cptCoups(Longueur_Serie,Random,C).

ctrlaltdefeat_cptCoups(Longueur,C,C):-
    %Tant que la longueur de la série est sup à 1 on continue à spamer le même coup
   Longueur>1.

% Quand on atteint Longueur = 1, c'est le moment de jouer N-2, sauf si
% N=2 sans quoi on jouerait 0

% Si le random spamé est 2 on empêche l'adversaire de nous contrer en
% jouant 1
ctrlaltdefeat_cptCoups(Longueur,2,1):-
    Longueur=<1,!.
% cas jamais atteint en pratique car random ne peut pas être 1 mais pour
% s'assurer que l'on ne joue pas zéro
ctrlaltdefeat_cptCoups(Longueur,1,1):-Longueur=<1.

ctrlaltdefeat_cptCoups(Longueur,Random,Coup):-
    Longueur=<1,
    Coup is Random-2,
    Coup>0.
