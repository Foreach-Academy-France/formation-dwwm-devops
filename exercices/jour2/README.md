# Jour 2 — Exercices guidés : rebase et Docker

Exercices courts en complément de la fin du TP 1 (rebase, tag) et de l'étape 1 du fil rouge (dockeriser TaskFlow).

| # | Exercice | Durée | Bloc | Fichiers fournis |
|---|---|---|---|---|
| 2.1 | [Nettoyer sa branche avec un rebase interactif](01-rebase-interactif.md) | 20 min | 2.5 | [`rebase-setup.sh`](rebase-setup.sh) |
| 2.2 | [Le Dockerfile à corriger](02-dockerfile-a-corriger.md) | 20 min | 3.3 | [`dockerfile-a-corriger/`](dockerfile-a-corriger/) (`Dockerfile` buggé + mini API Express) |
| 2.3 | [Quiz : images, conteneurs, couches](03-quiz-images-conteneurs.md) | 10 min | 3.1, 3.2, 3.4 | — |
| 2.4 | [Prouver que les données survivent : volume et réseau](04-volume-persistance.md) | 20 min | 3.4 | — |

**Corrigé :** [`solutions.md`](solutions.md) — à ouvrir après avoir essayé.

## Avant de commencer

- `rebase-setup.sh` crée un dépôt Git **jetable** dans `/tmp` et affiche la commande pour le supprimer.
- Les exercices Docker utilisent des noms d'images complets (`docker.io/library/...`) : ils fonctionnent aussi bien avec Docker qu'avec Podman.
- Pensez au nettoyage en fin d'exercice (`docker rm -f`, `docker rmi`, `docker volume rm`) : les images Node pèsent lourd.
