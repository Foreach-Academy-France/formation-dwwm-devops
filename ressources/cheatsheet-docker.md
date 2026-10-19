# Cheatsheet Docker et Docker Compose

> **Image** = la recette figée (comme une classe). **Conteneur** = une instance en cours d'exécution (comme un objet). **Registre** = l'endroit où l'on stocke les images (Docker Hub, ghcr.io).

## Images

| Commande | Effet |
|---|---|
| `docker pull nginx:1.27-alpine` | Télécharge une image |
| `docker images` | Liste les images locales |
| `docker build -t taskflow-api:dev ./api` | Construit une image depuis `./api/Dockerfile` |
| `docker tag taskflow-api:dev ghcr.io/moi/taskflow-api:1.0.0` | Ajoute un nom (tag) |
| `docker push ghcr.io/moi/taskflow-api:1.0.0` | Envoie vers le registre (après `docker login ghcr.io`) |
| `docker rmi image` / `docker image prune` | Supprime une image / les images orphelines |

## Conteneurs

| Commande | Effet |
|---|---|
| `docker run --rm hello-world` | Lance, affiche, supprime à la fin |
| `docker run -d --name web -p 8080:80 nginx:1.27-alpine` | En arrière-plan, port **hôte**:**conteneur** |
| `docker run -e POSTGRES_PASSWORD=secret postgres:16-alpine` | Variable d'environnement (`--env-file .env` pour un fichier) |
| `docker run -v pgdata:/var/lib/postgresql/data ...` | Volume nommé (données persistantes) |
| `docker run -v "$PWD":/app ...` | Bind mount (dossier de l'hôte) |
| `docker run --network monreseau ...` | Branche sur un réseau |
| `docker ps` / `docker ps -a` | Conteneurs actifs / tous |
| `docker logs -f --tail 50 web` | Suit les logs |
| `docker exec -it web sh` | Ouvre un shell dedans (`exit` pour sortir) |
| `docker stop web` / `docker start web` | Arrête / relance |
| `docker rm web` / `docker rm -f web` | Supprime (`-f` = même s'il tourne) |
| `docker inspect web` | Détails JSON (IP, volumes, santé) |
| `docker stats` | Consommation CPU/RAM en direct |

## Volumes et réseaux

| Commande | Effet |
|---|---|
| `docker volume create pgdata` / `docker volume ls` | Crée / liste |
| `docker volume rm pgdata` | Supprime (**perte des données**) |
| `docker network create taskflow` | Crée un réseau : les conteneurs s'y joignent **par leur nom** (`db`, `api`) |
| `docker system df` / `docker system prune` | Espace utilisé / nettoyage (conteneurs arrêtés, images inutilisées) |

## Dockerfile : instructions

```dockerfile
# Étape 1 : construire (multi-stage)
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./          # d'abord les dépendances : couche mise en cache
RUN npm ci
COPY . .
RUN npm run build

# Étape 2 : image finale légère
FROM nginx:1.27-alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/ || exit 1
```

| Instruction | Rôle |
|---|---|
| `FROM image:tag` | Image de départ (toujours un tag précis, pas `latest`) |
| `WORKDIR /app` | Dossier de travail |
| `COPY src dest` | Copie des fichiers de votre projet dans l'image |
| `RUN cmd` | Commande **au build** (installer, compiler) |
| `ENV CLE=valeur` | Variable d'environnement par défaut |
| `EXPOSE 3000` | Documentation du port (ne publie rien) |
| `USER node` | Ne pas tourner en root |
| `CMD ["node","src/server.js"]` | Commande **au démarrage** du conteneur |
| `HEALTHCHECK` | Test d'état de santé |

`.dockerignore` (indispensable) : `node_modules`, `.git`, `.env`, `dist`, `*.log`.
**Cache** : une instruction modifiée invalide toutes les suivantes. Mettez ce qui change rarement (dépendances) avant ce qui change souvent (code).

## Docker Compose v2 (`docker compose`, sans tiret)

```yaml
name: taskflow
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}      # lu dans .env
      POSTGRES_DB: taskflow
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskflow"]
      interval: 5s
      timeout: 3s
      retries: 10
  api:
    build: ./api
    environment:
      DATABASE_URL: postgres://taskflow:${POSTGRES_PASSWORD}@db:5432/taskflow   # « db » = nom du service
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
  front:
    build: ./front
    ports:
      - "8080:80"
volumes:
  pgdata:
```

| Commande | Effet |
|---|---|
| `docker compose up -d` | Crée et démarre (ajoutez `--build` pour reconstruire) |
| `docker compose ps` | État + santé des services |
| `docker compose logs -f api` | Logs d'un service (`--since 10m`, `--tail 100`) |
| `docker compose exec db psql -U taskflow` | Commande dans un service en cours |
| `docker compose run --rm api npm test` | Conteneur jetable |
| `docker compose pull` | Télécharge les nouvelles images |
| `docker compose config` | Affiche le fichier **résolu** (variables remplacées) : excellent pour déboguer |
| `docker compose restart api` | Redémarre un service |
| `docker compose down` | Arrête et supprime conteneurs + réseau (**garde** les volumes) |
| `docker compose down -v` | ... et supprime aussi les volumes (**données perdues**) |
| `docker compose -f compose.prod.yaml up -d` | Utiliser un autre fichier |

Variables : le fichier `.env` à côté du compose est lu automatiquement. `${VAR:-défaut}` donne une valeur par défaut. Ports `"HOTE:CONTENEUR"` : seul le côté hôte est visible depuis votre poste.

## Encadré : pièges fréquents

- **`localhost` dans un conteneur = le conteneur lui-même**, pas votre poste ni la BDD. Entre services Compose, utilisez le **nom du service** (`db`).
- **Volume oublié pour la BDD** : `docker rm` ou `down -v` = données perdues.
- **Secret dans l'image** (`ENV`, `COPY .env`) : il y reste pour toujours. Passez-le à l'exécution (`env_file`, `-e`) et ajoutez `.env` au `.dockerignore`.
- **Tag `latest`** : ne dit pas quelle version tourne. Taguez avec la version ou le SHA du commit.
- **`depends_on` sans `condition: service_healthy`** n'attend pas que la BDD soit prête.
- **Port déjà utilisé** (`address already in use`) : changer le côté hôte (`8081:80`).
- **Modification du code sans effet** : il faut reconstruire (`--build`).
- Indentation YAML : espaces uniquement (jamais de tabulation), 2 espaces par niveau.
- `docker compose` (v2) et non `docker-compose` (ancienne v1).
- Le conteneur s'arrête aussitôt ? `docker logs <nom>` donne la raison dans 90 % des cas.
