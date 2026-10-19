---
type: course-plan
duration: 4 jours × 7h (programme : 28h)
format: cours + démos le matin, TP l'après-midi (alternance plus fréquente que pour les M2)
last_updated: 2026-10-19
---

# Plan de cours — DWWM DevOps (4 jours, 28h)

**Public :** apprenants du titre professionnel **Développeur Web et Web Mobile (DWWM, niveau 5 / Bac+2)**, souvent en reconversion ou en alternance. Ils savent faire une application web (HTML/CSS/JS, un back-end PHP ou Node), **découvrent** Git/GitHub pour la plupart (le programme le cite en prérequis, mais en pratique il faut repartir de zéro : modèle mental, premier commit, clé SSH) et ont des **bases Linux** (cd, ls, nano). Ils n'ont jamais écrit de Dockerfile, de workflow CI ni configuré de serveur.

**Conséquences pédagogiques (différences avec les cours M2) :**
- **Pas-à-pas guidé** : chaque étape de TP donne la commande, le résultat attendu, et un encadré « Si ça ne marche pas ». Les questions de réflexion viennent *après* que ça marche.
- **Pourquoi avant comment** : chaque outil est introduit par le problème qu'il résout (« ça marche sur ma machine », « qui a cassé la prod ? », « j'ai oublié une étape du déploiement »).
- **Vocabulaire expliqué** : glossaire en fin de slides, aucun acronyme non défini (CI, CD, VPS, SSH, TLS, reverse proxy…).
- **Alternance courte** : blocs de théorie de 45 min max, puis une démo ou un exercice guidé.
- **Lien avec le titre pro DWWM** : on relie explicitement à l'activité « Développer la partie back-end » / compétence « Préparer et exécuter le déploiement d'une application web » et au dossier professionnel (ils peuvent réutiliser leur pipeline comme preuve).

**Choix d'outils :**

| Besoin | Outil | Pourquoi |
|---|---|---|
| Versionnement / collaboration | **Git + GitHub** (PR, review, branch protection) | Imposé par le programme ; outil du marché |
| Environnement reproductible | **Docker + Docker Compose v2** | Imposé ; règle le « ça marche sur ma machine » |
| CI/CD | **GitHub Actions** | Imposé ; gratuit, intégré au repo |
| Registre d'images | **GitHub Container Registry (ghcr.io)** | Gratuit, authentifié par `GITHUB_TOKEN`, pas de compte en plus |
| Environnement de « production » | **Le poste de l'apprenant** : une stack Compose séparée (`name: taskflow-prod`, dossier `~/taskflow-prod/`) qui tire les images publiées sur ghcr.io. **Pas de VPS, pas de SSH en TP.** | Rien à fournir ni à payer ; on garde les gestes de prod (images versionnées, `.env` hors Git, reverse proxy, HTTPS, sauvegarde) |
| Déploiement automatique | **Runner GitHub Actions self-hosted** en conteneur sur le poste (`ressources/lab/runner`), avec accès au socket Docker de l'hôte | GitHub ne peut pas joindre le poste ; le runner, lui, va chercher les jobs chez GitHub. Le déploiement reste visible dans l'onglet Actions. Alternative citée : Watchtower (pull) |
| Reverse proxy / HTTPS | **Conteneur Nginx** (`proxy`) dans `compose.prod.yaml` + certificat **auto-signé** (`openssl`) pour `taskflow.localhost` ; Let's Encrypt / certbot expliqué pour un vrai serveur | Mêmes fichiers de config Nginx qu'en vrai, sans nom de domaine |
| VPS / SSH | **Théorie + démo formateur** (slides S5, `demos/demo-ssh-serveur/`) : ce qui change sur un vrai serveur (SSH par clé, utilisateur non-root, pare-feu, `scp`, deploy via `ssh` dans le workflow) | Programme couvert sans infrastructure à fournir |
| Supervision | `docker logs`, `docker compose ps`, **healthchecks**, **Uptime Kuma** (monitoring simple en conteneur) | Accessible à un DWWM ; Prometheus/Grafana seulement cités |

---

## Projet fil rouge : TaskFlow (gestionnaire de tâches)

Application volontairement simple pour que l'effort porte sur le DevOps, pas sur le code :

```
taskflow/
├── front/                  # Vite + JavaScript vanilla (pas de framework)
│   ├── index.html
│   ├── src/ (main.js, api.js, styles.css)
│   ├── tests/ (api.test.js — Vitest, fetch mocké)
│   ├── package.json        # scripts : dev, build, lint, test
│   └── vite.config.js      # proxy /api → http://localhost:3000 en dev
├── api/                    # Node 20 + Express + pg
│   ├── src/
│   │   ├── app.js          # createApp({ repository }) — non démarrée (testable avec supertest)
│   │   ├── server.js       # lit l'env, crée le pool pg, migre, écoute PORT
│   │   ├── db.js           # pool pg + migrate() (CREATE TABLE IF NOT EXISTS tasks)
│   │   └── repositories/ (memory.js, postgres.js)  # même interface : list, create, toggle, remove, ping
│   ├── tests/
│   │   ├── app.test.js     # unitaires, repository mémoire, pas de BDD
│   │   └── db.int.test.js  # intégration, SKIP si DATABASE_URL absent
│   ├── package.json        # scripts : start, dev, lint, test, test:int
│   └── .env.example
├── .gitignore
└── README.md
```

**API** (port `3000`) :
- `GET /api/tasks` · `POST /api/tasks` `{ title }` → 201 · `PATCH /api/tasks/:id/toggle` · `DELETE /api/tasks/:id` → 204
- `GET /health` → `{ status: "ok", db: "up"|"down", version, env }` (503 si BDD down) — utilisé par les healthchecks, le smoke test et Uptime Kuma
- Logs : une ligne JSON par requête sur stdout (`method`, `path`, `status`, `ms`) — exploité en Séquence 6

**Variables d'environnement API** : `PORT` (3000), `DATABASE_URL` (`postgres://taskflow:taskflow@localhost:5432/taskflow`), `APP_ENV` (`local`|`production`), `APP_VERSION` (`dev`, injecté par le CI = SHA court).

**Table** : `tasks(id SERIAL PK, title TEXT NOT NULL, done BOOLEAN DEFAULT false, created_at TIMESTAMPTZ DEFAULT now())`.

**Starter** (`tp/fil-rouge-taskflow/starter/`) : le code ci-dessus, fonctionnel en local **sans** Docker (sauf la BDD), avec tests et lint verts. **Aucun** Dockerfile, compose, workflow ni config de déploiement.

**Solution** (`tp/fil-rouge-taskflow/solution/`) : le starter **+** tout ce que l'apprenant ajoute pendant la formation :

```
├── front/Dockerfile          # multi-stage : node:20-alpine (build) → nginx:1.27-alpine
├── front/nginx.conf          # sert dist/, proxy /api/ et /health → api:3000
├── front/.dockerignore
├── api/Dockerfile            # node:20-alpine, npm ci --omit=dev, USER node, HEALTHCHECK
├── api/.dockerignore
├── compose.yaml              # dev : db (postgres:16-alpine + volume + healthcheck), api (build), front (build, port 8080)
├── compose.prod.yaml         # « prod » locale (name: taskflow-prod) : db, api, front (images ghcr.io/<owner>/taskflow-api|front:${IMAGE_TAG}), proxy (nginx:1.27-alpine, ports ${HTTP_PORT:-80}:80 et ${HTTPS_PORT:-443}:443) ; seul proxy publie des ports ; env_file .env, restart: unless-stopped, healthchecks, volume pgdata
├── .env.example              # POSTGRES_PASSWORD, IMAGE_TAG, GHCR_OWNER, HTTP_PORT, HTTPS_PORT…
├── .github/
│   ├── workflows/ci.yml      # PR + push main : lint, tests (api avec service postgres), build front
│   ├── workflows/release.yml # push main : build & push images ghcr.io (tags sha + latest) → job deploy sur [self-hosted, lab] → smoke test /health ; workflow_dispatch avec input tag = rollback
│   ├── pull_request_template.md
│   └── CODEOWNERS (exemple commenté)
├── deploy/
│   ├── nginx/taskflow.conf   # conteneur proxy : 80 → 301 https, 443 ssl (certs montés) → proxy_pass http://front:80, en-têtes X-Forwarded-*
│   ├── gen-cert.sh           # openssl : certificat auto-signé taskflow.localhost → certs/ (gitignoré)
│   ├── deploy.sh             # lancé dans DEPLOY_DIR : IMAGE_TAG=<tag> docker compose pull && up -d && image prune
│   └── backup.sh             # docker compose exec db pg_dump horodaté → backups/ + rotation 7 jours (+ commande de restauration)
└── docs/
    ├── ARCHITECTURE.md       # schéma (mermaid), ports, flux
    ├── DEPLOIEMENT.md        # procédure pas-à-pas + rollback
    └── INCIDENTS.md          # modèle de post-mortem
```

**Dossier de déploiement** `~/taskflow-prod/` (= « le serveur ») : créé à la main en étape 4a ; contient `compose.prod.yaml`, `nginx/taskflow.conf`, `deploy.sh`, `backup.sh` (copiés depuis le repo), et **uniquement là** `.env` (chmod 600), `certs/`, `backups/`.

**Lab** (`ressources/lab/`) :
- `runner/` : runner GitHub self-hosted (`myoung34/github-runner`), labels `self-hosted,lab`, monte `/var/run/docker.sock` et le dossier de déploiement **au même chemin que sur l'hôte** (`${DEPLOY_DIR}:${DEPLOY_DIR}`, car les chemins des volumes Compose sont résolus par le daemon de l'hôte), variable `DEPLOY_DIR`, `extra_hosts: host.docker.internal:host-gateway` pour le smoke test. Image avec docker CLI + plugin compose + curl.
- Le job `deploy` de `release.yml` : checkout → copie `compose.prod.yaml`, `deploy/nginx/`, `deploy/*.sh` dans `$DEPLOY_DIR` (jamais `.env` ni `certs/`) → `docker login ghcr.io` (GITHUB_TOKEN) → `./deploy.sh <sha court>` → smoke test `curl -fsk --retry 10 --retry-all-errors https://host.docker.internal:${HTTPS_PORT}/health`.
- ⚠️ Monter le socket Docker = donner les droits root sur l'hôte au runner : acceptable dans un lab mono-utilisateur, **jamais** sur un repo public avec runner partagé (expliqué en slides).

---

## Répartition horaire (28h)

| Séquence programme | Durée | Placement |
|---|---|---|
| S1 — Introduction au DevOps | 3h | J1 matin |
| S2 — Git avancé et travail collaboratif | 5h | J1 après-midi (3h30) + J2 début (1h30) |
| S3 — Docker | 8h | J2 (5h) + J3 matin (3h) |
| S4 — CI/CD avec GitHub Actions | 6h | J3 après-midi (3h30) + J4 (1h30, après le déploiement manuel) |
| S5 — Déploiement d'une application | 4h | J4 matin (3h) + intégré au job de déploiement (1h) |
| S6 — Supervision et bonnes pratiques | 2h | J4 fin d'après-midi (1h) + soutenances (1h) |

> S5 passe **avant** la fin de S4 : on déploie d'abord **à la main** (comprendre chaque geste), puis on **automatise** ce qu'on vient de faire. C'est le fil conducteur DevOps : *on n'automatise que ce qu'on sait faire manuellement.*

---

## 📅 Jour 1 — Culture DevOps & Git collaboratif

> **Objectif fin de journée :** l'apprenant sait expliquer CI / livraison continue / déploiement continu, a cartographié un pipeline, et a contribué à un repo partagé par branche → PR → revue → merge, conflit compris.

### Matin — S1 Introduction au DevOps (3h)

**Bloc 1.1 — Pourquoi le DevOps ? (45 min)**
- Histoire : le « mur de la confusion » Dev vs Ops, Agile (2001), Patrick Debois et les DevOpsDays (2009), *The Phoenix Project*
- Culture avant outils : CALMS (Culture, Automatisation, Lean, Mesure, Partage)
- Cycle de vie d'une application : la boucle infinie *plan → code → build → test → release → deploy → operate → monitor*
- Témoignage chiffré : fréquence de déploiement, DORA metrics (expliquées simplement)

**Bloc 1.2 — CI, CD et CD (45 min)**
- Intégration continue : intégrer souvent, tester automatiquement à chaque push
- Livraison continue (*delivery*) : toujours prêt à déployer, bouton humain
- Déploiement continu (*deployment*) : en prod sans humain
- Collaboration Dev / Ops : responsabilité partagée, « you build it, you run it », environnements dev / test / prod

**Bloc 1.3 — Panorama des outils (30 min)**
- Une case par étape de la boucle : Git/GitHub/GitLab, npm/composer, Jest/PHPUnit/Vitest, Docker, GitHub Actions/GitLab CI/Jenkins, Nginx, VPS/PaaS (Render, Railway…)/cloud, Uptime Kuma/Grafana
- Ce que nous utiliserons cette semaine et pourquoi

**TP 0 — Cartographie d'un pipeline (1h)** → `tp/tp0-cartographie-pipeline/`
- Étude de cas « La Fromagerie » : une petite équipe qui déploie en FTP le vendredi soir ; lire le récit, lister les problèmes
- Analyse d'un workflow GitHub Actions réel commenté (lire, ne pas écrire)
- Dessiner (papier, Excalidraw ou mermaid) le pipeline cible de TaskFlow : étapes, outils, déclencheurs, qui fait quoi
- Restitution en groupe (10 min)

### Après-midi — S2 Git collaboratif, partie 1 (3h30)

**Bloc 2.1 — Les bases de Git (45 min)** : vérification du poste (`git config`, `ssh -T git@github.com`) ; working dir / index / commit / remote ; exercice 1.1 en direct (premiers commits) ; `git log --oneline --graph` ; bons messages de commit (Conventional Commits) ; `.gitignore`
**Bloc 2.2 — Branches et merge (45 min)** : branche = pointeur ; `switch -c` ; fast-forward vs merge commit ; **démo** `demos/demo-git-branches/`
**Bloc 2.3 — Workflow d'équipe (45 min)** : GitHub Flow (main toujours déployable) vs Git Flow simplifié (main / develop / feature/* / hotfix/*) ; Pull Request ; revue de code (quoi regarder, comment commenter avec bienveillance) ; protection de branche
**Bloc 2.4 — Conflits (30 min)** : pourquoi, lecture des marqueurs, résolution dans VS Code ; **démo** `demos/demo-git-conflit/`

**TP 1 — Projet collaboratif (1h, suite J2)** → `tp/tp1-git-collaboratif/`
- Par groupes de 3-4 : un repo partagé (site « Promo DWWM », une carte HTML par apprenant)
- Chacun : branche `feature/carte-<prenom>`, commit, push, PR, **revue par un pair**, merge
- Conflit **provoqué volontairement** (tout le monde ajoute sa ligne au même `<ul>` de `index.html`) et résolu

**Exercices guidés** : `exercices/jour1/` (commandes Git en solo, kata conflit).

---

## 📅 Jour 2 — Git (fin) & Docker

> **Objectif fin de journée :** l'apprenant sait rebaser une branche, taguer une version, et a dockerisé l'API TaskFlow (image construite, conteneur lancé, BDD Postgres en conteneur avec volume).

### Matin

**S2 partie 2 (1h30)**
- **Bloc 2.5 — Rebase (30 min)** : `rebase` vs `merge`, historique linéaire, règle d'or (ne jamais rebaser une branche partagée), `pull --rebase`
- **Bloc 2.6 — Versioning (20 min)** : SemVer (MAJEUR.MINEUR.CORRECTIF), tags annotés, releases GitHub, CHANGELOG
- **Fin TP 1 (40 min)** : rebase de sa branche sur main avant merge, tag `v1.0.0`, release GitHub
- **Mise en place du fil rouge** : chacun crée son repo `taskflow` depuis le starter, protège `main` (PR obligatoire)

**S3 Docker partie 1 (1h30)**
- **Bloc 3.1 — Virtualisation vs conteneurs (30 min)** : VM (hyperviseur, OS complet) vs conteneur (processus isolé, noyau partagé) ; « ça marche sur ma machine »
- **Bloc 3.2 — Docker Engine et images (1h)** : client / daemon / registre ; image vs conteneur (classe vs instance) ; couches ; Docker Hub ; `run`, `ps`, `logs`, `exec`, `stop`, `rm` ; ports `-p` ; **démo** `demos/demo-docker-premiers-pas/`

### Après-midi — S3 Docker partie 1 suite (3h30)

- **Bloc 3.3 — Dockerfile (45 min)** : `FROM`, `WORKDIR`, `COPY`, `RUN`, `ENV`, `EXPOSE`, `USER`, `CMD` ; ordre des instructions et cache ; `.dockerignore` ; multi-stage (aperçu) ; **démo** `demos/demo-dockerfile/`
- **Bloc 3.4 — Volumes, réseaux, variables d'env (45 min)** : données éphémères vs volume nommé vs bind mount ; réseau bridge et résolution DNS par nom ; `-e` / `--env-file` ; ne jamais mettre un secret dans une image
- **TP fil rouge — Étape 1 : Dockeriser TaskFlow (2h)** → `tp/fil-rouge-taskflow/etape1-docker.md`
  - Lancer Postgres en conteneur (`docker run` + volume + réseau)
  - Écrire `api/Dockerfile`, construire, lancer, connecter à la BDD par le réseau
  - Écrire `front/Dockerfile` multi-stage + `nginx.conf`
  - Vérifier : données conservées après `docker rm` de la BDD (volume)

**Exercices guidés** : `exercices/jour2/` (rebase, Dockerfile à corriger, quiz images/conteneurs).

---

## 📅 Jour 3 — Docker Compose & intégration continue

> **Objectif fin de journée :** TaskFlow complet démarre avec `docker compose up`, et chaque push/PR déclenche un pipeline GitHub Actions (lint + tests + build) ; sur `main`, les images sont publiées sur ghcr.io.

### Matin — S3 Docker partie 2 (3h)

- **Bloc 3.5 — Docker Compose (1h)** : pourquoi (10 `docker run` → 1 fichier) ; `services`, `build`, `image`, `ports`, `environment`, `env_file`, `volumes`, `networks`, `depends_on` + `condition: service_healthy`, `healthcheck` ; `up -d`, `ps`, `logs -f`, `down`, `down -v` ; **démo** `demos/demo-compose/`
- **Bloc 3.6 — Base de données conteneurisée (20 min)** : variables `POSTGRES_*`, volume obligatoire, script d'init, accès `psql` via `exec`, mention MySQL/MariaDB (équivalents)
- **TP fil rouge — Étape 2 : Environnement complet avec Compose (1h40)** → `etape2-compose.md`
  - `compose.yaml` : db + api + front, healthchecks, volume, `.env`
  - Un nouvel arrivant clone et lance tout en **une commande** (on le teste en binôme)
  - PR + revue par le binôme

### Après-midi — S4 CI/CD partie 1 (3h30)

- **Bloc 4.1 — GitHub Actions : concepts (45 min)** : workflow / événement / job / step / runner / action ; syntaxe YAML (indentation, listes, clés) ; déclencheurs `push`, `pull_request`, `workflow_dispatch`, `schedule` ; onglet Actions ; **démo** `demos/demo-actions-hello/`
- **Bloc 4.2 — Pipeline de vérification (45 min)** : `actions/checkout`, `actions/setup-node` + cache, lint, tests, build ; jobs parallèles vs `needs` ; matrice (aperçu) ; service container Postgres pour les tests d'intégration ; badge de statut ; checks requis sur la PR
- **Bloc 4.3 — Secrets, variables, build d'images (30 min)** : `secrets.*` vs `vars.*` vs `env` ; `GITHUB_TOKEN` et `permissions:` ; `docker/login-action`, `docker/build-push-action`, tags `sha` + `latest`
- **TP fil rouge — Étape 3 : Pipeline CI (1h30)** → `etape3-ci.md`
  - `ci.yml` : lint + tests (api avec service postgres) + build front, sur PR et push
  - Casser volontairement un test → PR rouge → merge bloqué → corriger
  - `release.yml` (partie build & push) : images sur ghcr.io à chaque push sur main

**Exercices guidés** : `exercices/jour3/` (YAML à corriger, compose à compléter, lire un log d'échec CI).

---

## 📅 Jour 4 — Déploiement, automatisation, supervision

> **Objectif fin de journée :** TaskFlow tourne en « production » locale derrière Nginx en HTTPS ; un merge sur main redéploie automatiquement ; l'apprenant sait lire des logs, diagnostiquer un incident et présenter son pipeline.

### Matin — S5 Déploiement (3h)

- **Bloc 5.1 — Le serveur (30 min, théorie + démo formateur)** : VPS vs PaaS vs cloud ; **SSH** par clé (paire publique/privée, `~/.ssh/config`, pourquoi pas de mot de passe) ; utilisateur non-root, `sudo`, pare-feu ; démo `demos/demo-ssh-serveur/` ; ce que nous faisons dans le TP : notre poste joue le rôle du serveur (`~/taskflow-prod/`), les gestes sont les mêmes
- **Bloc 5.2 — Configuration et reverse proxy (45 min)** : séparer code / config / données ; **Nginx** en reverse proxy (pourquoi : un seul point d'entrée, TLS, plusieurs apps) ; `server`, `location`, `proxy_pass`, en-têtes `X-Forwarded-*` ; `nginx -t` puis reload (dans le conteneur : `docker compose exec proxy nginx -t`)
- **Bloc 5.3 — Variables d'env, HTTPS, sauvegarde (30 min)** : `.env` côté « serveur » (jamais dans Git, `chmod 600`) ; TLS en 5 min (certificat, autorité, Let's Encrypt / certbot sur un vrai serveur ; auto-signé ici) ; sauvegarde `pg_dump` + rotation + **test de restauration**
- **TP fil rouge — Étape 4a : Déploiement manuel (1h15)** → `etape4-deploiement.md` (partie A)
  - Créer `~/taskflow-prod/`, y copier `compose.prod.yaml` + `deploy/`, écrire `.env`, `docker login ghcr.io`, générer le certificat (`gen-cert.sh`)
  - `docker compose up -d` → `https://taskflow.localhost` OK (avertissement navigateur expliqué), redirection HTTP → HTTPS vérifiée
  - `backup.sh` + restauration testée

### Après-midi

**S4 partie 2 — Déploiement continu (1h30)**
- **Bloc 4.4 — Automatiser ce qu'on vient de faire (30 min)** : pourquoi un runner self-hosted ici (GitHub ne voit pas notre poste) ; démarrer `ressources/lab/runner` ; socket Docker et sécurité ; environment GitHub `production` ; sur un vrai serveur : job sur `ubuntu-latest` + `ssh` avec un secret `SSH_PRIVATE_KEY` (montré, pas pratiqué) ; push vs pull (Watchtower, mention)
- **TP fil rouge — Étape 4b : Déploiement automatique (1h)** → `etape4-deploiement.md` (partie B)
  - Job `deploy` dans `release.yml` (`runs-on: [self-hosted, lab]`, `needs: build`) : copie des fichiers dans `$DEPLOY_DIR` → `deploy.sh` avec le tag du commit
  - Smoke test sur `/health` ; en cas d'échec, le job échoue
  - Modifier le titre de la page → PR → merge → voir la prod changer seule
  - Rollback : relancer le déploiement d'un tag précédent (`workflow_dispatch` avec input `tag`)

**S6 — Supervision et bonnes pratiques (1h)**
- **Bloc 6.1 — Logs, monitoring, erreurs (25 min)** : `docker compose logs -f --since`, logs JSON, niveaux ; healthchecks et `restart` ; Uptime Kuma (démo `demos/demo-uptime-kuma/`) ; Prometheus/Grafana cités ; gestion des erreurs (codes HTTP, ne pas exposer les stack traces)
- **Bloc 6.2 — Bonnes pratiques (10 min)** : documentation (README, ARCHITECTURE, DEPLOIEMENT), sauvegardes testées, secrets, petites PR, post-mortem sans blâme ; checklist mise en prod
- **TP fil rouge — Étape 5 : Analyse d'un incident (25 min)** → `etape5-incident.md`
  - Scénario fourni : après un merge, le site renvoie 502 (variable `DATABASE_URL` mal nommée dans le `.env`) ; logs fournis + reproduction sur le lab
  - Diagnostiquer avec méthode (symptôme → logs Nginx → `compose ps` → logs api → cause), corriger, rédiger le post-mortem dans `docs/INCIDENTS.md`

**Évaluation (1h)**
- QCM formatif (20 questions, 15 min) → `evaluation/qcm.md`
- **Mise en situation** : présentation du pipeline (5 min par apprenant + 3 min de questions, ou en parallèle par binômes selon l'effectif) → `evaluation/mise-en-situation.md`

---

## Évaluation

**Formative** (au fil de l'eau) : exercices guidés (`exercices/`), quiz de fin de journée (5 questions dans les slides), validation de chaque étape du fil rouge par le formateur, revues de code entre pairs.

**Certificative (mise en situation)** — grille `evaluation/grille-evaluation.md`, 100 points :

| Critère du programme | Points |
|---|---|
| Dockerfile fonctionnel (api + front, bonnes pratiques) | 15 |
| Fichier Docker Compose (db + api + front, volume, healthcheck, .env) | 15 |
| Dépôt GitHub configuré (branche protégée, PR revues, commits propres, tag) | 15 |
| Workflow GitHub Actions (lint, tests, build, push image) | 20 |
| Déploiement automatique fonctionnel (HTTPS, smoke test) | 15 |
| Documentation technique (architecture + procédure de déploiement) | 10 |
| Présentation du pipeline et justification des choix | 10 |

**Validation** : ≥ 50/100 et chacun des 5 premiers critères au moins partiellement atteint.

## Livrables attendus (par apprenant)

- un dépôt Git structuré (`taskflow`) ;
- une application conteneurisée ; un `Dockerfile` (×2) et un `compose.yaml` opérationnels ;
- un pipeline CI/CD automatisé avec GitHub Actions ;
- une application déployée sur l'environnement de test (stack `taskflow-prod` derrière Nginx en HTTPS) ;
- `docs/ARCHITECTURE.md` et `docs/DEPLOIEMENT.md`.
