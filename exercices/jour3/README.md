# Jour 3 — Exercices guidés : YAML, Compose et CI

Exercices courts en complément des étapes 2 (Compose) et 3 (pipeline CI) du fil rouge.

| # | Exercice | Durée | Bloc | Fichiers fournis |
|---|---|---|---|---|
| 3.1 | [YAML à corriger](01-yaml-a-corriger.md) | 20 min | 3.5, 4.1 | [`yaml-a-corriger/ci-casse.yml`](yaml-a-corriger/ci-casse.yml), [`yaml-a-corriger/compose-casse.yaml`](yaml-a-corriger/compose-casse.yaml) |
| 3.2 | [Le `compose.yaml` de TaskFlow à compléter](02-compose-a-completer.md) | 20 min | 3.5, 3.6 | [`compose-a-trous.yaml`](compose-a-trous.yaml), [`.env.example`](.env.example) |
| 3.3 | [Lire un log d'échec CI](03-lire-log-ci.md) | 15 min | 4.2 | [`log-ci-1.txt`](log-ci-1.txt), [`log-ci-2.txt`](log-ci-2.txt), [`ci-extrait.yml`](ci-extrait.yml) |
| 3.4 | [Quel workflow se déclenche ?](04-quel-declencheur.md) | 10 min | 4.1, 4.3 | — |

**Corrigé :** [`solutions.md`](solutions.md) — à ouvrir après avoir essayé.

## Avant de commencer

- Les fichiers du dossier `yaml-a-corriger/` sont **volontairement invalides** : ne les copiez pas tels quels dans votre dépôt `taskflow`.
- Installez l'extension VS Code **YAML** (Red Hat) et **GitHub Actions** : elles soulignent la plupart des erreurs en direct.
