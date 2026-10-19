# Jour 2 — Solutions des exercices guidés

> À ouvrir **après** avoir cherché (et utilisé les indices).

---

## Exercice 2.1 — Rebase interactif

1. La branche a **1 commit de retard** sur `main` (`feat(front): client API fetchTasks`) et **5 commits** dont 4 « brouillon » (`wip`, `fix typo`, `oups…`, et le message sans préfixe du tri).
2. Analyse :
   - `wip` + `tri des taches…` + `fix typo` = **une seule** évolution : le tri dans `api/src/app.js` ;
   - `docs: documente le tri dans le README` = commit propre, à garder ;
   - `oups, fichier de debug` = ajoute `debug.js`, à **supprimer**.

```bash
git rebase -i main
```

Liste à saisir (les identifiants sont différents chez vous) :

```text
reword f31aabc wip
fixup  d5773bc tri des taches par statut (non terminées d'abord)
fixup  b0a911a fix typo
pick   fb6e7b0 docs: documente le tri dans le README
drop   5b8d793 oups, fichier de debug
```

Git rouvre l'éditeur pour le `reword` : remplacer `wip` par `feat(api): trie les tâches par statut`.

> Variante acceptée : `pick` sur `wip`, `squash` sur les deux suivants, puis réécrire le message combiné.

```bash
git log --oneline --graph --all
ls                           # plus de debug.js ; front/ est présent (venu de main)
grep sort api/src/app.js     # tasks.sort((a, b) => Number(a.done) - Number(b.done));
git switch main
git merge feature/tri-taches # Fast-forward
```

8. **Fast-forward** : après le rebase, la branche part du **dernier** commit de `main` ; `main` n'a plus qu'à avancer son pointeur. Historique linéaire, pas de merge commit.

**Question de réflexion :** le rebase **réécrit** les commits (nouveaux identifiants). La branche distante contient les anciens : un `git push` simple est refusé, il faut `git push --force-with-lease`. Le collègue qui avait récupéré l'ancienne branche se retrouve avec un historique divergent (doublons, conflits). D'où la règle : on ne rebase que ce qu'on est **seul** à utiliser. (`--force-with-lease` est préférable à `--force` : il refuse d'écraser si quelqu'un d'autre a poussé entre-temps.)

---

## Exercice 2.2 — Dockerfile à corriger

### Problèmes attendus

| Ligne | Problème | Conséquence | Correction |
|---|---|---|---|
| `FROM …node:latest` | version non fixée, image Debian complète | build non reproductible (aujourd'hui `latest` = Node 26, pas Node 20 comme le projet) ; image de ~1,3 Go | `FROM docker.io/library/node:20-alpine` |
| *(pas de `WORKDIR`)* | tout est copié à la **racine** `/` du conteneur | fichiers mélangés avec le système (`/bin`, `/etc`…), message `Cannot find module '/src/index.js'` | `WORKDIR /app` |
| `COPY . .` avant `RUN npm install` | n'importe quelle modification du code invalide le cache | `npm install` relancé à **chaque** build (lent) | copier `package.json` + `package-lock.json`, installer, **puis** copier le code |
| `RUN npm install` | ignore la garantie du lockfile, installe les devDependencies (`nodemon`) | versions qui peuvent varier, image plus lourde, outils de dev en prod | `RUN npm ci --omit=dev` |
| `ENV DATABASE_URL=…SuperSecret2026…` | **secret écrit dans l'image** | visible par toute personne qui a l'image (`docker image inspect`, `docker history`), et figé pour tous les environnements | supprimer ; fournir au lancement (`-e`, `--env-file`, `environment:` dans compose) |
| `EXPOSE 8080` | l'application écoute sur **3000** (`PORT` par défaut dans `server.js`) | documentation fausse ; `-p 3000:8080` ne mène nulle part | `EXPOSE 3000` (et `-p 3000:3000`) |
| `CMD node src/index.js` | mauvais fichier (`src/server.js`) **et** forme *shell* | crash au démarrage ; en forme shell, `node` ne reçoit pas directement `SIGTERM` (`docker stop` attend 10 s puis tue) | `CMD ["node", "src/server.js"]` |
| *(pas de `USER`)* | le processus tourne en **root** | une faille dans l'application donne les droits root dans le conteneur | `USER node` (utilisateur fourni par l'image) |
| *(pas de `.dockerignore`)* | `node_modules` local, `.git`, `.env` partent dans le contexte de build | build lent, risque de copier des secrets ou des modules compilés pour une autre plateforme | créer `.dockerignore` |
| `ENV APP_ENV=production` | valeur d'environnement figée dans l'image | la même image ne peut pas servir en local/test | fournir `APP_ENV` au lancement (accepté si laissé, mais à discuter) |

### Dockerfile corrigé

```dockerfile
# Image de base précise, légère et maintenue (jamais :latest)
FROM docker.io/library/node:20-alpine

# Dossier de travail dédié (sinon tout est copié à la racine /)
WORKDIR /app

# Variables non sensibles uniquement ; DATABASE_URL est fournie au lancement (-e / --env-file)
ENV NODE_ENV=production \
    PORT=3000

# 1) Dépendances d'abord : cette couche reste en cache tant que package*.json ne change pas
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# 2) Code ensuite (change souvent), avec le bon propriétaire
COPY --chown=node:node src/ ./src/

# Ne pas tourner en root : l'image node fournit l'utilisateur « node »
USER node

# Le port réellement écouté par l'application
EXPOSE 3000

# Vérifie que l'API répond (wget est présent dans l'image alpine)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# Forme « exec » (tableau JSON) : node reçoit directement les signaux (docker stop)
CMD ["node", "src/server.js"]
```

### `.dockerignore`

```text
node_modules
npm-debug.log*
.git
.gitignore
.env
.env.*
Dockerfile
.dockerignore
*.md
tests
coverage
```

### Vérification

```bash
docker build -t taskflow-mini:ok .
docker run -d --name mini-ok -p 3000:3000 -e APP_VERSION=1.0.0 taskflow-mini:ok
curl http://localhost:3000/health          # {"status":"ok","version":"1.0.0","env":"local"}
docker exec mini-ok whoami                  # node
docker exec mini-ok ls node_modules/nodemon # No such file or directory (devDependency non installée)
docker images taskflow-mini                 # ok ≈ 140 Mo, casse ≈ 1,3 Go
```

Après modification de `src/server.js`, le build affiche `CACHED` (BuildKit) ou `Using cache` sur `COPY package*.json` et `RUN npm ci` : seule la dernière couche `COPY src/` est reconstruite.

---

## Exercice 2.3 — Quiz

| Q | Réponse | Explication |
|---|---|---|
| 1 | **B** | L'image est le modèle (en lecture seule), on en crée autant de conteneurs (instances) qu'on veut. |
| 2 | **C** | Pas de noyau embarqué ni d'hyperviseur : un conteneur est un processus isolé (namespaces, cgroups) qui partage le noyau de l'hôte. |
| 3 | **B** | `-p 8080:80` : port 8080 de la machine → port 80 du conteneur. |
| 4 | **B** | Sans volume, les données sont dans la couche inscriptible du conteneur, supprimée avec lui. L'image n'est jamais modifiée. |
| 5 | **B** | `docker ps` ne montre que les conteneurs en cours d'exécution ; `-a` (*all*) montre aussi les arrêtés. |
| 6 | **B** | `exec` exécute une commande dans un conteneur **déjà démarré** ; `-it` = interactif + terminal. |
| 7 | **B** | Chaque instruction crée une couche mise en cache ; si `package*.json` n'a pas changé, `npm ci` n'est pas relancé. |
| 8 | **C** | Sur un réseau bridge personnalisé, Docker fournit un DNS qui résout les noms de conteneurs. `localhost` désignerait le conteneur `api` lui-même. |
| 9 | **B et C** | Un secret ne va ni dans l'image (A : lisible par `docker image inspect`) ni dans un fichier versionné (D). On l'injecte au lancement, depuis un `.env` ignoré par Git. |
| 10 | **B** | Tag précis = build reproductible ; Alpine ≈ 140 Mo contre plus d'1 Go pour l'image Debian complète. |

---

## Exercice 2.4 — Volume et réseau

```bash
# Partie A : la dernière commande affiche « Did not find any relations. » → table perdue

# Partie B
docker network create taskflow-net
docker volume create taskflow-pgdata

docker run -d --name taskflow-db \
  --network taskflow-net \
  -v taskflow-pgdata:/var/lib/postgresql/data \
  -e POSTGRES_USER=taskflow \
  -e POSTGRES_PASSWORD=taskflow \
  -e POSTGRES_DB=taskflow \
  -p 5432:5432 \
  docker.io/library/postgres:16-alpine

docker logs taskflow-db | tail -2     # database system is ready to accept connections
# … création de la table et INSERT (énoncé, étape 5) …

docker rm -f taskflow-db
docker volume ls                       # taskflow-pgdata est toujours là
# relancer la même commande docker run …
docker exec taskflow-db psql -U taskflow -d taskflow -c "SELECT id, title, done FROM tasks;"   # 2 lignes

docker run --rm --network taskflow-net -e PGPASSWORD=taskflow \
  docker.io/library/postgres:16-alpine \
  psql -h taskflow-db -U taskflow -d taskflow -c "SELECT count(*) FROM tasks;"                # 2

# Nettoyage
docker rm -f taskflow-db
docker volume rm taskflow-pgdata
docker network rm taskflow-net
```

- Étape 9 : sans `--network taskflow-net`, le conteneur est sur le réseau par défaut, qui ne connaît pas le nom `taskflow-db` : `could not translate host name "taskflow-db" to address`. La résolution par nom ne fonctionne qu'entre conteneurs d'un **même réseau personnalisé**.
- Question de réflexion : `postgres://taskflow:taskflow@taskflow-db:5432/taskflow`. Dans le conteneur de l'API, `localhost` désigne **le conteneur de l'API lui-même**, où aucun Postgres n'écoute. (Avec Compose, ce sera le nom du service : `db`.)
