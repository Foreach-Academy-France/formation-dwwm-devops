# Jour 4 — Solutions des exercices guidés

> À ouvrir **après** avoir cherché (et utilisé les indices).

---

## Exercice 4.1 — Configuration Nginx du proxy

### Les 6 problèmes

| Ligne (fichier fourni) | Problème | Conséquence | Correction |
|---|---|---|---|
| `ssl_protocols TLSv1.2 TLSv1.3` | `;` manquant | `nginx -t` échoue : `directive "ssl_protocols" is not terminated by ";"` ; le proxy ne démarre pas | ajouter `;` |
| `ssl_certificate /etc/ssl/certs/taskflow.crt;` | mauvais chemin : les certificats sont montés dans `/etc/nginx/certs/` | `cannot load certificate … No such file or directory` ; le proxy ne démarre pas | `/etc/nginx/certs/taskflow.crt` |
| `proxy_pass http://127.0.0.1:8080;` (deux fois) | dans un conteneur, `127.0.0.1` = **le conteneur proxy lui-même** ; et le front écoute sur **80** dans le réseau de la stack (8080 était le port publié en développement) | **502 Bad Gateway** : `connect() failed (111: Connection refused) … upstream: "http://127.0.0.1:8080/"` | `proxy_pass http://front:80;` (nom du service Compose) |
| bloc `listen 80` | sert le site en clair au lieu de rediriger | le site reste accessible en HTTP non chiffré | `return 301 https://$host$request_uri;` |
| bloc `listen 443` sans `server_name` | Nginx ne sait pas à quel nom de domaine ce bloc répond (dans les logs : `server: ,`) | fonctionne par hasard tant qu'il n'y a qu'un site ; mauvais aiguillage dès qu'on en ajoute un | `server_name taskflow.localhost;` |
| `location /` : seul `Host` est transmis | pas de `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto` | l'application ne voit que l'IP du proxy et croit être en HTTP (logs faux, liens/cookies `secure` incorrects) | ajouter les trois en-têtes |

### Configuration corrigée (`deploy/nginx/taskflow.conf`)

```nginx
# ---------- Port 80 (HTTP) : tout est redirigé vers HTTPS ---------------------
server {
    listen 80;
    server_name taskflow.localhost;

    # 301 = redirection permanente vers la même adresse en https
    return 301 https://$host$request_uri;
}

# ---------- Port 443 (HTTPS) : le vrai site -----------------------------------
server {
    listen 443 ssl;
    server_name taskflow.localhost;

    # Certificat et clé montés depuis ~/taskflow-prod/certs/ (générés par gen-cert.sh)
    ssl_certificate     /etc/nginx/certs/taskflow.crt;
    ssl_certificate_key /etc/nginx/certs/taskflow.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    location / {
        # « front » = nom du service Compose, résolu par le DNS du réseau de la stack.
        # (127.0.0.1 désignerait le conteneur proxy lui-même !)
        proxy_pass http://front:80;

        # Transmettre au front/à l'API les informations sur le client réel
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Déroulé observé dans le labo

1. `docker compose ps` : `proxy` est `Exited (1)`. Logs : `directive "ssl_protocols" is not terminated by ";"`.
2. Après le `;` : `cannot load certificate "/etc/ssl/certs/taskflow.crt"`.
3. Après le chemin : `test is successful`, le proxy démarre… mais `curl` renvoie **502** et le log d'erreur montre `upstream: "http://127.0.0.1:8080/"`.
4. Après `proxy_pass http://front:80` + redirection + `server_name` + en-têtes : `301` sur le port HTTP, page « Welcome to nginx! » en HTTPS.

**Réflexion :** un seul point d'entrée = une seule porte à surveiller et à sécuriser (TLS, en-têtes, limites) ; la base et l'API ne sont jamais exposées directement (pas d'attaque par force brute sur 5432, pas de contournement du HTTPS en appelant `:3000` en clair) ; on peut changer l'organisation interne sans toucher à ce que voit l'extérieur.

---

## Exercice 4.2 — Logs d'incident

1. **Symptôme** : première erreur à **09:41:27** (`POST /api/tasks` → 500). Échouent : les écritures (`POST`, `PATCH`) dès 09:41, puis **toutes** les routes `/api` à partir de 09:48 ; `/health` passe à **503** à 09:48. La page d'accueil (`GET /` → 200) fonctionne car ce sont des fichiers statiques servis par le conteneur `front`, sans base de données.
2. **Proxy** : `nginx-error.log` ne contient rien de lié à l'incident (un handshake TLS raté à 3 h, un rechargement de config à 7 h 55, sans erreur). Aucune 502 dans les accès : le proxy et le front fonctionnent, **le problème est derrière**.
3. **Conteneurs** : `db` est en `Restarting (1)` (il s'arrête avec le code 1 et Docker le relance en boucle) ; `api` est `(unhealthy)` car son healthcheck `/health` échoue (base down).
4. **API** : première erreur à 07:41:27 UTC : `could not extend file "base/16384/16390": No space left on device` (code `53100`). Évolution : erreurs d'**écriture** (07:41–07:42), puis `terminating connection because of crash of another server process` (07:46:58, la base plante), puis `ECONNREFUSED 172.19.0.2:5432` (07:48, plus personne n'écoute).
5. **Base** : `PANIC: could not write to file "pg_wal/xlogtemp.27": No space left on device` (07:46:58 UTC) : Postgres ne peut plus écrire son journal (WAL) et s'arrête pour protéger les données. Il ne redémarre pas car il doit écrire `postmaster.pid` au démarrage, et le disque est **toujours plein**.
6. **Système** : la partition `/` est pleine à **100 %** (62 Go). `~/taskflow-prod/backups` occupe **53 Go** : **1 056** dumps SQL non compressés de ~52 Mo, un toutes les **15 minutes** depuis le **11 octobre** (cron « pour tester », jamais remis à une fois par nuit). `backup.sh` n'a **aucune rotation** (pas de suppression des anciens fichiers), pas de compression, pas de `set -euo pipefail` (il crée des fichiers tronqués ou vides — 21 Mo à 09:30, 0 octet à 09:45 — sans échouer).
7. **Chaîne causale** :
   - un cron de test lance `backup.sh` toutes les 15 min depuis 11 jours ;
   - `backup.sh` ne supprime jamais les anciens dumps et ne les compresse pas ;
   - le disque du poste se remplit (53 Go de sauvegardes) jusqu'à 100 % vers 09:30 ;
   - Postgres ne peut plus écrire : les insertions et mises à jour échouent (500), puis la base plante (PANIC) et ne peut plus redémarrer ;
   - l'API ne joint plus la base : toutes les routes `/api` renvoient 500 et `/health` renvoie 503 ;
   - Uptime Kuma détecte le 503 et alerte.
8. **Remédiation immédiate** :
   ```bash
   cd ~/taskflow-prod
   crontab -e                                   # remettre : 0 3 * * * …/backup.sh (une fois par nuit)
   find backups -name 'taskflow-*.sql' -size -1M -print -delete          # fichiers vides ou presque
   rm backups/taskflow-20261022-093001.sql                               # dump tronqué de 09:30 (21 Mo)
   gzip backups/taskflow-202610{21,22}-*.sql                             # garder les 2 derniers jours, compressés
   find backups -name 'taskflow-*.sql' -mtime +1 -print -delete          # supprimer les dumps bruts plus anciens
   df -h /                                      # vérifier qu'il y a de nouveau de la place
   docker compose -p taskflow-prod restart db
   docker compose -p taskflow-prod ps           # db healthy, puis api healthy
   curl -fsk https://taskflow.localhost/health  # {"status":"ok","db":"up",...}
   ```
   puis créer une tâche dans l'interface pour vérifier l'écriture.

   **Actions durables** (au moins trois) :
   - `backup.sh` avec **rotation** (`find … -mtime +7 -delete`), **compression** (`| gzip`), `set -euo pipefail` et suppression des fichiers incomplets (c'est le `backup.sh` de la solution du fil rouge) ;
   - sauvegardes **hors** de la machine de production (autre disque, stockage objet) : une sauvegarde sur le même disque ne protège pas d'une panne de disque ;
   - **surveiller l'espace disque** (alerte à 80 %) en plus de `/health` ;
   - **tester la restauration** régulièrement et documenter la planification cron dans `docs/DEPLOIEMENT.md` ;
   - revue : un réglage « pour tester » doit avoir une date de fin ou un ticket.
9. **Post-mortem (exemple)** :
   > **Résumé** : TaskFlow indisponible en écriture puis totalement (API) le 22/10. **Impact** : 09:41–10:05 (24 min), impossible de créer/modifier des tâches, puis de les lister ; aucune perte de données. **Chronologie** : 09:30 disque plein ; 09:41 premières erreurs 500 ; 09:47 crash de Postgres ; 09:48 `/health` en 503 ; 09:50 alerte Uptime Kuma ; 09:58 cause identifiée (`df -h`) ; 10:03 espace libéré, base relancée ; 10:05 service rétabli. **Cause racine** : sauvegardes toutes les 15 min sans rotation depuis le 11/10. **Actions** : rotation + compression dans `backup.sh` (Alice, 23/10), alerte disque à 80 % (Karim, 24/10), sauvegardes hors machine (à planifier), test de restauration mensuel.

---

## Exercice 4.3 — Checklist de mise en production

### Résultat de la revue

| # | Statut | Ligne(s) en cause | Risque concret |
|---|---|---|---|
| C1 | ❌ | `taskflow-api:latest`, `taskflow-front:latest` | impossible de savoir quelle version tourne, rollback impossible, un `pull` peut changer la prod sans le vouloir |
| C2 | ❌ | `image: docker.io/library/postgres` (= `latest`), `nginx:latest` | une nouvelle version majeure de Postgres (17, 18…) **refuse** de démarrer sur les données d'une version 16 |
| C3 | ❌ | `POSTGRES_PASSWORD: Taskflow2026!` et `DATABASE_URL` en clair dans le compose ; `.env` commité | toute personne ayant accès au dépôt (ou à son historique) a le mot de passe de la base et un jeton GitHub |
| C4 | ❌ | `env-du-collegue.txt` (le `.env` commité) | jeton GitHub et mot de passe compromis |
| C5 | ❌ | `ports:` sur `db` (5432), `api` (3000), `front` (8080) | base et API exposées directement sur le réseau, HTTPS contourné |
| C6 | ❌ | aucun volume pour `db` ; `docker compose down -v` dans `deploy.sh` | **chaque déploiement efface toutes les tâches** |
| C7 | ❌ | aucun `restart`, aucun `healthcheck`, `depends_on` simple | après un crash ou un redémarrage du poste, rien ne repart ; l'API démarre avant que la base soit prête |
| C8 | ❌ | `APP_ENV: development` ; volumes du proxy sans `:ro` | traces d'erreur détaillées affichées aux utilisateurs ; un conteneur compromis peut modifier sa config |
| C9 | ❌ | `deploy.sh` : pas de `set -euo pipefail`, pas de `-f compose.prod.yaml`, pas de tag | `docker compose` cherche `compose.yaml` (absent) ; les erreurs sont ignorées et le script affiche quand même « Déploiement terminé ! » |
| C10 | ❌ | pas de sauvegarde avant, pas de smoke test après | aucune possibilité de revenir en arrière sur les données ; un déploiement cassé passe pour un succès |
| C11 | ➖ | `docs/DEPLOIEMENT.md` n'est pas dans la PR | à demander dans la revue |

**Bloquants** : C1, C3, C4, C5, C6, C9, C10 (risque de perte de données, de fuite de secrets ou de prod cassée sans le savoir). C2, C7, C8 sont aussi à corriger avant la fusion (C2 peut empêcher la base de démarrer), mais sont moins urgents. C11 : à demander.

### Exemple de commentaire de revue

> Merci pour cette PR, c'est une super base pour la prod ! Quelques points à corriger avant de fusionner :
> 1. **Données** : `deploy.sh` fait `down -v` et `db` n'a pas de volume → chaque déploiement efface toutes les tâches. Je propose un volume `pgdata` et `up -d` sans `down`.
> 2. **Secrets** : le `.env` est dans le commit (mot de passe + jeton GitHub). Il faut le retirer, l'ajouter au `.gitignore` et surtout **changer** ces deux secrets. Dans le compose, on peut lire `${POSTGRES_PASSWORD}` depuis le `.env` du dossier `~/taskflow-prod`.
> 3. **Ports** : seul `proxy` devrait publier 80/443 ; on peut retirer les `ports:` de `db`, `api` et `front`.
> 4. **Versions** : `${IMAGE_TAG}` au lieu de `latest` pour nos images, et `postgres:16-alpine` / `nginx:1.27-alpine`.
> 5. **deploy.sh** : `set -euo pipefail`, `-f compose.prod.yaml`, une sauvegarde avant et un `curl -f …/health` après.
> Je peux t'aider à faire les modifs si tu veux, dis-moi !

### Actions sur le secret commité (C4), dans l'ordre

1. **Révoquer** immédiatement le jeton GitHub (*Settings → Developer settings → Personal access tokens*) et en créer un nouveau si besoin (pour ghcr.io, préférer `GITHUB_TOKEN` dans le workflow).
2. **Changer** le mot de passe de la base (`ALTER USER taskflow WITH PASSWORD '…';` dans la base, puis mise à jour du `.env` de `~/taskflow-prod` et redémarrage de l'API).
3. Retirer le fichier du dépôt (`git rm --cached .env`), ajouter `.env` au `.gitignore`, fournir un `.env.example` sans vraies valeurs.
4. Comme le secret reste dans l'historique : le considérer définitivement compromis (déjà fait aux étapes 1 et 2) ; éventuellement nettoyer l'historique (`git filter-repo`) si la PR n'est pas encore fusionnée, en coordination avec l'équipe.
5. Activer la **protection contre les fuites de secrets** de GitHub (*secret scanning / push protection*).

### `compose.prod.yaml` corrigé

```yaml
name: taskflow-prod

services:
  db:
    image: docker.io/library/postgres:16-alpine
    environment:
      POSTGRES_USER: taskflow
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?POSTGRES_PASSWORD manquant dans .env}
      POSTGRES_DB: taskflow
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskflow -d taskflow"]
      interval: 10s
      timeout: 3s
      retries: 10
    restart: unless-stopped

  api:
    image: ghcr.io/${GHCR_OWNER:?GHCR_OWNER manquant}/taskflow-api:${IMAGE_TAG:?IMAGE_TAG manquant}
    environment:
      PORT: 3000
      DATABASE_URL: postgres://taskflow:${POSTGRES_PASSWORD}@db:5432/taskflow
      APP_ENV: production
      APP_VERSION: ${IMAGE_TAG}
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O /dev/null http://127.0.0.1:3000/health || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3
      start_period: 10s
    restart: unless-stopped

  front:
    image: ghcr.io/${GHCR_OWNER}/taskflow-front:${IMAGE_TAG}
    depends_on:
      api:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O /dev/null http://127.0.0.1/ || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 3
    restart: unless-stopped

  proxy:
    image: docker.io/library/nginx:1.27-alpine
    ports:
      - "${HTTP_PORT:-80}:80"
      - "${HTTPS_PORT:-443}:443"
    volumes:
      - ./nginx/taskflow.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      front:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "nginx", "-t", "-q"]
      interval: 30s
      timeout: 3s
      retries: 3
    restart: unless-stopped

volumes:
  pgdata:
```

### `deploy.sh` corrigé

```bash
#!/usr/bin/env bash
# deploy.sh — usage : ./deploy.sh <tag>   (tag = SHA court de l'image à déployer)
set -euo pipefail

TAG="${1:?Usage : ./deploy.sh <tag>}"
cd "$(dirname "$0")"                       # ~/taskflow-prod (DEPLOY_DIR)
COMPOSE=(docker compose -f compose.prod.yaml)
SMOKE_URL="${SMOKE_URL:-https://localhost:${HTTPS_PORT:-443}/health}"

echo "==> Sauvegarde de la base avant déploiement"
if "${COMPOSE[@]}" ps --status running --services | grep -qx db; then
  ./backup.sh
fi

echo "==> Déploiement du tag $TAG"
export IMAGE_TAG="$TAG"
"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d --wait               # attend que les healthchecks soient verts

echo "==> Smoke test : $SMOKE_URL"
curl -fsk --retry 10 --retry-delay 3 --retry-all-errors "$SMOKE_URL"
echo

echo "==> Nettoyage des anciennes images"
docker image prune -f

echo "==> Déploiement de $TAG réussi"
```

Le job `deploy` du workflow lance `SMOKE_URL=https://host.docker.internal:${HTTPS_PORT}/health ./deploy.sh <sha>` (depuis le conteneur du runner, `localhost` désignerait le runner lui-même). Le **rollback** (C11) consiste à relancer `./deploy.sh <tag précédent>` ou le workflow `Release` en `workflow_dispatch` avec ce tag ; à documenter dans `docs/DEPLOIEMENT.md`.
