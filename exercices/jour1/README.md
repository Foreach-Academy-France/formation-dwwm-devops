# Jour 1 — Exercices guidés : Git en solo et conflits

Exercices courts à faire seul, en complément du TP 1 (projet collaboratif). Ils reprennent les blocs 2.1 à 2.4 de la séquence S2.

| # | Exercice | Durée | Bloc | Fichiers fournis |
|---|---|---|---|---|
| 1.1 | [Les commandes Git en solo](01-commandes-git-solo.md) | 20 min | 2.1, 2.2 | — |
| 1.2 | [Kata : résoudre un conflit de fusion](02-kata-conflit.md) | 15 min | 2.4 | [`kata-conflit-setup.sh`](kata-conflit-setup.sh) |
| 1.3 | [Lire un historique `git log --graph`](03-lire-historique.md) | 15 min | 2.1, 2.2 | [`historique.txt`](historique.txt), [`creer-historique.sh`](creer-historique.sh) |
| 1.4 | [Réparer ses erreurs avec Git](04-reparer-ses-erreurs.md) | 15 min | 2.1 | — |

**Corrigé :** [`solutions.md`](solutions.md) — à ouvrir après avoir essayé.

## Avant de commencer

- Les scripts `.sh` créent des dépôts **jetables** dans le dossier temporaire du système (`/tmp`) : vous pouvez tout casser sans risque. Ils affichent le chemin créé et la commande pour le supprimer.
- Lancez-les avec `bash nom-du-script.sh` depuis ce dossier.
- Sous Windows, utilisez **Git Bash** ou WSL.
