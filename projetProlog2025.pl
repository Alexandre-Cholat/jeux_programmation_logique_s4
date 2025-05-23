% Licence MIASHS, UniversitÃ© Grenoble-Alpes, 2025.
% Ajouter les noms des joueurs dans la liste du prÃ©dicat inscrits/1.
% Ajouter le code de votre stratÃ©gie dans la section JOUEURS
% Lancer le tournoi avec la requÃªte: go.
%
% Liste des joueurs inscrits au tournoi
inscrits([gambler,volPermanent,fave_adaptative,permaHarass,ctrlaltdefeat,ctrlAltDefeat, titfortat, favevolution, favexcellent, favoleur, favenom,adv2adaptive]).
run(ctrlAltDefeat, permaHarass, X, Y).

% Affichage ou non des dÃ©tails de chaque partie (oui/non).
affichageDetails(non).     % Indiquer oui pour voir les dÃ©tails

%%%%%%%%%%%
% JOUEURS %
%%%%%%%%%%%
%


joue(adv2adaptive, History, Move) :-
        adv2_target_length(History, Target),       % learned safe cap
        adv2_my_2_streak(History, Streak),         % current chain length
        ( Streak >= Target -> Move = 4             % break with 4
        ; Move = 2 ).                              % otherwise keep 2

% ==========================================================================
% 1.  Learn the next target length
%    – One less than the most recent punished streak, min
% ==========================================================================

adv2_target_length(History, Target) :-
        adv2_last_break_length(History, Len), !,
        Tmp is Len - 1,
        Target is max(2, Tmp).
adv2_target_length(_, 4).                          % no break seen yet

% Find the newest pair [2,1] (we 2, they 1) and count the 2-run ending there
adv2_last_break_length([[2,1]|Rest], Len) :-
        adv2_count_back_through_twos(Rest, 1, Len).
adv2_last_break_length([_|Rest], Len) :-
        adv2_last_break_length(Rest, Len).

adv2_count_back_through_twos([[2,_]|Rest], Acc, Len) :-
        Acc1 is Acc + 1,
        adv2_count_back_through_twos(Rest, Acc1, Len).
adv2_count_back_through_twos([[X,_]|_], Acc, Acc) :-
        X =\= 2.
adv2_count_back_through_twos([], Acc, Acc).

% ==========================================================================
% 2.  Current streak of consecutive 2’s
% ==========================================================================

adv2_my_2_streak([], 0).
adv2_my_2_streak([[2,_]|T], N) :-
        adv2_my_2_streak(T, M), N is M + 1, !.
adv2_my_2_streak([_|_], 0).


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
    c_listeCoupsPreced(Historique,L1),
   \+member(1,L1),
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


c_randSpam([[X,_]|_],X).

c_catchSpam([A,B,C|L],A):- A =:= B, B =:= C.

c_listeCoupsPreced([], []).  %Cas de base: liste vide
c_listeCoupsPreced([[_, X]|Rest], [X|Xs]) :-
    c_listeCoupsPreced(Rest, Xs).



joue(aleatwar25,_,N):-random_between(3,5,N).













% volPermanent - version Prolog
% 1er coup : aléatoire
% Puis, si l'adversaire répète 2 fois le même coup (OppLast=OppPrev) et OppLast>1, on joue OppLast-1
% Sinon, on joue 50% aléatoire / 50% imitation.

% 1) Coup initial
joue(volPermanent, [], Move) :-
    random_between(1, 5, Move).

% 2) Détection de la répétition adverse (dernier et avant-dernier)
joue(volPermanent, [[MyLast, OppLast],[, OppPrev] | _], Move) :-
    OppLast = OppPrev,
    OppLast > 1,
    !,
    Move is OppLast - 1.

% 3) Si pas de répétition adverse => moitié aléatoire, moitié imitation
joue(volPermanent, [[_MyLast, OppLast] | _], Move) :-
    random(N),
    (  N < 0.5
    -> random_between(1, 5, Move)
    ;  Move = OppLast
    ).

% permaHarass - version Prolog
% 1er coup : aléatoire
% Puis, dès que l'adversaire vient de répéter 2 fois le même coup X>1,
% on joue X-1. Sinon, on reste sur un jeu purement aléatoire.

% Coup initial
joue(permaHarass, [], Move) :-
    random_between(1, 5, Move).

% Si l'adversaire a répété le même nombre (OppLast=OppPrev) et OppLast>1
joue(permaHarass, [[MyLast, OppLast],[, OppPrev] | _], Move) :-
    OppLast = OppPrev,
    OppLast > 1,
    !,
    Move is OppLast - 1.

% Sinon, aléatoire
joue(permaHarass, _, Move) :-
    random_between(1, 5, Move).



% Coup initial : on n'a pas d'historique => coup aléatoire
joue(fave_adaptative, [], MyMove) :-
    random_between(1, 5, MyMove).

% Cas 1 : L'adversaire (Opp) vient de répéter son coup, OppLast=OppPrev, >1
joue(fave_adaptative, [[OppLast, MyLast],[OppPrev, MyPrev] | _], Move) :-
    OppLast = OppPrev,
    OppLast > 1,
    !,
    % Je joue OppLast - 1 pour le punir
    Move is OppLast - 1.

% Cas 2 : L'adversaire m'a volé au dernier tour => il a joué OppLast = MyLast - 1
joue(fave_adaptative, [[OppLast, MyLast] | _], Move) :-
    OppLast =:= MyLast - 1,
    !,
    % Dans ce cas, je change de coup
    pick_other_fave_adaptative(MyLast, Move).

% Cas 3 : pas de répétition adverse, pas de vol => je répète mon coup
joue(fave_adaptative, [[OppLast, MyLast] | _], MyLast).

% Auxiliaire : on choisit un autre nombre que X
pick_other_fave_adaptative(X, Y) :-
    random_between(1, 5, Tmp),
    ( Tmp = X -> pick_other_fave_adaptative(X,Y)
    ; Y = Tmp
    ).

% fave_mid


joue(favevolution, [[, OppLast],[, OppPrev] | _], Coup) :-
    OppLast = OppPrev,
    OppLast > 1,
    !,
    Coup is OppLast - 1.


joue(favevolution, [[MyLast, OppLast] | _], Coup) :-
    OppLast =:= MyLast - 1,
    !,
    pick_other_favevolution(MyLast, Coup).


joue(favevolution, [[MyLast, _] | _], MyLast).


autre_favevolution(X, Y) :-
    random_between(1, 5, Temp),
    ( Temp = X -> autre_favevolution(X, Y) ; Y = Temp ).


% fave_op


joue(favexcellent, [], N) :- random_between(1,5, N).




joue(favexcellent, [[MyLast, OppLast] | Rest], Coup) :-
    (
        Rest = [[MyPrev, _] | _], MyLast = MyPrev
    ->  autre_favexcellent(MyLast, Coup)
    ;
        OppLast =:= MyLast - 1
    ->  autre_favexcellent(MyLast, Coup)
    ;
        Coup = MyLast
    ).


autre_favexcellent(X, Y) :-
    random_between(1, 5, Temp),
    ( Temp = X -> autre_favexcellent(X, Y) ; Y = Temp ).


% fave_triche


joue(favenerve, [], 5).


joue(favenerve, [[MyLast, _] | _], MyLast).


% fave_voleur


joue(favoleur, [], Move) :-
	random_between(1, 5, Move).


joue(favoleur, [[MyLast, OppLast],[, OppPrev] | _], Move) :-
	OppLast = OppPrev,
	OppLast > 1,
	!,
	Move is OppLast - 1.


joue(favoleur, [[_, OppLast] | _], Move) :-
	random(N),
	(  N < 0.5
	-> random_between(1, 5, Move)
	;  Move = OppLast
	).


% fave_ok


joue(favenom, [], Move) :-
	random_between(1, 5, Move).


joue(favenom, [[, OppLast],[, OppPrev] | _], Move) :-
	OppLast = OppPrev,
	OppLast > 1,
	!,
	Move is OppLast - 1.


joue(favenom, _, Move) :-
	random_between(1, 5, Move).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KHAWA_KHAWA V4 - Version Avancée et Générale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic khawa_threshold_v4/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prédicat principal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v4, Historique, Coup) :-
    % Détermination d'un seuil aléatoire pour la phase d'apprentissage (25 à 30 tours)
    ( khawa_threshold_v4(Threshold) ->
          true
    ;   random_between(25,30,Threshold),
        assertz(khawa_threshold_v4(Threshold))
    ),
    length(Historique, NbTours),
    ( NbTours < Threshold ->
          % Phase d'apprentissage purement aléatoire
          random_between(1,5,Coup)
    ;
          % D'abord, si un pattern simple est détecté, on utilise les contre-stratégies
          ( adversaire_repetitif_v4(Historique) ->
                jouer_contre_repetitif(Historique, Coup)
          ; adversaire_titfortat_v4(Historique) ->
                jouer_contre_titfortat(Historique, Coup)
          ;
                % Sinon, on procède à une analyse avancée
                Lambda is 0.8,
                % Distribution globale pondérée sur l'historique
                weighted_distribution(Historique, Lambda, UncondDist),
                % Distribution conditionnelle basée sur la chaîne de Markov (ordre 1)
                markov_conditional_distribution(Historique, CondDist),
                % Fusion des deux distributions selon un coefficient de confiance
                blended_distribution(UncondDist, CondDist, BlendedDist),
                % Détection d'un changement de stratégie via comparaison de fenêtres récentes
                ( NbTours >= 10 ->
                      detecter_changement(Historique, Delta)
                ;     Delta = 0
                ),
                % Définition dynamique de la probabilité d'exploration
                ( Delta > 0.3 ->
                      ExplorationProb = 0.3
                ;     ExplorationProb = 0.1
                ),
                % Pour chaque coup possible, on calcule l'espérance de gain en se basant sur BlendedDist
                findall(EP-M, (between(1,5,M), expected_payoff(M, BlendedDist, EP)), ListEP),
                max_ep_move(ListEP, ChosenMove),
                random(R),
                ( R < ExplorationProb ->
                      % Coup aléatoire pour déstabiliser l'adversaire
                      random_between(1,5,Coup)
                ;
                      Coup = ChosenMove
                )
          )
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Distribution pondérée globale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weighted_distribution(+Historique, +Lambda, -Distribution)
% La distribution est une liste de paires Move-Prob pour les coups 1 à 5.
weighted_distribution(Historique, Lambda, Dist) :-
    init_counts(Counts0),
    weighted_counts(Historique, Lambda, 0, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]  % distribution uniforme par défaut
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

init_counts([1-0, 2-0, 3-0, 4-0, 5-0]).

weighted_counts([], _, _, Counts, Counts).
weighted_counts([[_, Opp]|Rest], Lambda, Index, CountsIn, CountsOut) :-
    Weight is Lambda ** Index,
    update_count(CountsIn, Opp, Weight, CountsUpdated),
    NextIndex is Index + 1,
    weighted_counts(Rest, Lambda, NextIndex, CountsUpdated, CountsOut).

update_count([], _, _, []).
update_count([Move-Val|Rest], Move, Weight, [Move-NewVal|Rest]) :-
    !,
    NewVal is Val + Weight.
update_count([Other-Val|Rest], Move, Weight, [Other-Val|RestUpdated]) :-
    update_count(Rest, Move, Weight, RestUpdated).

total_counts(Counts, Total) :-
    findall(Val, member(_-Val, Counts), Values),
    sum_list(Values, Total).

prob_of_count(Total, Move-Val, Move-Prob) :-
    Prob is Val / Total,
    Result is Prob,
    Move-Prob = Move-Result.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Distribution conditionnelle via chaîne de Markov (ordre 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% markov_conditional_distribution(+Historique, -CondDist)
% Estime P(Coup suivant | dernier coup adverse) en analysant les transitions dans l'historique.
markov_conditional_distribution(Historique, CondDist) :-
    % Récupère le dernier coup adverse (du tour le plus récent)
    ( Historique = [[, LastOpp]|] -> true ; LastOpp = none ),
    % Inverse l'historique pour obtenir l'ordre chronologique
    reverse(Historique, Chrono),
    findall(Prev-OppNext, (adjacent_opp(Chrono, Prev, OppNext)), Transitions),
    % Ne garder que les transitions dont le coup précédent correspond à LastOpp
    include(matches_last(LastOpp), Transitions, RelevantTransitions),
    count_transitions(RelevantTransitions, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         CondDist = []  % Aucune donnée conditionnelle
    ;
         maplist(prob_of_count(Total), Counts, CondDist)
    ).

% adjacent_opp(+Chrono, -Prev, -OppNext)
% Recherche des transitions consécutives dans Chrono (liste chronologique)
adjacent_opp([[_ , Opp1], [_ , Opp2] | _], Opp1, Opp2).
adjacent_opp([_ | Rest], Prev, OppNext) :-
    adjacent_opp(Rest, Prev, OppNext).

matches_last(Last, Prev-_) :-
    Prev = Last.

% count_transitions(+Transitions, -Counts)
% Compte la fréquence des coups adverses en seconde position dans les transitions.
count_transitions(Transitions, Counts) :-
    init_counts(Counts0),
    count_transitions_list(Transitions, Counts0, Counts).

count_transitions_list([], Counts, Counts).
count_transitions_list([_-Opp|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    count_transitions_list(Rest, CountsUpdated, CountsOut).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Fusion des distributions : blending
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blended_distribution(+UncondDist, +CondDist, -BlendedDist)
% Si la distribution conditionnelle est disponible et « prédictive », on lui donne plus de poids.
blended_distribution(UncondDist, [], UncondDist).  % Pas de donnée conditionnelle → on garde UncondDist
blended_distribution(UncondDist, CondDist, BlendedDist) :-
    % On récupère la probabilité maximale dans CondDist pour jauger la prédictivité
    max_probability(CondDist, _, MaxProbCond),
    % Définir α : si MaxProbCond est supérieur à 0.5, on y accorde un poids croissant
    ( MaxProbCond >= 0.5 -> Alpha is (MaxProbCond - 0.5) / 0.5 ; Alpha = 0 ),
    % Pour chaque coup (de 1 à 5), la probabilité finale est :
    % P_final = α * P_conditionnelle + (1-α) * P_global
    blend_lists(UncondDist, CondDist, Alpha, BlendedDist).

% blend_lists(+UncondDist, +CondDist, +Alpha, -BlendedDist)
blend_lists(UncondDist, CondDist, Alpha, BlendedDist) :-
    findall(Move-P,
            ( between(1,5,Move),
              member(Move-Pu, UncondDist),
              ( member(Move-Pc, CondDist) -> true ; Pc = 0 ),
              P is Alpha * Pc + (1 - Alpha) * Pu
            ),
            BlendedDist).

% max_probability(+Distribution, -Move, -MaxProb)
max_probability([Move-Prob], Move, Prob).
max_probability([Move1-P1, Move2-P2|Rest], Move, MaxProb) :-
    ( P1 >= P2 ->
         max_probability([Move1-P1|Rest], Move, MaxProb)
    ;  max_probability([Move2-P2|Rest], Move, MaxProb)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Calcul de l'espérance de gain et sélection du coup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expected_payoff(OurMove, Distribution, EP) :-
    expected_payoff_list(OurMove, Distribution, EP).

expected_payoff_list(_, [], 0).
expected_payoff_list(OurMove, [Opp-P|Rest], EP) :-
    payoff(OurMove, Opp, Pay),
    expected_payoff_list(OurMove, Rest, RestEP),
    EP is P * Pay + RestEP.

% Selon les règles du jeu :
% Si |OurMove - Opp| = 1 et OurMove < Opp, payoff = OurMove + Opp, sinon payoff = 0.
% Dans tous les autres cas, payoff = OurMove.
payoff(OurMove, Opp, Payoff) :-
    Diff is abs(OurMove - Opp),
    ( Diff =:= 1 ->
         ( OurMove < Opp -> Payoff is OurMove + Opp ; Payoff is 0 )
    ;   Payoff is OurMove
    ).

% max_ep_move(+ListEP, -BestMove)
max_ep_move(ListEP, BestMove) :-
    sort(1, @>=, ListEP, Sorted),
    Sorted = [EP-BestMove|].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) Détection de changement de stratégie (comparaison de fenêtres)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detecter_changement(Historique, Variation) :-
    length(Historique, L),
    ( L >= 10 ->
         prefix_length(Historique, Recent5, 5),
         remove_prefix(Historique, 5, Previous5),
         prefix_length(Previous5, Prev5, 5),
         simple_distribution(Recent5, Dist1),
         simple_distribution(Prev5, Dist2),
         variation_distance(Dist1, Dist2, Variation)
    ;   Variation = 0
    ).

prefix_length(List, Prefix, N) :-
    length(Prefix, N),
    append(Prefix, _, List).

remove_prefix(List, N, Rest) :-
    length(Prefix, N),
    append(Prefix, Rest, List).

simple_distribution(Historique, Dist) :-
    init_counts(Counts0),
    simple_counts(Historique, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

simple_counts([], Counts, Counts).
simple_counts([[_, Opp]|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    simple_counts(Rest, CountsUpdated, CountsOut).

variation_distance(Dist1, Dist2, Variation) :-
    findall(AbsDiff, ( member(M-P1, Dist1), member(M-P2, Dist2), Diff is abs(P1 - P2), AbsDiff = Diff ), Diffs),
    sum_list(Diffs, Sum),
    Variation is Sum / 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) Détection de patterns simples déjà existants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comportement répétitif : les 5 derniers coups adverses identiques
adversaire_repetitif_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    last_n_opponent_moves(Historique, 5, Moves),
    all_same(Moves).

last_n_opponent_moves(Historique, N, Moves) :-
    length(Prefix, N),
    append(Prefix, _, Historique),
    findall(Move, (member([_, Move], Prefix)), Moves).

all_same([]).
all_same([_]).
all_same([X, X|T]) :-
    all_same([X|T]).

% Comportement de type tit-for-tat : l'adversaire répète notre coup précédent sur une fenêtre donnée
adversaire_titfortat_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    prefix_length(Historique, Prefix, 5),
    check_titfortat(Prefix).

check_titfortat([_]).  % Un seul coup, rien à comparer.
check_titfortat([First, Second|Rest]) :-
    First = [MyCurrent, _],
    Second = [_, OppPrevious],
    OppPrevious =:= MyCurrent,
    check_titfortat([Second|Rest]).









%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMAKHAWA V5 (Stratégie méta-adaptative universelle)
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_meta_state/3.  % État: [Croyances, Patterns, Risque]
:- dynamic khawa_entropy/1.     % Mesure d'incertitude

joue(khawa_khawa_v5, Historique, Coup) :-
    % 1. Mise à jour de l'état méta
    (khawa_meta_state(Beliefs, Patterns, Risk)
        -> update_meta_state(Historique, Beliefs, Patterns, Risk, NewState)
        ;  initial_meta_state(NewState)),

    % 2. Calcul du coup optimal
    NewState = [NewBeliefs, NewPatterns, NewRisk],
    select_action(NewBeliefs, NewPatterns, NewRisk, Historique, Coup),

    % 3. Mise à jour dynamique
    retractall(khawa_meta_state(_, _, _)),
    assertz(khawa_meta_state(NewBeliefs, NewPatterns, NewRisk)).

% Initialisation de l'état méta
initial_meta_state([
    [random:0.25, titfortat:0.25, repetitive:0.25, unknown:0.25], % Croyances
    [ ],                                                            % Patterns
    0.5                                                            % Risque
]).

% Mise à jour bayésienne avec détection de stratégies inconnues
update_meta_state(Historique, OldBeliefs, OldPatterns, OldRisk, NewState) :-
    % a. Détection de nouveaux patterns
    scan_emerging_patterns(Historique, NewPatterns),

    % b. Mise à jour des croyances
    update_beliefs(Historique, OldBeliefs, NewBeliefs),

    % c. Calcul du risque dynamique
    calculate_risk(Historique, NewBeliefs, NewPatterns, NewRisk),

    NewState = [NewBeliefs, NewPatterns, NewRisk].

% Sélection d'action probabiliste multi-critères
select_action(Beliefs, Patterns, Risk, Historique, Coup) :-
    % 1. Génération de coups candidats
    findall(C, between(1, 5, C), Cand),

    % 2. Calcul des scores multi-objectifs
    maplist(score_action(Beliefs, Patterns, Risk, Historique), Cand, Scores),

    % 3. Sélection stochastique pondérée
    max_member(Score-Coup, Scores),
    (Risk > 0.7 -> random_member(Coup, Cand) ; true). % Exploration forcée

% Score d'une action (combine 4 critères)
score_action(Beliefs, Patterns, Risk, Hist, C, Score) :-
    exploit_score(Beliefs, C, S1),          % Exploitation des croyances
    explore_score(Hist, C, S2),             % Exploration des patterns
    risk_adjusted_score(Risk, C, S3),       % Ajustement au risque
    pattern_avoidance(Patterns, C, S4),     % Évitement des pièges

    Score is 0.4*S1 + 0.3*S2 + 0.2*S3 + 0.1*S4.

% Méthodes avancées -----------------------------------------------------------

% Détection de patterns émergents (algorithme Apriori adapté)
scan_emerging_patterns(Historique, Patterns) :-
    findall(Pat, (subsequence(Historique, Pat), length(Pat, L), L >= 3), AllPat),
    freq_patterns(AllPat, Freq),
    filter_significant(Freq, 0.2, Patterns).

% Mise à jour des croyances avec modèle de Dirichlet
update_beliefs(Hist, Old, New) :-
    length(Hist, N),
    alpha(0.5, Alpha), % Paramètre de régularisation
    maplist(update_strat_prob(Hist, Alpha, N), Old, Updated),
    normalize(Updated, New).

% Calcul du risque basé sur l'entropie de Shannon
calculate_risk(_, Beliefs, Patterns, Risk) :-
    entropy(Beliefs, E),
    patterns_risk(Patterns, PR),
    Risk is 0.7*E + 0.3*PR.

% Implémentations critiques ----------------------------------------------------
% (Ces prédicats nécessitent une implémentation détaillée selon la théorie des jeux)

% Fonctions utilitaires avancées
normalize(Probs, Normed) :- sumlist(Probs, Total), maplist(div(Total), Probs, Normed).
div(Total, X, Y) :- Y is X/Total.

entropy([], 0).
entropy([_:P|T], E) :- entropy(T, E1), (P > 0 -> E is E1 - P*log(P) ; E = E1).

% ... (autres implémentations nécessaires)

%%%%%%%%%%%%%%%%%%%%%%%%
% STRATÉGIE D'ÉQUILIBRE DYNAMIQUE
%%%%%%%%%%%%%%%%%%%%%%%%
% Permet de s'adapter même contre des clones de soi-même
anti_clone_policy(Historique, Coup) :-
    findall(C, (between(1,5,C), is_safe_against_clone(C, Historique)), Safe),
    random_member(Coup, Safe).

is_safe_against_clone(C, Hist) :-
    % Vérifie que le coup C ne crée pas de configuration exploitable
    not(dangerous_pattern(C, Hist)).

dangerous_pattern(C, Hist) :-
    length(Hist, L),
    L > 5,
    sublist([Prev1, Prev2, _], Hist),
    C =:= (Prev1 + Prev2) mod 5 + 1.

















%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICATS UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%
adversaire_repetitif(Historique) :-
    derniers_coups(Historique, 5, Derniers),
    compter_repetitions(Derniers, Reps),
    Reps >= 3.

adversaire_titfortat(Historique) :-
    length(Historique, L), L >= 2,
    derniers_coups(Historique, 2, [[M1, ], [, A2]]),
    A2 =:= M1.

jouer_contre_repetitif(Historique, Coup) :-
    dernier_adversaire(Historique, Dernier),
    Coup is max(1, Dernier - 1).

jouer_contre_titfortat(Historique, Coup) :-
    derniers_coups(Historique, 1, [[M, _]]),
    ( M =:= 3 ->
         Coup = 5
    ;
         Coup = 2
    ).

dernier_adversaire(Historique, D) :-
    Historique = [[_, D] | _].


derniers_coups(Historique, N, Derniers) :-
    reverse(Historique, R),
    firstN(R, N, Derniers).

firstN(L, N, R) :-
    length(R, N),
    append(R, _, L).

compter_repetitions(L, R) :-
    msort(L, S),
    count_reps(S, 1, R).

count_reps([_], C, C).
count_reps([H, H | T], Acc, R) :-
    Acc1 is Acc + 1,
    count_reps([H | T], Acc1, R).
count_reps([_ | T], Acc, R) :-
     count_reps(T, Acc, R).

computeLongestPreviousSequence(_, _, [], 0).
computeLongestPreviousSequence(X, P, [[X, _] | T], N) :-
    P =:= 1,
    computeLongestPreviousSequence(X, 1, T, M),
    N is M + 1.
computeLongestPreviousSequence(X, P, [[_, X] | T], N) :-
    P =:= 2,
    computeLongestPreviousSequence(X, 2, T, M),
    N is M + 1.
computeLongestPreviousSequence(_, _, _, 0).

inversePaires([], []).
inversePaires([[X, Y] | T], [[Y, X] | R]) :-
    inversePaires(T, R).

comparePairs(=, [, X], [, X]) :- !.
comparePairs(<, [, X], [, Y]) :-
    X > Y, !.
comparePairs(>, _, _).

affiche(_, _, _, _, _, _, _, _).


:- dynamic khawa_meta_state_v6/3.  % Stratégie détectée, Confiance, Compteur de stabilité

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prédicat principal - Version méta-adaptative universelle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v6, Historique, Coup) :-
    % Initialisation dynamique de l'état méta
    ( khawa_meta_state_v6(,,_) -> true ; assertz(khawa_meta_state_v6(unknown, 0.0, 0))),

    % Phase d'analyse méta en continu
    analyser_meta_strategie_khawa_khawa(Historique, Strat, NewConf, Stab),
    retractall(khawa_meta_state_v6(,,_)),
    assertz(khawa_meta_state_v6(Strat, NewConf, Stab)),

    % Détermination du coup avec système de priorité
    ( NewConf > 0.7 ->
        appliquer_strategie_ciblee_khawa_khawa(Strat, Historique, Coup)
    ; Stab > 15 ->
        declencher_surprise_khawa_khawa(Historique, Coup)
    ;
        generer_coup_optimal_khawa_khawa(Historique, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Méta-analyse stratégique (15 indicateurs combinés)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analyser_meta_strategie_khawa_khawa(Historique, Strat, Conf, Stab) :-
    % 1. Analyse de fréquence multi-niveaux
    calculer_distributions_khawa_khawa(Historique, [1,3,5], FreqDist),

    % 2. Détection de motifs complexes
    detecter_motifs_complexes_khawa_khawa(Historique, Motifs),

    % 3. Analyse de stabilité contextuelle
    calculer_entropie_khawa_khawa(Historique, Entropie),
    calculer_derive_strategique_khawa_khawa(Historique, Derive),

    % 4. Classification par réseau de décision
    ( Entropie < 1.2, Derive < 0.1 ->
        Strat = repetitive, Conf is 0.9 - (Entropie/2)
    ; Motifs = [anti_pattern|_] ->
        Strat = anti_strat, Conf is 0.8
    ; Entropie > 1.8 ->
        Strat = aleatoire, Conf is 0.95
    ;
        Strat = adaptive, Conf is max(0.6, 1 - (Entropie/3))
    ),

    % Calcul de la stabilité
    Stab is integer(20 * (1 - Derive)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Générateur de coup universel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generer_coup_optimal_khawa_khawa(Historique, Coup) :-
    % Triple couche prédictive
    markov_conditional_distribution_khawa_khawa(Historique, 3, MarkovDist),
    pattern_bayesien_khawa_khawa(Historique, BayesDist),
    historique_pondere_khawa_khawa(Historique, 0.9, HistDist),

    % Fusion neuronale
    blended_distribution_khawa_khawa([0.4,0.3,0.3], [MarkovDist,BayesDist,HistDist], FusionDist),

    % Calcul d'utilité avec gestion de risque
    findall(U-C, (between(1,5,C), utilite_attendue_khawa_khawa(C, FusionDist, U)), Utilities),
    keysort(Utilities, Sorted),
    reverse(Sorted, [MaxU-MaxC|_]),

    % Sélection avec exploration adaptative
    ( MaxU > 3.5 -> Coup = MaxC ; random_between(1,5,Coup)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contre-stratégies spécialisées
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
appliquer_strategie_ciblee_khawa_khawa(repetitive, Historique, Coup) :-
    derniers_coups_adversaire_khawa_khawa(Historique, 5, Derniers),
    mode_khawa_khawa(Derniers, Mode),
    ( Mode > 3 -> Coup is Mode - 1 ; Coup is Mode + 1).

appliquer_strategie_ciblee_khawa_khawa(anti_strat, Historique, Coup) :-
    random_select_khawa_khaway(Coup, [2,4], 0.7),  % Évite les extrêmes
    ( coup_valide_khawa_khaway(Historique, Coup) -> true ; Coup = 3).

appliquer_strategie_ciblee_khawa_khawa(aleatoire, _, Coup) :-
    distribution_anti_aleatoire_khawa_khaway(Coup).

appliquer_strategie_ciblee_khawa_khawa(adaptive, Historique, Coup) :-
    adversaire_imprevisible_khawa_khaway(Historique) ->
        random_between(1,5,Coup) ;
        generer_coup_optimal_khawa_khawa(Historique, Coup).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Système de surprise stratégique
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declencher_surprise_khawa_khawa(Historique, Coup) :-
    % Alternance entre pièges et fausses patterns
    random_select_khawa_khaway(Type, [sequence_trap,reverse_pattern,boost_multiplier], [0.4,0.3,0.3]),
    execute_surprise_khawa_khaway(Type, Historique, Coup).

execute_surprise_khawa_khaway(sequence_trap, Historique, Coup) :-
    derniers_coups_khawa_khaway(Historique, 3, MesDerniers),
    sum_list(MesDerniers, Sum),
    Coup is (Sum mod 5) + 1.

execute_surprise_khawa_khaway(reverse_pattern, Historique, Coup) :-
    reverse(Historique, [H|_]),
    H = [_,AdvCoup],
    Coup is 6 - AdvCoup.

execute_surprise_khawa_khaway(boost_multiplier, Historique, Coup) :-
    findall(C, member([C,_], Historique), MesCoups),
    mode_khawa_khaway(MesCoups, Mode),
    Coup = Mode.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonctions analytiques avancées
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calculer_distributions_khawa_khawa(_, [], []).
calculer_distributions_khawa_khawa(Historique, [N|Tailles], [Dist-N|Rests]) :-
    distribution_par_fenetre_khawa_khaway(Historique, N, Dist),
    calculer_distributions_khawa_khawa(Historique, Tailles, Rests).

distribution_par_fenetre_khawa_khaway(Historique, N, Dist) :-
    length(Historique, L),
    ( L > N ->
        length(Window, N),
        append(Window, _, Historique),
        compter_frequences_khawa_khaway(Window, Dist)
    ;
        compter_frequences_khawa_khaway(Historique, Dist)
    ).

detecter_motifs_complexes_khawa_khawa(Historique, Motifs) :-
    findall(Motif, (motif_complexe_khawa_khaway(Historique, Motif)), Motifs).

motif_complexe_khawa_khaway(Historique, anti_pattern) :-
    subsequence_khawa_khaway(Historique, [_,[A,B],[C,D]]),
    abs(A-B) =:= 1,
    abs(C-D) =:= 1,
    abs(A-C) =:= 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilitaires optimisés
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compter_frequences_khawa_khaway(Historique, Dist) :-(
    findall(C, member([_,C], Historique, Coups),
    init_counts_khawa_khaway(1-5, Counts),
    remplir_counts_khawa_khaway(Coups, Counts, FinalCounts),
    total_counts_khawa_khaway(FinalCounts, Total),
    maplist(prob_of_count_khawa_khaway(Total), FinalCounts, Dist))).

historique_pondere_khawa_khaway(Historique, Decay, Dist) :-
    reverse(Historique, Chrono),
    init_counts_khawa_khaway(1-5, Counts),
    apply_decay_recursive_khawa_khaway(Chrono, Decay, 1.0, Counts, FinalCounts),
    total_counts_khawa_khaway(FinalCounts, Total),
    maplist(prob_of_count_khawa_khaway(Total), FinalCounts, Dist).

apply_decay_recursive_khawa_khaway([], _, _, Counts, Counts).
apply_decay_recursive_khawa_khaway([[_,C]|R], D, W, CIn, COut) :-
    update_count_khawa_khaway(CIn, C, W, CTmp),
    WNew is W * D,
    apply_decay_recursive_khawa_khaway(R, D, WNew, CTmp, COut).



:- dynamic khawa_nash_state_v7/2.
:- dynamic khawa_game_version_v7/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intégration de l'équilibre de Nash - Version hybride V7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v7, Historique, Coup) :-
    % Détection dynamique de la version du jeu
    ( khawa_game_version_v7(V) -> true ; detecter_version_jeu_khawa_khawa(Historique, V)),

    % Calcul de la stratégie Nash en temps réel
    ( appliquer_nash_khawa_khawa(V, Historique, NashCoup) ->
        Coup = NashCoup,
        debug_nash_khawa_khawa(V)
    ;
        % Fallback sur la stratégie adaptative
        generer_coup_optimal_khawa_khawa(Historique, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Détection de la version du jeu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detecter_version_jeu_khawa_khawa(Historique, Version) :-
    findall(S, (member([A,B], Historique), score(A,B,_,S1,S2), S is S1+S2), Scores),
    ( member(S, Scores), S > 10 ->
        assertz(khawa_game_version_v7(v2)),
        Version = v2
    ;
        assertz(khawa_game_version_v7(v1)),
        Version = v1
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stratégies Nash pour les deux versions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
appliquer_nash_khawa_khawa(v1, Historique, Coup) :-
    % Équilibre mixte calculé : [1:10%, 2:30%, 3:20%, 4:25%, 5:15%]
    random_select_khawa_khaway(Coup, [1,2,2,2,3,3,4,4,4,5], _).

appliquer_nash_khawa_khawa(v2, Historique, Coup) :-
    % Stratégie Nash adaptative avec mémoire
    ( derniers_coups_khawa_khawa(Historique, 3, [X,X,X]) ->
        contre_multiplicateur_nash_khawa_khawa(X, Coup)
    ;
        nash_pondere_khawa_khawa(Historique, Coup)
    ).

contre_multiplicateur_nash_khawa_khawa(X, Coup) :-
    Y is (X mod 5) + 1,
    (Y =:= X+1 -> Coup = Y ; Coup = max(1, X-1)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul Nash pondéré version 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nash_pondere_khawa_khawa(Historique, Coup) :-
    matrice_gains_nash_khawa_khawa(Historique, Matrice),
    meilleure_reponse_nash_khawa_khawa(Matrice, Coup).

matrice_gains_nash_khawa_khawa(Historique, Matrice) :-
    findall(Col, (between(1,5,AdvCoup), Colonnes),
    maplist(calcul_utilite_nash_khawa_khawa(Historique), Colonnes, Matrice)).

calcul_utilite_nash_khawa_khawa(Historique, AdvCoup, Utilite) :-
    findall(U, (between(1,5,MyCoup), calcul_gain_nash_khawa_khawa(MyCoup, AdvCoup, U)), Utilite).

calcul_gain_nash_khawa_khawa(MyCoup, AdvCoup, Gain) :-
    ( abs(MyCoup - AdvCoup) =:= 1 ->
        ( MyCoup < AdvCoup -> Gain is MyCoup + AdvCoup ; Gain = 0 )
    ;   Gain = MyCoup
    ).

meilleure_reponse_nash_khawa_khawa(Matrice, Coup) :-
    transpose(Matrice, Transpose),
    findall(Max, (nth1(Idx, Transpose, Col), max_list(Col, Max)), Maxs),
    max_list(Maxs, MaxVal),
    findall(Idx, nth1(Idx, Transpose, Col), member(MaxVal, Col), Indices),
    random_member(Coup, Indices).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intégration avec système existant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generer_coup_optimal_khawa_khawa(Historique, Coup) :-
    % Fusion Nash + Adaptatif
    ( random(0.0,1.0,R), R < 0.3 ->
        appliquer_nash_khawa_khawa(v2, Historique, Coup)
    ;
        % Code original adaptatif
        markov_conditional_distribution_khawa_khawa(Historique, 3, MarkovDist),
        pattern_bayesien_khawa_khawa(Historique, BayesDist),
        blended_distribution_khawa_khawa([0.5,0.5], [MarkovDist,BayesDist], FusionDist),
        findall(U-C, (between(1,5,C), utilite_attendue_khawa_khawa(C, FusionDist, U)), Utilities),
        max_ep_move_khawa_khawa(Utilities, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilitaires supplémentaires
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
debug_nash_khawa_khawa(v1) :- write('Nash V1 activé').
debug_nash_khawa_khawa(v2) :- write('Nash V2 adaptatif').

derniers_coups_khawa_khawa(Historique, N, Coups) :-
    length(Prefix, N),
    append(Prefix, _, Historique),
    findall(C, member([C,_], Prefix), Coups).

% ... (Maintenir tous les prédicats auxiliaires existants)



 :- discontiguous joue/3.
:- dynamic param_khawa_khawa_prime/2.
:- dynamic drapeau_fausse_repet/1.
:- dynamic khawa_multiplier_state/2.

%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMÈTRES DYNAMIQUES
%%%%%%%%%%%%%%%%%%%%%%%%
param_khawa_khawa_prime(avance_sure, 25).
param_khawa_khawa_prime(retard_aggr, -20).
param_khawa_khawa_prime(repet_min, 1).
param_khawa_khawa_prime(taux_nash, 0.05).
param_khawa_khawa_prime(menace_max, 0.15).
param_khawa_khawa_prime(mult_max, 3).

maj_param_cle(Cle, Val) :-
    retractall(param_khawa_khawa_prime(Cle,_)),
    assertz(param_khawa_khawa_prime(Cle,Val)).

%%%%%%%%%%%%%%%%%%%%%%%%
%% STRATÈGE PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_prime, Historique, Coup) :-
    parametres(AvanceOk, RetardMax, SeuilRep, TauxNash, MenaceMax, MultMax),
    (detecter_version(Historique, v2) ->
        strategie_v2(Historique, Coup, AvanceOk, RetardMax, SeuilRep, TauxNash, MenaceMax, MultMax)
    ;
        strategie_v1(Historique, Coup, AvanceOk, RetardMax, SeuilRep, TauxNash)
    ).

strategie_v2(Hist, Coup, Av, Rg, Sr, Tn, Mm, Mx) :-
    (khawa_multiplier_state(Current, Count), Count > 0 ->
        (safe_multiplier(Current, Hist, Count, Mx)
            -> Coup = Current, NewCount is Count + 1,
               retractall(khawa_multiplier_state(,)),
               assertz(khawa_multiplier_state(Current, NewCount))
            ; abandon_multiplier(Hist, Coup, Mm)
        )
    ;
        etat_score(Hist, Delta),
        menace_basse(Hist, MenaceMax, CoupSafe),
        pret_decharger(Hist, CoupDecharge),
        choisir_coup_v2(Hist, Coup, Av, Rg, Sr, Tn, Delta, CoupSafe, CoupDecharge, Mx)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%
%% LOGIQUE VERSION 2
%%%%%%%%%%%%%%%%%%%%%%%%
choisir_coup_v2(Hist, Coup, Av, Rg, Sr, Tn, Dlt, CoupSafe, CoupDecharge, Mx) :-
    (Dlt >= Av, random(0.0, 1.0, R), R < 0.4 -> initier_multiplier(Hist, Coup, Mx)
    ; peut_decharger(Hist, CoupDecharge) -> Coup = CoupDecharge
    ; menace_basse(Hist, 0.2, CoupSafe) -> Coup = CoupSafe
    ; generer_coup_adaptatif(Hist, Coup, Tn)
    ).

safe_multiplier(Coup, Hist, Count, Max) :-
    dernier_coup_adv(Hist, DernierAdv),
    abs(DernierAdv - Coup) =\= 1,
    Count < Max,
    length_hist_streak(Hist, Coup, Len),
    Len >= 2.

initier_multiplier(Hist, Coup, Max) :-
    dernier_coup_moi(Hist, Last),
    between(2, 4, SafeCoup),
    Coup = SafeCoup,
    assertz(khawa_multiplier_state(Coup, 1)).

abandon_multiplier(Hist, Coup, Mm) :-
    retractall(khawa_multiplier_state(,)),
    (random(0.0, 1.0, R), R < Mm ->
        coup_agressif(Hist, Coup)
    ;
        generer_coup_adaptatif(Hist, Coup, 0.1)
    ).




% Random
%%%%%%%%
% joue au hasard entre 1 et 5
joue(random,_,N):-random_between(1,5,N).

% Tit for tat
%%%%%%%%%%%%%
% joue au hasard la premiÃ¨re fois puis le coup prÃ©cÃ©dent de l adversaire
joue(titfortat,[],N):-random_between(1,5,N).
joue(titfortat,[[_,C]|_],C).

% Gambler
%%%%%%%%%
% joue au hasard la premiÃ¨re fois puis, soit son coup prÃ©cÃ©dent avec une probabilitÃ© de 20% ou au hasard avec une probabilitÃ© de 80%
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
    adjust_range(T, R).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CtrlAltDefeat  – 2025 edition
%  ∘ Anti-spam (three identical opponent moves)
%  ∘ Adaptive Advantage-2  → learns risk length on the fly
%  ∘ Defensive default from Version 1
%  (all helpers prefixed cad_ to avoid name clashes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------------
% TOP-LEVEL DISPATCH
% --------------------------------------------------------------------------
joue(ctrlaltdefeat, History, Move) :-write('catchspam'),
        cad_catchSpam_detect(History, Move), !.      % 1) punish spammers
joue(ctrlaltdefeat, History, Move) :-write('advantage2'),
        cad_adaptive_advantage2(History, Move), !.   % 2) smart 2-mode
joue(ctrlaltdefeat, History, Move) :-write('default'),
        cad_default_move(History, Move).             % 3) fallback

% ==========================================================================
% 1.  SPAM-CATCHER  (three identical opponent moves in a row)
% ==========================================================================

cad_catchSpam_detect(History, Move) :-
        cad_listOppMoves(History, OppMoves),
        cad_catchSpam(OppMoves, SpamNb),
        Tmp is SpamNb - 1,
        ( Tmp < 1, Move = 1
        ; Tmp >= 1, Move = Tmp ).

cad_catchSpam([A,B,C|_], A) :-
        A =:= B, B =:= C.                     % three equal
cad_catchSpam([_|T], SpamNb) :-
        cad_catchSpam(T, SpamNb).

% ==========================================================================
% 2.  ADAPTIVE “ADVANTAGE-2”
% ==========================================================================

%  – Requires at least 15 history moves.
%  – Enters only if 1 is very rare in the last 20 opponent moves (≤ 2).
%  – Learns the length L of our last 2-streak that triggered a 1,
%    then uses (L − 1) as its new target.
%  – Once we reach the target, play a 4 to reset risk, then start again.

cad_adaptive_advantage2(History, Move) :-
        length(History, L), L >= 15,
        cad_opponent_window(20, History, Win),            % recent 20
        cad_count_occ(1, Win, C1), C1 =< 2,               % 1 is still rare
        Win = [LastOpp|_], LastOpp =\= 1,                 % last move not 1
        cad_target_length(History, Target),               % learned cap
        cad_my_2_streak(History, Streak),
        ( Streak >= Target, Move = 4                      % break
        ; Streak  < Target, Move = 2 ).                   % keep spamming

% --- learn last break length and derive next target -----------------------

cad_target_length(History, Target) :-
        cad_last_break_length(History, Len), !,
        Tmp is Len - 1,
        ( Tmp < 4, Target = 4 ; Target = Tmp ).
cad_target_length(_, 4).                                 % default start

% find most recent pair [2,1] then count the 2-streak ending there
cad_last_break_length([[2,1]|Rest], Len) :-
        cad_count_streak_here([[2,1]|Rest], 0, Len).
cad_last_break_length([_|Rest], Len) :-
        cad_last_break_length(Rest, Len).

cad_count_streak_here([[2,_]|Rest], A, Len) :-
        A1 is A + 1,
        cad_count_streak_here(Rest, A1, Len).
cad_count_streak_here([[X,]|], A, A) :-
        X =\= 2.
cad_count_streak_here([], A, A).

% consecutive 2’s we are currently on
cad_my_2_streak([], 0).
cad_my_2_streak([[2,_]|T], N) :-
        cad_my_2_streak(T, M), N is M + 1, !.
cad_my_2_streak([|], 0).

% ==========================================================================
% 3.  DEFAULT (Version 1)
% ==========================================================================

% < 30 rounds  → random 2 or 4
cad_default_move(History, Move) :-
        length(History, L), L < 30,
        random_between(2, 4, Move), !.

% prediction list available
/*cad_default_move(History, Move) :-
        findall(Opp, member([_,Opp], History), OppList),
        sort(OppList, UniqueOpp),
        cad_adjust_range(UniqueOpp, Adj),
        Adj \== [],
        random_member(Move, Adj), !.*/

% otherwise fallback random 2-4
cad_default_move(_, Move) :-
        random_between(2, 4, Move).

% shift each distinct opponent value down by 1 (min 1)
cad_adjust_range([], []).
cad_adjust_range([H|T], [Adj|R]) :-
        Tmp is H - 1,
        ( Tmp < 1, Adj = 1
        ; Tmp >= 1, Adj = Tmp ),
        cad_adjust_range(T, R).

% ==========================================================================
%  UTILITIES  (all prefixed cad_)
% ==========================================================================

% opponent’s move list (newest first in History)
cad_listOppMoves([], []).
cad_listOppMoves([[_,X]|Rest], [X|Xs]) :-
        cad_listOppMoves(Rest, Xs).

% take first N elements
cad_take_first_n(_, 0, []) :- !.
cad_take_first_n([], _, []) :- !.
cad_take_first_n([H|T], N, [H|R]) :-
        N1 is N - 1,
        cad_take_first_n(T, N1, R).

% last N opponent moves window
cad_opponent_window(N, Hist, Window) :-
        cad_listOppMoves(Hist, Ops),
        cad_take_first_n(Ops, N, Window).

% count occurrences of X
cad_count_occ(_, [], 0).
cad_count_occ(X, [X|T], N) :-
        cad_count_occ(X, T, M), N is M + 1, !.
cad_count_occ(X, [_|T], N) :-
        cad_count_occ(X, T, N).





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
                  Move = 3
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
%    listeCoupsPreced(Rest, Xs).


% jouer 4, 5, 5, sans prendre en compte coups
% precedents de ladversaire
strat455([[4,_],[5,_]|L],5).
strat455([[5,_],[5,_]|L],4).
strat455([[5,_],[4,_]|L],5).








joue(avantage2,L,R):-length(L,Length), Length < 10, random(N),(N<0.5,random_between(2,5,R);R=2).
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

% PrÃ©dicats qui gÃ¨rent le tournoi
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

% PrÃ©dicat qui lance 100 parties entre J1 et J2
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

comparePairs(=,[_,X],[_,X]):-!.   % Predicat utilisÃ© pour le classement
comparePairs(<,[_,X],[_,Y]):-X>Y,!.
comparePairs(>,_,_).
