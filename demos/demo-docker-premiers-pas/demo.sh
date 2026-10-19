#!/usr/bin/env bash
# =============================================================================
# Démo J2 — Bloc 3.2 : premiers pas avec Docker (image vs conteneur, cycle de vie)
#   Usage   : bash demo.sh             (pauses entre les étapes)
#             DEMO_AUTO=1 bash demo.sh  (sans pause, pour tester)
#             DEMO_PORT=8090 bash demo.sh  (si le port 8081 est occupé)
#   Effet   : crée des conteneurs « demo-dpp-* », tous supprimés à la fin.
#             Les images téléchargées (hello-world, nginx, alpine) sont conservées.
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
DEMO_PORT="${DEMO_PORT:-8081}"
DOCKER="${DOCKER:-docker}"          # DOCKER=podman fonctionne aussi
NGINX_IMAGE="docker.io/library/nginx:1.27-alpine"
ALPINE_IMAGE="docker.io/library/alpine:3.21"
HELLO_IMAGE="docker.io/library/hello-world:latest"
WORKDIR="$(mktemp -d -t demo-dpp-XXXXXX)"

cleanup() {
  "$DOCKER" rm -f demo-dpp-web demo-dpp-web2 demo-dpp-hello demo-dpp-alpine >/dev/null 2>&1 || true
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Conteneurs demo-dpp-* et dossier temporaire supprimés"
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }
attendre_http() {   # attendre_http URL : réessaie pendant ~10 s
  for _ in $(seq 1 20); do curl -fsS "$1" >/dev/null 2>&1 && return 0; sleep 0.5; done
  echo "⚠ $1 ne répond pas" >&2; return 1
}

etape "1. Client, daemon, version"
run "$DOCKER version --format 'Client {{.Client.Version}} / Serveur {{.Server.Version}}' || $DOCKER --version"
pause

etape "2. Hello world : télécharger une image et lancer un conteneur"
run "$DOCKER run --name demo-dpp-hello $HELLO_IMAGE | sed -n '1,4p'"
run "$DOCKER ps -a --filter name=demo-dpp-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'"
echo "→ Le conteneur a fait son travail puis s'est ARRÊTÉ (Exited). Il existe toujours."
run "$DOCKER rm demo-dpp-hello"
pause

etape "3. Un serveur web en arrière-plan, port publié"
run "$DOCKER run -d --name demo-dpp-web -p $DEMO_PORT:80 $NGINX_IMAGE"
attendre_http "http://localhost:$DEMO_PORT"
run "$DOCKER ps --filter name=demo-dpp --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'"
run "curl -s http://localhost:$DEMO_PORT | grep -i '<title>'"
echo "→ Ouvrez http://localhost:$DEMO_PORT dans le navigateur."
pause

etape "4. Logs et exec : regarder dedans"
run "$DOCKER logs --tail 3 demo-dpp-web"
run "$DOCKER exec demo-dpp-web cat /etc/os-release | sed -n '1,2p'"
run "$DOCKER exec demo-dpp-web sh -c 'echo \"<h1>Modifié DANS le conteneur</h1>\" > /usr/share/nginx/html/index.html'"
run "curl -s http://localhost:$DEMO_PORT"
pause

etape "5. Une image, plusieurs conteneurs (classe → instances)"
run "$DOCKER run -d --name demo-dpp-web2 -p $((DEMO_PORT + 1)):80 $NGINX_IMAGE"
attendre_http "http://localhost:$((DEMO_PORT + 1))"
run "curl -s http://localhost:$((DEMO_PORT + 1)) | grep -i '<title>'"
echo "→ Le 2e conteneur n'a PAS la modification : chaque conteneur a sa propre couche inscriptible."
pause

etape "6. Les données d'un conteneur sont éphémères"
run "$DOCKER rm -f demo-dpp-web"
run "$DOCKER run -d --name demo-dpp-web -p $DEMO_PORT:80 $NGINX_IMAGE"
attendre_http "http://localhost:$DEMO_PORT"
run "curl -s http://localhost:$DEMO_PORT | grep -i '<title>'"
echo "→ Notre modification a disparu avec le conteneur. Solution : les volumes (bloc 3.4)."
pause

etape "7. Bind mount : servir un dossier de l'hôte"
mkdir -p "$WORKDIR/site"
echo "<h1>Servi depuis l'hôte : $WORKDIR/site</h1>" > "$WORKDIR/site/index.html"
run "$DOCKER rm -f demo-dpp-web2"
run "$DOCKER run -d --name demo-dpp-web2 -p $((DEMO_PORT + 1)):80 -v $WORKDIR/site:/usr/share/nginx/html:ro,Z $NGINX_IMAGE"
attendre_http "http://localhost:$((DEMO_PORT + 1))"
run "curl -s http://localhost:$((DEMO_PORT + 1))"
pause

etape "8. Conteneur interactif et jetable"
run "$DOCKER run --rm --name demo-dpp-alpine $ALPINE_IMAGE sh -c 'hostname; ps; uname -r'"
run "uname -r"
echo "→ Même noyau que l'hôte : un conteneur est un processus isolé, pas une VM."
pause

etape "9. Images, arrêt, suppression"
run "$DOCKER image ls --format '{{.Repository}}:{{.Tag}}  →  {{.Size}}' $HELLO_IMAGE"
run "$DOCKER image ls --format '{{.Repository}}:{{.Tag}}  →  {{.Size}}' $NGINX_IMAGE"
run "$DOCKER image ls --format '{{.Repository}}:{{.Tag}}  →  {{.Size}}' $ALPINE_IMAGE"
run "$DOCKER stop demo-dpp-web demo-dpp-web2"
run "$DOCKER ps -a --filter name=demo-dpp --format 'table {{.Names}}\t{{.Status}}'"
run "$DOCKER rm demo-dpp-web demo-dpp-web2"
echo -e "\n✅ Fin de la démo. Cycle de vie : run → ps → logs/exec → stop → rm."
