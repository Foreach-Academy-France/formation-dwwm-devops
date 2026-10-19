# Exercice 2.2 — Le Dockerfile à corriger

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S3 — Bloc 3.3 (Dockerfile, ordre des instructions et cache, `.dockerignore`) |
| **Prérequis** | Docker fonctionnel (`docker run --rm docker.io/library/hello-world`) ; démo `demo-dockerfile` vue |
| **Fichiers fournis** | dossier [`dockerfile-a-corriger/`](dockerfile-a-corriger/) : `Dockerfile` (buggé), `package.json`, `package-lock.json`, `src/server.js` |

## Objectif

Un collègue a écrit le Dockerfile d'une mini API TaskFlow (Node + Express, écoute sur le port **3000**, route `GET /health`). L'image se construit… mais le conteneur s'arrête aussitôt, et le fichier accumule les mauvaises pratiques. Vous devez **trouver au moins 7 problèmes** et livrer un Dockerfile corrigé **et** un `.dockerignore`.

## Le Dockerfile fourni

```dockerfile
FROM docker.io/library/node:latest

COPY . .

RUN npm install

ENV DATABASE_URL=postgres://taskflow:SuperSecret2026@db:5432/taskflow
ENV APP_ENV=production

EXPOSE 8080

CMD node src/index.js
```

## Consignes

1. Placez-vous dans le dossier : `cd dockerfile-a-corriger`.
2. Construisez l'image telle quelle et notez sa taille :
   ```bash
   docker build -t taskflow-mini:casse .
   docker images taskflow-mini
   ```
3. Lancez le conteneur et observez :
   ```bash
   docker run -d --name mini-casse -p 3000:8080 taskflow-mini:casse
   docker ps -a --filter name=mini-casse
   docker logs mini-casse
   ```
   Que dit le message d'erreur ? **Dans quel dossier** Node cherche-t-il le fichier ?
4. Inspectez l'image, comme le ferait n'importe qui qui la télécharge :
   ```bash
   docker image inspect taskflow-mini:casse --format '{{.Config.Env}}'
   docker run --rm taskflow-mini:casse sh -c 'pwd; ls; whoami; node --version'
   ```
5. Lisez `src/server.js` et `package.json`. Puis remplissez ce tableau (au moins 7 lignes) :

   | Ligne du Dockerfile | Problème | Conséquence | Correction |
   |---|---|---|---|
   | `FROM …:latest` | … | … | … |

6. Écrivez votre Dockerfile corrigé (remplacez le fichier) et créez un `.dockerignore`.
7. Reconstruisez sous le tag `taskflow-mini:ok`, lancez le conteneur en publiant le bon port, et testez :
   ```bash
   docker build -t taskflow-mini:ok .
   docker run -d --name mini-ok -p 3000:3000 -e APP_VERSION=1.0.0 taskflow-mini:ok
   curl http://localhost:3000/health
   ```
8. Modifiez une ligne de `src/server.js` (par exemple le message de démarrage) et reconstruisez : l'étape `npm ci` doit indiquer `CACHED` (ou `Using cache`).
9. Comparez les tailles des deux images, puis nettoyez :
   ```bash
   docker rm -f mini-casse mini-ok
   docker rmi taskflow-mini:casse taskflow-mini:ok
   ```

## Résultat attendu

```text
$ curl http://localhost:3000/health
{"status":"ok","version":"1.0.0","env":"local"}

$ docker exec mini-ok whoami
node

$ docker images taskflow-mini
REPOSITORY      TAG     SIZE
taskflow-mini   ok      ~140 MB
taskflow-mini   casse   ~1.3 GB
```

## Indices

<details>
<summary>Indice 1 — par où commencer</summary>

Le message `Cannot find module '/src/index.js'` contient **deux** problèmes : le nom du fichier (comparez avec `package.json` → `"main"` et `"start"`) et le chemin `/src` (où les fichiers ont-ils été copiés, faute de `WORKDIR` ?).
</details>

<details>
<summary>Indice 2 — la liste des thèmes à vérifier</summary>

Version de l'image de base · dossier de travail · ordre des `COPY` et cache · `npm install` vs `npm ci --omit=dev` · secret dans l'image · port réel de l'application · forme de `CMD` · utilisateur qui exécute le processus · fichiers envoyés au build (`node_modules`, `.git`, `.env`…).
</details>

<details>
<summary>Indice 3 — squelette du Dockerfile corrigé</summary>

```dockerfile
FROM docker.io/library/node:20-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=3000
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY ... ./src/
USER ...
EXPOSE ...
CMD ["node", "..."]
```
</details>

## Pour aller plus loin

Ajoutez une instruction `HEALTHCHECK` qui interroge `/health`, puis observez la colonne `STATUS` de `docker ps` (`healthy` / `unhealthy`).

> Avec **Podman** à la place de Docker, `HEALTHCHECK` est ignoré au format d'image par défaut : construisez avec `podman build --format docker -t taskflow-mini:ok .`.
