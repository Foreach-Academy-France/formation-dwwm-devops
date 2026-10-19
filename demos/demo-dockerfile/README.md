# Démo — Dockerfile naïf vs optimisé

| | |
|---|---|
| **Jour / bloc** | J2 après-midi — Bloc 3.3 « Dockerfile » (juste avant l'Étape 1 du fil rouge) |
| **Durée** | 25 min |
| **Prérequis** | Docker ou Podman, `curl`, port **3001** libre (sinon `DEMO_PORT=…`) ; images `node:20` et `node:20-alpine` pré-téléchargées (≈ 1,2 Go au total) |
| **Ce qu'on montre** | `FROM`, `WORKDIR`, `COPY`, `RUN`, `ENV`, `EXPOSE`, `USER`, `HEALTHCHECK`, `CMD` ; ordre des instructions et cache ; `.dockerignore` ; taille d'image ; secrets embarqués par erreur ; root vs non-root ; forme exec et arrêt propre |

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `app/` | mini API Express (port 3000, `GET /` et `GET /health`, logs JSON) : même forme que l'API TaskFlow |
| `app/package-lock.json` | lockfile réel (nécessaire à `npm ci`) |
| `Dockerfile.naif` | version « qui marche » mais avec 6 mauvaises pratiques commentées ❌ |
| `Dockerfile` | version optimisée commentée ✅ (base de `api/Dockerfile` du fil rouge) |
| `.dockerignore` | exclut `node_modules`, `.env`, `.git`, gros fichiers… |
| `demo.sh` | déroulé automatique rejouable |

## Lancer

```bash
docker pull docker.io/library/node:20 && docker pull docker.io/library/node:20-alpine   # avant le cours
bash demos/demo-dockerfile/demo.sh
KEEP_IMAGES=1 bash demos/demo-dockerfile/demo.sh   # garder les images pour y revenir
DEMO_AUTO=1 bash demos/demo-dockerfile/demo.sh     # test sans pause
```

Le script copie l'application dans un dossier temporaire, y ajoute **un faux `.env` avec un mot de passe et une « vidéo » de 30 Mo** (ce qui traîne dans un vrai projet), construit `demo-dockerfile:naif` (sans `.dockerignore`) puis `demo-dockerfile:optimise`, et nettoie tout à la fin. Sous Podman, il ajoute `--format docker` pour que `HEALTHCHECK` soit pris en compte.

## Déroulé minuté

| Min | Étape | Dire | Taper / montrer | Question à poser à la salle |
|---|---|---|---|---|
| 0-3 | 1 | « Un Dockerfile est une **recette** : chaque instruction produit une **couche**. » | `Dockerfile.naif` lu ligne à ligne | « D'après vous, qu'est-ce qui pose problème dans ce fichier ? » (noter les réponses au tableau) |
| 3-5 | 2 | « Il marche. Mais regardons ce qu'il contient. » | Durée du build | — |
| 5-8 | 3 | « Tout le dossier est dans l'image : le `.env`, la vidéo, nodemon… et on est root. » | `whoami` → `root`, `cat .env` affiche le mot de passe | « Si je pousse cette image sur un registre public, que se passe-t-il ? » |
| 8-12 | 4 | Lire le `Dockerfile` optimisé : image Alpine fixée, dépendances d'abord, `npm ci --omit=dev`, code ensuite, `USER node`, `HEALTHCHECK`, forme exec. Puis le `.dockerignore`. | Les deux fichiers | « Pourquoi copier `package*.json` **avant** `src/` ? » |
| 12-14 | 5 | « Même application, image construite proprement. » | `whoami` → `node`, pas de nodemon, pas de `.env` | « Où mettra-t-on le `DATABASE_URL` alors ? » (`-e` / `--env-file` / Compose, bloc 3.4) |
| 14-16 | 6 | « Comparons les tailles. » | ≈ 1,1 Go contre ≈ 140 Mo | « Quel impact sur un déploiement, sur le CI, sur la facture ? » |
| 16-20 | 7 | « On change UNE ligne de code. » | Naïf : `npm install` relancé ; optimisé : `Using cache` jusqu'à `npm ci` | « Quelle règle retenir sur l'ordre des instructions ? » (du moins au plus souvent modifié) |
| 20-22 | 8 | « `docker history` montre les couches et leur poids. » | Couche `npm ci` ≈ 3 Mo, couche `src` ≈ 4 ko | « Quelle couche est reconstruite à chaque commit ? » |
| 22-25 | 9 | « On lance : `/health` répond, Docker voit l'état **healthy**, et `docker stop` est instantané. » | `curl`, `docker logs` (JSON), `inspect` → `healthy`, stop en ≈ 1 s | « À quoi servira ce healthcheck dans Compose ? » (`depends_on: condition: service_healthy`, J3) |

## Aller plus loin (si le temps le permet)

- **Multi-stage** : montrer que le `front/Dockerfile` du fil rouge construit avec `node:20-alpine` puis ne garde que `dist/` dans `nginx:1.27-alpine` (image finale ≈ 50 Mo, sans Node).
- `docker run --rm demo-dockerfile:optimise env` : `NODE_ENV=production` est là, mais **aucun** secret.

## Pièges à anticiper

- Premier téléchargement de `node:20` très long sur un réseau lent : pré-télécharger.
- Sous Podman sans `--format docker`, l'avertissement `HEALTHCHECK is not supported for OCI image format` apparaît et le statut reste vide.
- Les temps de build sont courts ici (3 dépendances). Sur l'API TaskFlow, la différence de cache est bien plus visible : le dire.
- Sans le gestionnaire `SIGTERM` de `server.js`, Node en PID 1 ignore le signal et `docker stop` attend 10 s : bon sujet de question.
