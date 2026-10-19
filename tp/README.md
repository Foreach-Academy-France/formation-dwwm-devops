# Travaux pratiques : vue d'ensemble

Ce dossier contient les énoncés de tous les travaux pratiques (TP) de la formation DevOps DWWM (4 jours).
Chaque énoncé est **guidé pas à pas** : pour chaque étape, vous trouverez la commande à taper, le résultat attendu,
un encadré « Si ça ne marche pas » et un court « Pourquoi ? ». Les questions de réflexion arrivent **après** que tout fonctionne.

> **Règle d'or de la semaine** : on n'automatise que ce qu'on sait faire à la main. Vous ferez donc chaque geste
> manuellement une première fois, puis vous le confierez à une machine.

## Ordre et durée

| Quand | TP | Durée | Énoncé | Livrable |
|---|---|---|---|---|
| J1 matin | **TP 0** : cartographie d'un pipeline | 1h | [`tp0-cartographie-pipeline/`](tp0-cartographie-pipeline/README.md) | Liste des problèmes de « La Fromagerie » + schéma du pipeline cible de TaskFlow |
| J1 après-midi | **TP 1** : projet Git collaboratif (partie 1) | 1h | [`tp1-git-collaboratif/`](tp1-git-collaboratif/README.md) | Une PR revue et fusionnée par personne, un conflit résolu |
| J2 matin | **TP 1** (partie 2) : rebase, tag, release | 40 min | [`tp1-git-collaboratif/`](tp1-git-collaboratif/README.md#partie-2-jour-2-rebase-tag-et-release-40-min) | Tag `v1.0.0` et release GitHub |
| J2 matin | Mise en place du fil rouge : votre dépôt `taskflow` | 15 min | [`fil-rouge-taskflow/`](fil-rouge-taskflow/README.md) | Dépôt `taskflow` sur GitHub, `main` protégée |
| J2 après-midi | **Fil rouge, étape 1** : dockeriser TaskFlow | 2h | [`etape1-docker.md`](fil-rouge-taskflow/etape1-docker.md) | `api/Dockerfile`, `front/Dockerfile`, `front/nginx.conf`, `.dockerignore` |
| J3 matin | **Fil rouge, étape 2** : environnement complet avec Compose | 1h40 | [`etape2-compose.md`](fil-rouge-taskflow/etape2-compose.md) | `compose.yaml`, `.env.example`, README à jour, PR revue par le binôme |
| J3 après-midi | **Fil rouge, étape 3** : pipeline d'intégration continue | 1h30 | [`etape3-ci.md`](fil-rouge-taskflow/etape3-ci.md) | `ci.yml` (checks requis), `release.yml` (images sur ghcr.io), badge |
| J4 matin | **Fil rouge, étape 4, partie A** : déploiement manuel | 1h15 | [`etape4-deploiement.md`](fil-rouge-taskflow/etape4-deploiement.md#partie-a-déploiement-manuel-1h15) | Stack `taskflow-prod` en HTTPS, sauvegarde restaurée |
| J4 après-midi | **Fil rouge, étape 4, partie B** : déploiement automatique | 1h | [`etape4-deploiement.md`](fil-rouge-taskflow/etape4-deploiement.md#partie-b-déploiement-automatique-1h) | Job `deploy` + smoke test, rollback testé |
| J4 après-midi | **Fil rouge, étape 5** : analyse d'un incident | 25 min | [`etape5-incident.md`](fil-rouge-taskflow/etape5-incident.md) | Post-mortem dans `docs/INCIDENTS.md` |

Les exercices guidés plus courts (à faire seul, quand vous avez terminé ou pour vous entraîner) sont dans
[`../exercices/`](../exercices/README.md).

## Le fil rouge en une image

```
J2  Dockerfile api + front      ─┐
J3  compose.yaml (db+api+front)  ├─▶ dépôt GitHub « taskflow » (main protégée, PR revues)
J3  ci.yml + release.yml        ─┘          │
                                            ▼  merge sur main
                              GitHub Actions : lint, tests, build ─▶ images sur ghcr.io
                                            │
                                            ▼  job deploy (runner sur votre poste)
J4                       ~/taskflow-prod : stack « taskflow-prod » derrière Nginx en HTTPS
```

## Livrables de fin de formation (par apprenant)

Ce sont aussi les éléments évalués lors de la mise en situation (voir [`../evaluation/`](../evaluation/README.md)) :

- [ ] un dépôt GitHub `taskflow` structuré : `main` protégée, PR relues, commits lisibles, au moins un tag ;
- [ ] deux `Dockerfile` (API et front) et un `compose.yaml` opérationnels ;
- [ ] un pipeline GitHub Actions : `ci.yml` (lint, tests, build) et `release.yml` (publication des images, déploiement, smoke test) ;
- [ ] l'application déployée dans la stack `taskflow-prod` derrière Nginx en HTTPS ;
- [ ] `docs/ARCHITECTURE.md`, `docs/DEPLOIEMENT.md` et `docs/INCIDENTS.md`.

> **Pour votre dossier professionnel DWWM** : ce pipeline illustre la compétence « Préparer et exécuter le déploiement
> d'une application web ». Gardez des captures d'écran (PR revue, run vert dans l'onglet Actions, page en HTTPS).

## Vous êtes en retard ?

C'est normal, et c'est prévu :

1. Chaque étape du fil rouge se termine par une **checklist « Je valide avec le formateur »** : faites valider
   avant de passer à la suite, même si tout n'est pas parfait.
2. Le dossier [`fil-rouge-taskflow/solution/`](fil-rouge-taskflow/solution/) contient la version finale de chaque fichier.
   Si vous êtes bloqué plus de 15 minutes sur un fichier, copiez celui de la solution, **lisez-le ligne par ligne**,
   puis continuez. La marche à suivre est détaillée dans [`fil-rouge-taskflow/README.md`](fil-rouge-taskflow/README.md#vous-êtes-en-retard--récupérer-un-fichier-de-la-solution).
3. Les antisèches sont dans [`../ressources/`](../ressources/) : `cheatsheet-git.md`, `cheatsheet-docker.md`,
   `cheatsheet-github-actions.md`, `cheatsheet-linux-ssh-nginx.md` et le `glossaire.md`.
