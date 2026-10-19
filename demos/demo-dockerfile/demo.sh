#!/usr/bin/env bash
# =============================================================================
# Démo J2 — Bloc 3.3 : Dockerfile naïf vs optimisé (taille, cache, sécurité)
#   Usage   : bash demo.sh             (pauses entre les étapes)
#             DEMO_AUTO=1 bash demo.sh  (sans pause, pour tester)
#             DEMO_PORT=3005 bash demo.sh  (port local de l'API, 3001 par défaut)
#   Effet   : copie l'app dans un dossier temporaire, construit 2 images
#             demo-dockerfile:naif / demo-dockerfile:optimise, les supprime à la fin
#             (KEEP_IMAGES=1 pour les garder). Les images de base restent en cache.
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
DEMO_PORT="${DEMO_PORT:-3001}"
KEEP_IMAGES="${KEEP_IMAGES:-0}"
DOCKER="${DOCKER:-docker}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d -t demo-dockerfile-XXXXXX)"

# Podman construit au format OCI par défaut, qui ignore HEALTHCHECK : on force le format Docker
BUILD_OPTS=()
if "$DOCKER" version 2>/dev/null | grep -qi podman; then BUILD_OPTS=(--format docker); fi

cleanup() {
  "$DOCKER" rm -f demo-dockerfile-api >/dev/null 2>&1 || true
  if [[ "$KEEP_IMAGES" != "1" ]]; then
    "$DOCKER" rmi -f demo-dockerfile:naif demo-dockerfile:optimise >/dev/null 2>&1 || true
  fi
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Conteneur, images demo-dockerfile:* et dossier temporaire supprimés"
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }
chrono() {   # chrono "libellé" commande… : affiche la durée
  local label="$1"; shift
  local debut=$SECONDS
  run "$@"
  echo -e "\033[1;33m⏱  $label : $((SECONDS - debut)) s\033[0m"
}

# Deux copies de l'app : « naif » SANS .dockerignore, « optimise » AVEC
for variante in naif optimise; do
  mkdir -p "$WORKDIR/$variante/notes"
  cp -r "$HERE/app/." "$WORKDIR/$variante/"
  # Des fichiers qui traînent dans tout projet réel :
  echo "DATABASE_URL=postgres://taskflow:MotDePasseSecret@db:5432/taskflow" > "$WORKDIR/$variante/.env"
  head -c 30000000 /dev/zero > "$WORKDIR/$variante/notes/capture-ecran.mp4"   # 30 Mo
done
cp "$HERE/Dockerfile.naif" "$WORKDIR/naif/Dockerfile"
cp "$HERE/Dockerfile" "$HERE/.dockerignore" "$WORKDIR/optimise/"

etape "1. Le projet : une mini API Express (comme l'API TaskFlow)"
run "ls -la $WORKDIR/naif $WORKDIR/naif/src"
run "cat $WORKDIR/naif/Dockerfile"
pause

etape "2. Build de l'image NAÏVE"
chrono "build naïf (1er)" "$DOCKER build ${BUILD_OPTS[*]} -q -t demo-dockerfile:naif $WORKDIR/naif"
pause

etape "3. Ce qu'il y a dedans…"
run "$DOCKER run --rm demo-dockerfile:naif sh -c 'whoami; ls -a /app; cat /app/.env; du -sh /app/notes /app/node_modules'"
echo "→ root, le .env avec le mot de passe, la vidéo de 30 Mo, nodemon… tout est DANS l'image."
pause

etape "4. Le Dockerfile OPTIMISÉ et son .dockerignore"
run "cat $WORKDIR/optimise/Dockerfile"
run "cat $WORKDIR/optimise/.dockerignore"
pause

etape "5. Build de l'image OPTIMISÉE"
chrono "build optimisé (1er)" "$DOCKER build ${BUILD_OPTS[*]} -q -t demo-dockerfile:optimise $WORKDIR/optimise"
run "$DOCKER run --rm demo-dockerfile:optimise sh -c 'whoami; ls -a /app; ls /app/node_modules | grep -c . ; ls /app/node_modules | grep nodemon || echo \"pas de nodemon ✔\"'"
pause

etape "6. Comparer les tailles"
run "$DOCKER image ls --format '{{.Repository}}:{{.Tag}}  →  {{.Size}}' demo-dockerfile"
pause

etape "7. Le cache : on modifie UNE ligne de code et on reconstruit"
for variante in naif optimise; do
  sed -i "s/Bonjour depuis un conteneur !/Bonjour depuis un conteneur (v2) !/" "$WORKDIR/$variante/src/server.js"
done
chrono "rebuild naïf" "$DOCKER build ${BUILD_OPTS[*]} -t demo-dockerfile:naif $WORKDIR/naif 2>&1 | grep -E 'STEP|Using cache|added' || true"
chrono "rebuild optimisé" "$DOCKER build ${BUILD_OPTS[*]} -t demo-dockerfile:optimise $WORKDIR/optimise 2>&1 | grep -E 'STEP|Using cache|added' || true"
echo "→ Naïf : COPY . . a changé ⇒ npm install relancé. Optimisé : npm ci reste en cache (« Using cache »)."
pause

etape "8. Les couches de l'image optimisée"
run "$DOCKER history --format '{{.Size}}\t{{.CreatedBy}}' demo-dockerfile:optimise | sed -n '1,8p' | cut -c1-110"
pause

etape "9. On lance l'image optimisée"
run "$DOCKER run -d --name demo-dockerfile-api -p $DEMO_PORT:3000 -e APP_VERSION=demo demo-dockerfile:optimise"
for _ in $(seq 1 20); do curl -fsS "http://localhost:$DEMO_PORT/health" >/dev/null 2>&1 && break; sleep 0.5; done
run "curl -s http://localhost:$DEMO_PORT/health; echo"
run "curl -s http://localhost:$DEMO_PORT/; echo"
run "$DOCKER logs demo-dockerfile-api"
echo "(attente du premier healthcheck, ~10 s…)"
for _ in $(seq 1 30); do
  [[ "$("$DOCKER" inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' demo-dockerfile-api)" == "healthy" ]] && break
  sleep 1
done
run "$DOCKER inspect --format 'Santé : {{if .State.Health}}{{.State.Health.Status}}{{else}}(pas de healthcheck){{end}}' demo-dockerfile-api"
chrono "docker stop" "$DOCKER stop demo-dockerfile-api >/dev/null"
run "$DOCKER logs --tail 1 demo-dockerfile-api"
echo "→ Arrêt immédiat : forme exec (node reçoit SIGTERM) + gestionnaire SIGTERM dans server.js."
echo -e "\n✅ Fin de la démo : image plus petite, build plus rapide, pas de secret, pas de root."
