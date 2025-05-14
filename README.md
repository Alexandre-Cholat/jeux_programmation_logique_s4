# Projet de Jeux de Programmation Logique en Prolog

Ce projet a été développé par Alexandre Cholat, Ramez Dahouathi et Julia Trimaille dans le cadre du cours de Prolog de l'UE Informatique de la Licence MIASHS, Université Grenoble Alpes
, enseigné par le professeur Benoit Lemaire.

## Règle du jeu
Ce jeu se joue à 2 joueurs. Le but est d'obtenir le score le plus élevé après plusieurs tours.
### VERSION 1. 
Chaque joueur choisit un nombre entre 1 et 5 et les 2 joueurs les
prononcent en même temps. Appelons A et B ces nombres. Si |A-B|=1 (donc si les deux
nombres sont consécutifs), le joueur qui a proposé le nombre le plus petit obtient la valeur
A+B et l'autre 0. Sinon, chaque joueur obtient la valeur de son nombre.
Par exemple, si le premier joueur dit 4 et le second dit 2, le premier gagne 4 points et le
second gagne 2 points. Au tour suivant, si le premier joueur dit 4 et le second dit 3, le
premier joueur a 0 points et le second joueur a 7 points. Les scores sont : 4 (joueur 1) vs 9
(joueur 2). Et on continue...
### VERSION 2. 
Mêmes règles que la version 1 excepté le fait que lorsqu'un joueur prononce
un nombre N qui est le même que le précédent, le score potentiel est multiplié par luimême. Par exemple, si le deux nombres sont 4 et 2, les joueurs gagnent 4 et 2. Au tour
suivant, si les deux nombres sont 4 et 1, le premier joueur gagne 4×4=16 et le second
joueur gagne 1. Aux tours suivants, le gain est de nouveau multiplié en cas de nouvelle
répétition ; donc si le joueur 1 dit de nouveau 4, il peut gagner 16×4=64 ! Sauf si
l'adversaire prononce 3, auquel cas ce dernier gagne la somme des deux, donc 3+64 = 67 !!!
La répétition d'un nombre permet de gagner beaucoup mais elle peut aussi faire perdre
beaucoup.

### Implémentation en Prolog
Chaque équipe doit créer un prédicat joue/3.

• Le premier argument est le nom de l'équipe.

• Le second argument est la liste des coups précédents, en commençant par le dernier.
Un coup est une paire de chiffres entre 1 et 5. Vos coups précédents sont toujours en
première position. Par exemple, si les 2 premiers coups ont été 1 pour vous et 4
pour l'adversaire, puis 3 pour vous et 2 pour l'adversaire, cette liste vaudra [[3,2],
[1,4]]. Ce n'est pas à vous de gérer cette liste, elle va vous être donnée.

• Le troisième argument est votre coup, un entier entre 1 et 5.

## Structure du Projet

Voici une liste des fichiers inclus dans ce projet :

- `'ctrl+alt+defeat'_tournois_prolog_CDT.pl` : Itération de la stratégie ctrl+alt+defeat ayant participé au tournoi du jeu.
- `final_ctrlAltDefeat.pl` : Itération de la stratégie ctrl+alt+defeat contenant les tactiques avantage2, randSpam, et catchSpam.
- `projet-s4-gestionDeJeux.pl` : Gestionnaire de jeux Version 1 qui permet à n'importe quelle deux stratégies de jouer, et calculer le score au long de la partie. Nous avons également inclus un argument pour définir le nombre de parties à jouer. Il est à noter que ce gestionnaire n’inverse pas les listes donc le deuxième joueur peut uniquement jouer des stratégies simplistes ou bien doit être spécialement conçu pour jouer deuxième.
- `projet-s4-prolog.pl` : Gestionnaire de jeux Version 2.
- `projetProlog2025.pl` : Gestionnaire de jeux et tournois Version 2 créé par Benoit Lemaire, ainsi qu'un répertoire détaille de stratégies variées.

## Installation

Pour exécuter ce projet, vous aurez besoin d'un interpréteur Prolog installé sur votre machine. Vous pouvez utiliser SWI-Prolog, qui est largement utilisé et disponible sur plusieurs plateformes.

1. Téléchargez et installez SWI-Prolog depuis [swi-prolog.org](https://www.swi-prolog.org/).
2. Clonez ce dépôt sur votre machine locale.
3. Ouvrez un terminal et naviguez jusqu'au répertoire du projet.
4. Lancez SWI-Prolog en tapant `swipl` dans le terminal.
5. Chargez le fichier Prolog que vous souhaitez exécuter en utilisant la commande `[nom_du_fichier].`.


## Licence

Ce projet est sous licence [MIT](https://opensource.org/licenses/MIT). Vous êtes libre de l'utiliser, de le modifier et de le distribuer conformément aux termes de cette licence.
