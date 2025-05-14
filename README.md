# Projet de Jeux de Programmation Logique en Prolog

Ce projet a été développé par Alexandre Cholat, Ramez Dahouathi et Julia Trimaille dans le cadre du cours de Prolog de l'UE Informatique de la Licence MIASHS, Université Grenoble Alpes
, enseigné par le professeur Benoit Lemaire.
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
