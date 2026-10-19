# Grille d'évaluation — Mise en situation TaskFlow (certificative)

**Formation** : DWWM DevOps (4 jours, 28h) — ForEach Academy
**Formateur** : Fabrice Claeys

> **Note sur 100 points**, 7 critères issus du programme.
> **Validation** : total **≥ 50/100** **et** chacun des **5 premiers critères au moins « Partiel »**.
> La note se fonde sur l'état du dépôt et de la stack `taskflow-prod` **au moment de la présentation** (J4, avant 17h00).

---

## Préparer la correction

Sur le poste du formateur (ou celui de l'apprenant pendant sa présentation) :

```bash
git clone https://github.com/<owner>/taskflow.git && cd taskflow
gh auth login                       # une fois ; gh utilise le remote origin
gh repo view --web                  # ouvre le dépôt dans le navigateur
tree -a -I 'node_modules|.git' -L 2 # arborescence attendue (voir mise-en-situation.md)
```

Sur le poste de l'apprenant (qui joue le rôle du serveur : la « prod » est la stack Compose `taskflow-prod` dans `~/taskflow-prod/`) :

```bash
docker ps --format '{{.Names}}\t{{.Status}}'      # le conteneur du runner (lab) est « Up »
docker compose -p taskflow-prod ps                 # db, api, front, proxy « Up » / « healthy »
curl -kfsS https://taskflow.localhost/health       # {"status":"ok","db":"up","version":"<sha court>",...}
ls -l ~/taskflow-prod/                             # .env (-rw-------), certs/, backups/, compose.prod.yaml, deploy.sh…
```

> `.env`, `certs/` et `backups/` n'existent **que** dans `~/taskflow-prod/`, jamais dans le dépôt.

## Niveaux et barème

Chaque critère est noté en additionnant ses sous-critères (points entiers ; un sous-critère partiellement réalisé peut recevoir la moitié de ses points, arrondie à l'entier inférieur). Le **niveau** du critère se déduit ensuite de sa note :

| Critère sur | Non atteint | Partiel | Atteint |
|---|---|---|---|
| 15 points | 0 – 5 | 6 – 11 | 12 – 15 |
| 20 points | 0 – 7 | 8 – 15 | 16 – 20 |
| 10 points | 0 – 3 | 4 – 7 | 8 – 10 |

Chaque critère précise aussi, en une phrase, ce que signifient concrètement les trois niveaux.

---

## Critère 1 — Dockerfile fonctionnel, api + front, bonnes pratiques (15 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 1.1 | `api/Dockerfile` : base `node:20-alpine`, `WORKDIR`, `COPY package*.json` **avant** `COPY . .`, `npm ci --omit=dev`, `CMD` | 4 | Lire `api/Dockerfile` ; `docker build -t tf-api ./api` passe ; modifier un commentaire dans `src/app.js` et rebuilder : la couche `npm ci` est `CACHED` |
| 1.2 | Sécurité / exploitation de l'image api : `USER node`, `EXPOSE 3000`, `HEALTHCHECK` sur `/health` | 3 | `docker run --rm tf-api whoami` → `node` ; `docker inspect tf-api --format '{{json .Config.Healthcheck}}'` non vide |
| 1.3 | `front/Dockerfile` **multi-stage** : `node:20-alpine` (build Vite) → `nginx:1.27-alpine` qui sert `dist/` ; `front/nginx.conf` proxifie `/api/` et `/health` vers `api:3000` | 4 | Lire les deux fichiers ; `docker build -t tf-front ./front` ; `docker image ls tf-front` : quelques dizaines de Mo (pas d'image node de plusieurs centaines de Mo) |
| 1.4 | `.dockerignore` dans `api/` et `front/` (au minimum `node_modules`, `.env`, `.git`, `dist` côté front) | 2 | `cat api/.dockerignore front/.dockerignore` |
| 1.5 | Aucune donnée sensible dans les images (pas de `COPY .env`, pas de mot de passe en `ENV`) et les deux images démarrent sans erreur | 2 | `git grep -nE 'COPY \.env\|ENV .*PASSWORD' -- '*Dockerfile'` vide ; `docker history tf-api` ; conteneurs `Up (healthy)` à l'étape compose |

- **Non atteint** : un seul Dockerfile, ou image qui ne se construit pas / ne démarre pas.
- **Partiel** : les deux images se construisent et tournent, mais plusieurs bonnes pratiques manquent (root, pas de cache, pas de multi-stage…).
- **Atteint** : deux images fonctionnelles, multi-stage pour le front, utilisateur non-root, cache exploité, `.dockerignore` présents.

---

## Critère 2 — Docker Compose : db + api + front, volume, healthcheck, .env (15 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 2.1 | `compose.yaml` avec 3 services `db` (`postgres:16-alpine`), `api` (build `./api`), `front` (build `./front`, port `8080`) ; toute l'appli démarre en **une commande** | 4 | `cp .env.example .env && docker compose config -q && docker compose up -d --build` ; http://localhost:8080 affiche TaskFlow, on peut créer une tâche |
| 2.2 | **Volume nommé** pour PostgreSQL ; les données survivent à `docker compose down` | 3 | Créer une tâche, `docker compose down && docker compose up -d`, la tâche est toujours là ; `docker volume ls` |
| 2.3 | `healthcheck` sur `db` (`pg_isready`) et `depends_on: db: condition: service_healthy` sur `api` | 3 | `docker compose ps` : `db` et `api` en `(healthy)` ; lire le fichier |
| 2.4 | Variables via `.env` / `env_file` ; `.env.example` versionné ; `.env` **non** versionné ; `DATABASE_URL` pointe vers `db:5432` | 3 | `git ls-files \| grep -E '^\.env'` → seulement `.env.example` ; `git log --all --oneline -- .env` vide |
| 2.5 | `compose.prod.yaml` (`name: taskflow-prod`) : services db, api, front (images `ghcr.io/<owner>/taskflow-api\|front:${IMAGE_TAG}`) et `proxy` (`nginx:1.27-alpine`), **seul `proxy` publie des ports** (80/443), `restart: unless-stopped` | 2 | Lire le fichier ; `grep -n 'ports:' compose.prod.yaml` → une seule occurrence, sous `proxy` ; `docker compose -p taskflow-prod config -q` dans `~/taskflow-prod/` |

- **Non atteint** : pas de compose, ou impossible de démarrer les trois services.
- **Partiel** : les trois services démarrent mais sans volume, ou sans healthcheck, ou avec des secrets en dur dans le fichier.
- **Atteint** : démarrage en une commande, données persistantes, ordre de démarrage maîtrisé par healthcheck, configuration externalisée, variante prod présente.

---

## Critère 3 — Dépôt GitHub configuré : branche protégée, PR revues, commits propres, tag (15 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 3.1 | `main` **protégée** : PR obligatoire, check CI requis (ou ruleset équivalent) | 4 | `gh api repos/{owner}/{repo}/branches/main/protection --jq '{pr: .required_pull_request_reviews != null, checks: .required_status_checks.contexts}'` ou `gh api repos/{owner}/{repo}/rulesets` ; *Settings → Branches* |
| 3.2 | Au moins **3 PR mergées**, dont au moins une avec un commentaire ou une approbation du binôme | 4 | `gh pr list --state merged --limit 20` ; `gh pr view <n> --comments` |
| 3.3 | Commits lisibles (messages explicites, idéalement Conventional Commits `feat:`, `fix:`, `ci:`…), pas de fichiers parasites (`node_modules/`, `dist/`, `.env`) | 4 | `git log --oneline --graph -30` ; `git ls-files \| grep -E 'node_modules\|/dist/\|^\.env$'` vide ; `.gitignore` présent |
| 3.4 | Tag **SemVer annoté** (ex. `v1.0.0`) poussé, et release GitHub associée | 3 | `git tag -n` ; `git cat-file -t v1.0.0` → `tag` (annoté) ; `gh release list` |

- **Non atteint** : travail poussé directement sur `main`, aucune PR, pas de protection.
- **Partiel** : quelques PR mais sans revue, ou protection absente, ou historique pollué (« update », « fix », `node_modules` commité).
- **Atteint** : `main` protégée, flux branche → PR → revue → merge visible, historique propre, version taguée.

---

## Critère 4 — Workflow GitHub Actions : lint, tests, build, push image (20 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 4.1 | `.github/workflows/ci.yml` déclenché sur `pull_request` **et** `push` sur `main` | 3 | Lire l'en-tête `on:` ; `gh run list --workflow ci.yml --limit 10` montre des runs `pull_request` et `push` |
| 4.2 | Lint + tests de l'**api** (avec `services: postgres` pour les tests d'intégration) + lint + tests du **front** ; `setup-node` en Node 20 avec cache npm | 6 | Lire `ci.yml` ; `gh run view <id> --log \| grep -Ei 'vitest\|passed\|tests'` ; le job api expose `DATABASE_URL` vers le service |
| 4.3 | Build du front (`npm run build`) dans le CI | 2 | Lire `ci.yml` ; étape `build` verte dans le dernier run |
| 4.4 | `.github/workflows/release.yml` : sur push `main`, login ghcr.io avec `GITHUB_TOKEN`, `permissions: packages: write`, build & push des **deux** images taguées `sha` + `latest` | 5 | Lire le fichier ; `gh api "users/<owner>/packages?package_type=container" --jq '.[].name'` liste `taskflow-api` et `taskflow-front` ; page *Packages* du profil |
| 4.5 | Secrets correctement utilisés (`secrets.*`), aucun secret en clair dans les workflows ou les logs, `permissions:` minimales | 2 | `git grep -nE 'password\|BEGIN .*PRIVATE KEY' -- .github` vide ; logs : valeurs masquées `***` |
| 4.6 | Dernier run de `ci.yml` et de `release.yml` sur `main` **verts** | 2 | `gh run list --branch main --limit 5` |

- **Non atteint** : aucun workflow, ou workflow qui n'a jamais réussi.
- **Partiel** : CI vert mais incomplet (pas de tests api, ou pas de publication d'image, ou seulement sur `push`).
- **Atteint** : CI complet sur PR et push, publication des deux images sur ghcr.io, runs verts.

---

## Critère 5 — Déploiement automatique fonctionnel : HTTPS, smoke test (15 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 5.1 | Stack locale `taskflow-prod` servie en **HTTPS** par le conteneur `proxy` (`deploy/nginx/taskflow.conf` : 80 → 301 https, 443 ssl → `proxy_pass http://front:80`), certificat auto-signé généré par `deploy/gen-cert.sh` ; `.env` (`chmod 600`) et `certs/` présents **uniquement** dans `~/taskflow-prod/` | 4 | `docker compose -p taskflow-prod ps` (4 services Up) ; `curl -kfsS https://taskflow.localhost/health` ; `curl -sI http://taskflow.localhost \| head -3` → `301` ; `docker compose -p taskflow-prod exec proxy nginx -t` ; `ls -l ~/taskflow-prod/.env` → `-rw-------` ; `git ls-files \| grep -E '(^\|/)\.env$\|certs/\|\.pem$\|\.key$'` vide |
| 5.2 | Job `deploy` dans `release.yml` : `runs-on: [self-hosted, lab]`, `needs: build`, copie `compose.prod.yaml` + `deploy/` dans `$DEPLOY_DIR` (jamais `.env` ni `certs/`), `docker login ghcr.io` avec `GITHUB_TOKEN`, lance `./deploy.sh <sha court>` ; runner **Idle** | 4 | Lire `release.yml` ; *Settings → Actions → Runners* : `lab-runner` Idle (ou `gh api repos/{owner}/{repo}/actions/runners --jq '.runners[] \| {name,status}'`) ; `gh run view <id> --log` du job deploy montre `docker compose pull` / `up -d` |
| 5.3 | **Smoke test** en fin de job (`curl -fsk --retry 10 --retry-all-errors https://host.docker.internal:${HTTPS_PORT}/health`) : le job échoue si l'application ne répond pas ; dernier run **vert** | 3 | Lire l'étape ; `gh run list --workflow release.yml --limit 5` ; log : réponse JSON `"status":"ok"` |
| 5.4 | Démonstration : une modification mergée sur `main` arrive en production **sans geste manuel** ; `/health` affiche la nouvelle `version` (SHA court) | 2 | Pendant la présentation, ou : `gh run list --workflow release.yml --limit 3` + `curl -ks https://taskflow.localhost/health` : `version` = SHA court du dernier commit de `main` (`git rev-parse --short origin/main`) |
| 5.5 | Rollback possible : `workflow_dispatch` avec un input `tag` qui redéploie une version précédente | 2 | Lire `on: workflow_dispatch: inputs: tag` ; `gh run list --workflow release.yml --event workflow_dispatch` ; après le run, `/health` affiche le tag demandé |

- **Non atteint** : stack `taskflow-prod` absente ou non fonctionnelle, ou déployée uniquement à la main sans aucune automatisation.
- **Partiel** : déploiement manuel réussi en HTTPS dans `~/taskflow-prod/` **ou** job automatique présent mais incomplet (pas de smoke test, HTTP seulement, échecs fréquents).
- **Atteint** : un merge sur `main` met à jour la prod en HTTPS, vérifiée par un smoke test, avec possibilité de rollback.

---

## Critère 6 — Documentation technique : architecture + procédure de déploiement (10 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 6.1 | `docs/ARCHITECTURE.md` : schéma (mermaid ou image) navigateur → `proxy` Nginx (80/443) → front → api → db, ports (80/443, 8080 en dev, 3000, 5432), flux CI/CD (GitHub → ghcr.io → runner self-hosted → stack `taskflow-prod`) | 4 | Ouvrir le fichier sur GitHub (le mermaid s'affiche) |
| 6.2 | `docs/DEPLOIEMENT.md` : procédure pas à pas reproductible (création de `~/taskflow-prod/`, `.env`, `gen-cert.sh`, commandes), **rollback**, sauvegarde/restauration (`deploy/backup.sh`) ; idéalement une section « sur un vrai serveur » (connexion distante, Let's Encrypt) | 4 | Lire ; test « nouvel arrivant » : la procédure suffit-elle sans poser de question ? |
| 6.3 | `README.md` à jour : présentation, lancement local en une commande (`docker compose up`), badge de statut CI, liens vers `docs/` | 2 | Ouvrir la page d'accueil du dépôt |

- **Non atteint** : documents absents ou réduits au README du starter.
- **Partiel** : un seul des deux documents, ou documents trop vagues pour être suivis.
- **Atteint** : architecture claire et procédure de déploiement + rollback utilisable par quelqu'un d'autre.

---

## Critère 7 — Présentation du pipeline et justification des choix (10 points)

| Code | Sous-critère observable | Pts | Comment vérifier |
|---|---|---|---|
| 7.1 | Présentation structurée, vocabulaire juste (CI, CD, image, conteneur, runner, reverse proxy…), **5 min respectées** | 3 | Observation, chronomètre |
| 7.2 | Démonstration du pipeline de bout en bout (modif → PR → CI vert → merge → prod) ou, à défaut, captures commentées | 3 | Observation |
| 7.3 | Réponses aux questions du jury : l'apprenant **justifie** ses choix (multi-stage, volume, runner self-hosted, secrets, healthcheck…) et sait expliquer une limite / amélioration | 4 | 2 à 3 questions tirées de [mise-en-situation.md](mise-en-situation.md#questions-types-du-jury) |

- **Non atteint** : lecture de notes sans démonstration, incapacité à expliquer ce qui a été fait.
- **Partiel** : démonstration partielle, justifications approximatives ou récitées.
- **Atteint** : présentation claire dans le temps, démonstration réussie, choix techniques argumentés.

---

## Récapitulatif des points

| # | Critère | Sous-critères | Total |
|---|---|---|---|
| 1 | Dockerfile | 4 + 3 + 4 + 2 + 2 | 15 |
| 2 | Docker Compose | 4 + 3 + 3 + 3 + 2 | 15 |
| 3 | Dépôt GitHub | 4 + 4 + 4 + 3 | 15 |
| 4 | Workflow GitHub Actions | 3 + 6 + 2 + 5 + 2 + 2 | 20 |
| 5 | Déploiement automatique | 4 + 4 + 3 + 2 + 2 | 15 |
| 6 | Documentation | 4 + 4 + 2 | 10 |
| 7 | Présentation | 3 + 3 + 4 | 10 |
| | **Total** | | **100** |

---

## Règle de validation

La mise en situation est **validée** si :

1. **total ≥ 50 / 100**, **et**
2. les critères **1, 2, 3, 4 et 5** sont chacun **au moins « Partiel »** (≥ 6/15 pour 1, 2, 3, 5 ; ≥ 8/20 pour 4).

Les critères 6 et 7 comptent dans le total mais ne sont pas éliminatoires.

| Cas | Total | Critères 1-5 | Décision |
|---|---|---|---|
| A | 58 | tous ≥ Partiel | **Validé** |
| B | 71 | critère 5 = 4/15 (Non atteint) | **Non validé** |
| C | 47 | tous ≥ Partiel | **Non validé** (total < 50) |

---

## Fiche de notation (une par apprenant)

**Apprenant :** ______________________ **Dépôt :** `https://github.com/________________/taskflow` **Date :** ____________

| # | Critère | Note | Max | Niveau (NA / P / A) | Observations |
|---|---|---|---|---|---|
| 1 | Dockerfile | | 15 | | |
| 2 | Docker Compose | | 15 | | |
| 3 | Dépôt GitHub | | 15 | | |
| 4 | Workflow GitHub Actions | | 20 | | |
| 5 | Déploiement automatique | | 15 | | |
| 6 | Documentation | | 10 | | |
| 7 | Présentation | | 10 | | |
| | **Total** | | **100** | | |

- Total ≥ 50 : ☐ oui ☐ non
- Critères 1 à 5 tous au moins « Partiel » : ☐ oui ☐ non
- **Décision** : ☐ Validé ☐ Non validé

**Points forts :** ____________________________________________________________

**Axes de progrès :** __________________________________________________________

Signature du formateur : ______________________
