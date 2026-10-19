# Jour 4 — Exercices guidés : reverse proxy, incidents, mise en production

Exercices courts en complément des étapes 4 (déploiement de la « prod » locale `taskflow-prod`) et 5 (analyse d'incident) du fil rouge.

| # | Exercice | Durée | Bloc | Fichiers fournis |
|---|---|---|---|---|
| 4.1 | [La configuration Nginx du proxy à corriger](01-nginx-a-corriger.md) | 20 min | 5.2, 5.3 | [`taskflow-casse.conf`](taskflow-casse.conf), [`nginx-labo/`](nginx-labo/) (`compose.yaml`, `gen-cert.sh`) |
| 4.2 | [Lire des logs d'incident](02-logs-incident.md) | 20 min | 6.1 | [`logs/`](logs/) : `nginx-access.log`, `nginx-error.log`, `api.log`, `db.log`, `compose-ps.txt`, `df-h.txt` |
| 4.3 | [Appliquer une checklist de mise en production](03-checklist-mise-en-prod.md) | 20 min | 6.2 | [`mise-en-prod/`](mise-en-prod/) : `compose.prod.yaml`, `env-du-collegue.txt`, `deploy.sh` |

**Corrigé :** [`solutions.md`](solutions.md) — à ouvrir après avoir essayé.

## Avant de commencer

- Le labo de l'exercice 4.1 utilise les ports **8880** et **8443** : il peut tourner en même temps que votre stack `taskflow-prod` (80/443). Le certificat généré dans `nginx-labo/certs/` est ignoré par Git.
- Les fichiers des dossiers `logs/` et `mise-en-prod/` sont des **pièces à analyser** : ne les déployez pas. L'incident de l'exercice 4.2 est différent de celui de l'étape 5 du fil rouge.
