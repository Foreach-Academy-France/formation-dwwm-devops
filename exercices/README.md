# Exercices guidés — DWWM DevOps

Exercices **courts (10 à 20 min), à faire seul**, qui complètent les démos du matin et les étapes du fil rouge TaskFlow. Ils servent d'évaluation **formative** : on s'entraîne, on se trompe, on recommence. Ils ne sont pas notés.

## Index

| Jour | # | Exercice | Durée | Séquence / bloc | Fichiers fournis |
|---|---|---|---|---|---|
| J1 | 1.1 | [Les commandes Git en solo](jour1/01-commandes-git-solo.md) | 20 min | S2 — 2.1, 2.2 | — |
| J1 | 1.2 | [Kata : résoudre un conflit de fusion](jour1/02-kata-conflit.md) | 15 min | S2 — 2.4 | `kata-conflit-setup.sh` |
| J1 | 1.3 | [Lire un historique `git log --graph`](jour1/03-lire-historique.md) | 15 min | S2 — 2.1, 2.2 | `historique.txt`, `creer-historique.sh` |
| J1 | 1.4 | [Réparer ses erreurs avec Git](jour1/04-reparer-ses-erreurs.md) | 15 min | S2 — 2.1 | — |
| J2 | 2.1 | [Nettoyer sa branche avec un rebase interactif](jour2/01-rebase-interactif.md) | 20 min | S2 — 2.5 | `rebase-setup.sh` |
| J2 | 2.2 | [Le Dockerfile à corriger](jour2/02-dockerfile-a-corriger.md) | 20 min | S3 — 3.3 | `dockerfile-a-corriger/` |
| J2 | 2.3 | [Quiz : images, conteneurs, couches](jour2/03-quiz-images-conteneurs.md) | 10 min | S3 — 3.1, 3.2, 3.4 | — |
| J2 | 2.4 | [Prouver que les données survivent : volume et réseau](jour2/04-volume-persistance.md) | 20 min | S3 — 3.4 | — |
| J3 | 3.1 | [YAML à corriger](jour3/01-yaml-a-corriger.md) | 20 min | S3 — 3.5 ; S4 — 4.1 | `yaml-a-corriger/` |
| J3 | 3.2 | [Le `compose.yaml` de TaskFlow à compléter](jour3/02-compose-a-completer.md) | 20 min | S3 — 3.5, 3.6 | `compose-a-trous.yaml`, `.env.example` |
| J3 | 3.3 | [Lire un log d'échec CI](jour3/03-lire-log-ci.md) | 15 min | S4 — 4.2 | `log-ci-1.txt`, `log-ci-2.txt`, `ci-extrait.yml` |
| J3 | 3.4 | [Quel workflow se déclenche ?](jour3/04-quel-declencheur.md) | 10 min | S4 — 4.1, 4.3 | — |
| J4 | 4.1 | [La configuration Nginx du proxy à corriger](jour4/01-nginx-a-corriger.md) | 20 min | S5 — 5.2, 5.3 | `taskflow-casse.conf`, `nginx-labo/` |
| J4 | 4.2 | [Lire des logs d'incident](jour4/02-logs-incident.md) | 20 min | S6 — 6.1 | `logs/` |
| J4 | 4.3 | [Appliquer une checklist de mise en production](jour4/03-checklist-mise-en-prod.md) | 20 min | S6 — 6.2 | `mise-en-prod/` |

Chaque jour a son propre index : [jour 1](jour1/README.md) · [jour 2](jour2/README.md) · [jour 3](jour3/README.md) · [jour 4](jour4/README.md).

## Comment travailler un exercice

1. **Lisez tout l'énoncé** avant de taper une commande : objectif, prérequis, résultat attendu.
2. **Suivez les consignes numérotées** dans l'ordre et comparez avec le « Résultat attendu ».
3. **Bloqué ?** Ouvrez l'**Indice 1** ; s'il ne suffit pas, l'**Indice 2**, puis le 3. Chaque indice en dit un peu plus que le précédent : n'ouvrez le suivant qu'après avoir réessayé.
4. **Ensuite seulement**, comparez avec le corrigé du jour (`jourN/solutions.md`). Lire la solution sans avoir cherché ne fait rien retenir.
5. Répondez aux questions de réflexion : ce sont elles qui reviennent dans le QCM et dans les questions du jury.

## Conventions

- Les scripts `.sh` créent leurs dépôts Git **jetables** dans le dossier temporaire du système (`/tmp`) et affichent la commande de nettoyage. Lancez-les avec `bash nom-du-script.sh`.
- Les fichiers « cassés », « à trous » et les logs sont **fournis** dans le dossier de chaque jour. Ne les copiez pas tels quels dans votre dépôt `taskflow`.
- Les commandes Docker utilisent des noms d'images complets (`docker.io/library/...`) : elles fonctionnent avec Docker comme avec Podman.
- Exemples cohérents avec TaskFlow : API Node 20 + Express (port 3000), PostgreSQL 16 (5432), front Vite servi par Nginx (8080 en dev), images `ghcr.io/<owner>/taskflow-api` et `taskflow-front`, « prod » locale = stack Compose `taskflow-prod` dans `~/taskflow-prod/`, domaine `taskflow.localhost`.

## Pour le formateur

- Les fichiers `solutions.md` sont des **corrigés** : à distribuer après l'exercice (ils sont exclus de la génération PDF des supports apprenants).
- `jour1/historique.txt` est la sortie réelle de `creer-historique.sh --print` (dates et auteurs fixés : mêmes identifiants de commit partout). Si une future version de Git change les identifiants, régénérez-le : `bash creer-historique.sh --print | sed -n '4,$p' > historique.txt`.
