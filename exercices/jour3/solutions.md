# Jour 3 — Solutions des exercices guidés

> À ouvrir **après** avoir cherché (et utilisé les indices).

---

## Exercice 3.1 — YAML à corriger

### Partie A — `compose-casse.yaml`

| Ligne (fichier fourni) | Problème | Correction |
|---|---|---|
| `POSTGRES_DB taskflow` | `:` manquant : YAML ne voit pas une clé | `POSTGRES_DB: taskflow` |
| `environment:` de `api` | liste (`- DATABASE_URL=…`) **mélangée** avec un dictionnaire (`APP_ENV: local`) | tout en dictionnaire (ou tout en liste) |
| `   front:` | indenté de **3** espaces au lieu de 2 : YAML ne sait pas à quel niveau le rattacher | `  front:` |
| `depends_on: api` | Compose attend une liste ou un dictionnaire, pas un texte | `depends_on: [api]` ou en liste `- api` |
| `volume:` | clé inconnue (singulier) ; le volume `pgdata` n'est donc jamais déclaré | `volumes:` |

**Piège valide (question 4) :** sous `api`, `ports:` suivi de `- 3000:3000` **au même niveau** que `ports:` est du YAML **valide** (une liste peut s'aligner sur sa clé). On l'indente quand même pour la lisibilité et l'homogénéité. Et on se demande si l'API a besoin d'être publiée (ici non : le front fait proxy vers `api:3000`) ; on garde les guillemets `"3000:3000"`, recommandés pour les ports.

Fichier corrigé :

```yaml
services:
  db:
    image: docker.io/library/postgres:16-alpine
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: taskflow
      POSTGRES_DB: taskflow
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build: ./api
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgres://taskflow:taskflow@db:5432/taskflow
      APP_ENV: local
    depends_on:
      - db

  front:
    build: ./front
    ports:
      - "8080:80"
    depends_on:
      - api

volumes:
  pgdata:
```

### Partie B — `ci-casse.yml`

| Endroit | Problème | Correction |
|---|---|---|
| `on:` → `pull_request` | élément sans `:` au milieu d'un dictionnaire (`push:` en a un) | `pull_request:` |
| `runs-on ubuntu-latest` | `:` manquant | `runs-on: ubuntu-latest` |
| `cache-dependency-path` | décalé d'un espace sous `cache: npm` | aligner sur `cache:` |
| `- run: npm test` | commence par une **tabulation** | remplacer par des espaces |
| `steps:` du job `front` | le premier élément `uses: …` n'est pas précédé de `- ` (mélange dictionnaire / liste) | `- uses: actions/checkout@v4` |
| `run:` multi-ligne | sans `\|`, les trois lignes sont **repliées** en une seule commande `npm ci npm test npm run build` (fichier valide mais tests et build jamais exécutés) | `run: \|` |

Fichier corrigé :

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  api:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: api
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: api/package-lock.json
      - run: npm ci
      - run: npm run lint
      - run: npm test

  front:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: front
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Installer, tester, construire
        run: |
          npm ci
          npm test
          npm run build
```

---

## Exercice 3.2 — Compose à compléter

| N° | Réponse |
|---|---|
| 1 | `docker.io/library/postgres:16-alpine` |
| 2 | `pgdata` |
| 3 | `pg_isready` |
| 4 | **Non** : seul `api` parle à la base, par le réseau interne de Compose. Publier 5432 ouvrirait la base sur la machine (et sur un serveur, à Internet). |
| 5 | `./api` |
| 6 | `3000` |
| 7 | `db` (nom du service) |
| 8 | `service_healthy` |
| 9 | `health` |
| 10 | `unless-stopped` |
| 11 | `8080` |
| 12 | `api` |
| 13 | `volumes` |
| 14 | `pgdata` |

Fichier complété :

```yaml
name: taskflow

services:
  db:
    image: docker.io/library/postgres:16-alpine
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?à définir dans .env}
      POSTGRES_DB: taskflow
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskflow -d taskflow"]
      interval: 5s
      timeout: 3s
      retries: 10

  api:
    build: ./api
    environment:
      PORT: 3000
      DATABASE_URL: postgres://taskflow:${POSTGRES_PASSWORD}@db:5432/taskflow
      APP_ENV: local
      APP_VERSION: ${APP_VERSION:-dev}
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://127.0.0.1:3000/health || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 5
    restart: unless-stopped

  front:
    build: ./front
    ports:
      - "8080:80"
    depends_on:
      api:
        condition: service_healthy
    restart: unless-stopped

volumes:
  pgdata:
```

- Question 4 de l'énoncé (sans `.env`) : `docker compose config` s'arrête avec `required variable POSTGRES_PASSWORD is missing a value: à définir dans .env`. La syntaxe `${VAR:?message}` rend la variable **obligatoire** : mieux vaut un échec clair au démarrage qu'une base avec un mot de passe vide.
- Ordre de démarrage : `db` passe `healthy`, puis `api` démarre et passe `healthy`, puis `front` démarre.
- `docker compose down` supprime conteneurs et réseau mais **garde** le volume : les tâches sont conservées. `down -v` supprime aussi les volumes : base vide.

---

## Exercice 3.3 — Lire un log d'échec CI

### Log n° 1

1. Step **`Run npm ci`** du job `api`. Checkout et setup-node ont réussi.
2. `npm error Missing: zod@3.23.8 from lock file` (précédée de « `npm ci` can only install packages when your package.json and package-lock.json … are in sync »).
3. La PR a modifié `api/package.json` (ajout de `zod`) mais **pas** `api/package-lock.json`.
4. Sur son poste : `cd api && npm install` (met à jour le lockfile), puis `git add package.json package-lock.json && git commit -m "build(api): met à jour le lockfile" && git push`. La PR se relance toute seule.
5. `npm ci` est volontairement strict : il garantit que le CI installe **exactement** les versions testées et commitées. `npm install` masquerait l'oubli et pourrait installer des versions différentes de celles du développeur (« ça marche sur ma machine »).

### Log n° 2

6. Unitaires : **9 passés**. Intégration : **4 échoués** sur 4.
7. `Error: connect ECONNREFUSED 127.0.0.1:5432` : l'API essaie de se connecter à Postgres sur la machine du runner, port 5432, et **personne n'y écoute**.
8. Oui : `postgres service is healthy.` (section *Initialize containers*). La commande `docker create` montre aussi qu'**aucune** option `-p` n'a été passée.
9. Il manque la **publication du port** du conteneur vers la machine du runner : clé `ports:` du service.
10. Correction :

```yaml
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: taskflow
          POSTGRES_PASSWORD: taskflow
          POSTGRES_DB: taskflow
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U taskflow"
          --health-interval 5s
          --health-timeout 3s
          --health-retries 10
```

> À savoir : si le job tournait lui-même dans un conteneur (`container: node:20`), on n'aurait pas besoin de `ports:` mais il faudrait utiliser l'hôte `postgres` (nom du service) au lieu de `localhost`.

---

## Exercice 3.4 — Quel workflow se déclenche ?

| # | Workflow(s) | Justification |
|---|---|---|
| 1 | **aucun** | `CI` ne réagit au `push` que sur `main` ; pas de PR ouverte. |
| 2 | **CI** | `pull_request` (type `opened`). |
| 3 | **CI** | `pull_request` (type `synchronize`) : chaque nouveau commit sur une PR ouverte relance le CI. |
| 4 | **CI** et **Release** | La fusion crée un `push` sur `main` ; le fichier modifié n'est pas exclu par `paths-ignore`. |
| 5 | **CI** seulement | `Release` ignore les push qui ne touchent que `docs/**` ou des `.md`. `CI` n'a pas de filtre de chemins. |
| 6 | **Release** | `workflow_dispatch` avec l'input `tag` : déclenchement manuel. |
| 7 | **Vérification hebdomadaire** | `cron: "0 6 * * 1"` = minute 0, heure 6, tous les lundis (UTC), sur la branche par défaut. |
| 8 | **aucun** | Un tag n'est pas une branche : `branches: [main]` ne le concerne pas (il faudrait `tags: ["v*"]`). |
| 9 | **aucun** | Le push est **refusé** par GitHub (branche protégée) : aucun commit n'arrive sur `main`. |

10. Une PR déclenche `CI` (sur le commit de fusion simulé `refs/pull/N/merge`) ; après la fusion, le push sur `main` relance `CI`. Ce n'est pas grave, c'est même souhaitable : on vérifie le code **réellement** présent sur `main` (d'autres PR ont pu être fusionnées entre-temps).
11. C'est le **rollback** (ou redéploiement) : redéployer une image déjà construite, par exemple celle du commit précédent, sans refaire de commit.
12. Paris = UTC+1 en hiver → **7 h 00** ; UTC+2 en été → **8 h 00**.
