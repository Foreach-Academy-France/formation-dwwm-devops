# Exercice 4.3 — Appliquer une checklist de mise en production

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S6 — Bloc 6.2 (bonnes pratiques, checklist de mise en prod) ; révision de S3 à S5 |
| **Prérequis** | étapes 2 à 4 du fil rouge (au moins lues) |
| **Fichiers fournis** | dossier [`mise-en-prod/`](mise-en-prod/) : `compose.prod.yaml`, `env-du-collegue.txt`, `deploy.sh` |

## Le scénario

Un collègue ouvre la PR #31 « prod : on y va ! » sur le dépôt `taskflow`. Elle ajoute un `compose.prod.yaml`, un `deploy.sh`… et un fichier `.env` (reproduit ici sous le nom `env-du-collegue.txt`, car un vrai `.env` ne doit jamais être versionné). Vous êtes chargé de la **revue de code**. Pour être objectif, vous appliquez la checklist d'équipe ci-dessous.

## La checklist de mise en production TaskFlow

| # | Domaine | Point à vérifier |
|---|---|---|
| C1 | Images | Les images applicatives sont **versionnées** par un tag précis (`${IMAGE_TAG}` = SHA court du commit), jamais `latest` en prod. |
| C2 | Images | Les images tierces (Postgres, Nginx) ont une version **fixée** (`postgres:16-alpine`, `nginx:1.27-alpine`). |
| C3 | Secrets | Aucun mot de passe ni jeton dans un fichier versionné : tout vient d'un `.env` **hors dépôt** (`~/taskflow-prod/.env`, `chmod 600`) ; seul `.env.example` (sans vraies valeurs) est versionné. |
| C4 | Secrets | Un secret qui a été poussé sur GitHub est considéré comme **compromis** : il est changé (rotation), pas seulement supprimé. |
| C5 | Réseau | **Seul** le conteneur `proxy` publie des ports (80 et 443). `db`, `api` et `front` ne sont joignables que par le réseau interne de la stack. |
| C6 | Données | La base a un **volume nommé** ; aucune commande de déploiement ne supprime les volumes. |
| C7 | Résilience | Chaque service a `restart: unless-stopped` et un **healthcheck** ; l'ordre de démarrage utilise `depends_on` + `condition: service_healthy`. |
| C8 | Configuration | `APP_ENV=production` ; les montages de configuration sont en lecture seule (`:ro`). |
| C9 | Déploiement | `deploy.sh` s'arrête à la première erreur (`set -euo pipefail`), utilise le bon fichier (`-f compose.prod.yaml`) et le tag demandé. |
| C10 | Déploiement | Une **sauvegarde** de la base est faite avant le déploiement, et un **smoke test** sur `/health` vérifie le résultat (échec = déploiement en échec). |
| C11 | Retour arrière | La procédure de **rollback** (redéployer le tag précédent) est documentée dans `docs/DEPLOIEMENT.md`. |

## Consignes

1. Lisez les trois fichiers du dossier `mise-en-prod/`.
2. Pour **chaque** point de la checklist, indiquez : ✅ conforme, ❌ non conforme, ou ➖ non vérifiable avec ces fichiers. Pour chaque ❌, citez la ligne fautive.

   | # | Statut | Ligne(s) en cause | Risque concret |
   |---|---|---|---|
   | C1 | | | |
   | … | | | |

3. Classez vos ❌ : lesquels sont **bloquants** (la PR ne doit pas être fusionnée) ? Lesquels sont des améliorations ?
4. Rédigez **le commentaire de revue** que vous laisseriez sur la PR : bienveillant, précis, avec une proposition de correction pour chaque point bloquant (5 à 10 lignes).
5. Le fichier `.env` a été commité avec un jeton GitHub et le mot de passe de la base. Listez, dans l'ordre, les actions à mener (C4).
6. Réécrivez `compose.prod.yaml` et `deploy.sh` pour qu'ils passent toute la checklist.
7. Si vous avez Docker : validez votre `compose.prod.yaml` sans rien lancer.
   ```bash
   mkdir -p ~/exo-checklist && cd ~/exo-checklist
   # copiez-y votre compose.prod.yaml corrigé, puis :
   printf 'POSTGRES_PASSWORD=test\nGHCR_OWNER=alice-dwwm\nIMAGE_TAG=4e7a1c2\n' > .env
   docker compose -f compose.prod.yaml config --quiet && echo "compose valide"
   ```

## Résultat attendu

Au moins **9 non-conformités** identifiées avec leur risque, un commentaire de revue constructif, et des fichiers corrigés dont le `compose.prod.yaml` passe `docker compose config`. Corrigé dans [`solutions.md`](solutions.md).

## Indices

<details>
<summary>Indice 1 — par où commencer</summary>

Cherchez dans `compose.prod.yaml` tous les `ports:` (combien de services en ont ?), tous les `image:` (lesquels n'ont pas de tag précis ?), et toute valeur qui ressemble à un mot de passe.
</details>

<details>
<summary>Indice 2 — <code>deploy.sh</code></summary>

Lisez-le ligne par ligne en vous demandant « que se passe-t-il si cette ligne échoue ? » et « que devient la base de données ? ». Regardez de près l'option `-v` de `docker compose down` et le nom du fichier compose utilisé par défaut.
</details>

<details>
<summary>Indice 3 — le secret commité</summary>

Supprimer le fichier dans un nouveau commit ne suffit pas : il reste dans l'**historique** Git, et le dépôt a peut-être déjà été cloné ou indexé. La première action est donc de rendre le secret **inutilisable**.
</details>
