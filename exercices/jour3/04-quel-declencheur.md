# Exercice 3.4 — Quel workflow se déclenche ?

| | |
|---|---|
| **Durée** | 10 min |
| **Séquence** | S4 — Bloc 4.1 (déclencheurs `push`, `pull_request`, `workflow_dispatch`, `schedule`) et Bloc 4.3 (`release.yml`) |
| **Prérequis** | démo `demo-actions-hello` |
| **Fichiers fournis** | aucun (les deux workflows sont ci-dessous) |

## Objectif

Savoir prédire **quand** un workflow s'exécute en lisant sa section `on:`. C'est indispensable pour comprendre pourquoi un pipeline ne s'est « pas lancé », ou pourquoi il s'est lancé deux fois.

## Les workflows du dépôt `taskflow`

```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:
  push:
    branches: [main]
```

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]
    paths-ignore:
      - "docs/**"
      - "**.md"
  workflow_dispatch:
    inputs:
      tag:
        description: "Tag d'image à (re)déployer (ex. 3f2b9d1)"
        required: true
```

```yaml
# .github/workflows/backup-check.yml
name: Vérification hebdomadaire
on:
  schedule:
    - cron: "0 6 * * 1"
```

## Consignes

Pour chaque situation, indiquez **quel(s) workflow(s)** se déclenche(nt) : `CI`, `Release`, `Vérification hebdomadaire`, ou **aucun**. Justifiez en une ligne.

| # | Situation | Workflow(s) déclenché(s) | Justification |
|---|---|---|---|
| 1 | Vous poussez un commit sur votre branche `feature/filtre` (aucune PR ouverte). | | |
| 2 | Vous ouvrez une PR de `feature/filtre` vers `main`. | | |
| 3 | Vous poussez un nouveau commit sur `feature/filtre` alors que la PR est ouverte. | | |
| 4 | La PR (qui modifie `api/src/app.js`) est fusionnée dans `main`. | | |
| 5 | Une PR qui ne modifie que `docs/DEPLOIEMENT.md` est fusionnée dans `main`. | | |
| 6 | Vous cliquez sur **Run workflow** dans l'onglet Actions, workflow « Release », en saisissant le tag `3f2b9d1`. | | |
| 7 | Nous sommes lundi, 6 h 00 (UTC). | | |
| 8 | Vous poussez un tag `v1.2.0` (`git push origin v1.2.0`). | | |
| 9 | Un collègue pousse directement sur `main` alors que la branche est protégée (PR obligatoire). | | |

## Questions complémentaires

10. Dans quel cas le pipeline **CI** s'exécute-t-il deux fois pour le même code ? Est-ce grave ?
11. À quoi sert la situation 6 dans notre projet ?
12. Le cron `0 6 * * 1` est en UTC. À quelle heure s'exécute-t-il à Paris en hiver ? En été ?

## Résultat attendu

Le tableau rempli et justifié. Corrigé dans [`solutions.md`](solutions.md).

## Indices

<details>
<summary>Indice 1</summary>

`push` sans filtre `branches` réagit à **toutes** les branches ; avec `branches: [main]`, uniquement à `main`. `pull_request` sans filtre réagit à l'ouverture d'une PR **et** à chaque nouveau commit poussé sur une PR ouverte (`opened`, `synchronize`, `reopened`).
</details>

<details>
<summary>Indice 2</summary>

Fusionner une PR crée un **push sur `main`**. Un tag n'est pas une branche : un filtre `branches:` ne réagit pas aux tags (il faudrait `tags:`).
</details>
