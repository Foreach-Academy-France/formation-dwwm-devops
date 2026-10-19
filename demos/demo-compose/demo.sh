#!/usr/bin/env bash
# =============================================================================
# Démo J3 — Bloc 3.5 / 3.6 : Docker Compose (web + Postgres + Adminer)
#   Usage   : bash demo.sh             (pauses entre les étapes)
#             DEMO_AUTO=1 bash demo.sh  (sans pause, pour tester)
#   Ports   : WEB_PORT (3002) et ADMINER_PORT (8081), modifiables en variables d'env
#   Effet   : copie le projet dans un dossier temporaire, « docker compose up »,
#             puis « docker compose down -v » + suppression de l'image construite à la fin.
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
DOCKER="${DOCKER:-docker}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d -t demo-compose-XXXXXX)"
export WEB_PORT="${WEB_PORT:-3002}" ADMINER_PORT="${ADMINER_PORT:-8081}"

cp -r "$HERE/app" "$HERE/compose.yaml" "$HERE/.env.example" "$WORKDIR/"
cd "$WORKDIR"

compose() { "$DOCKER" compose "$@"; }

cleanup() {
  cd "$WORKDIR" && compose down -v --remove-orphans >/dev/null 2>&1 || true
  "$DOCKER" image ls -q --filter reference='*demo-compose*' | xargs -r "$DOCKER" rmi -f >/dev/null 2>&1 || true
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Stack demo-compose arrêtée, volume et image supprimés"
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }
attendre_http() {   # attendre_http URL [secondes]
  for _ in $(seq 1 "${2:-60}"); do curl -fsS "$1" >/dev/null 2>&1 && return 0; sleep 1; done
  echo "⚠ $1 ne répond pas" >&2; return 1
}

etape "1. Un seul fichier décrit toute l'application"
run "cat compose.yaml"
pause

etape "2. Les variables : un .env local, jamais commité"
run "cp .env.example .env"
run "cat .env"
run "compose config --services"
pause

etape "3. Tout démarrer en UNE commande"
run "compose up -d --build"
attendre_http "http://localhost:$WEB_PORT/health"
run "compose ps"
echo "→ « web » a attendu que « db » soit healthy (depends_on + condition: service_healthy)."
pause

etape "4. L'application parle à la base PAR SON NOM de service"
run "curl -s http://localhost:$WEB_PORT/; echo"
run "curl -s http://localhost:$WEB_PORT/; echo"
run "curl -s http://localhost:$WEB_PORT/health; echo"
run "compose exec web getent hosts db"
pause

etape "5. Les logs de tous les services (ou d'un seul)"
run "compose logs --tail 5 web"
run "compose logs --tail 3 db"
pause

etape "6. Entrer dans la base avec psql (sans installer Postgres sur la machine)"
run "compose exec db psql -U demo -d demo -c 'SELECT count(*) AS visites FROM visits;'"
echo "→ Adminer : http://localhost:$ADMINER_PORT  (Système PostgreSQL, serveur db, utilisateur demo, mot de passe du .env)"
pause

etape "7. down : conteneurs supprimés… mais le VOLUME reste"
run "compose down"
run "$DOCKER volume ls --filter name=demo-compose"
run "compose up -d"
attendre_http "http://localhost:$WEB_PORT/health"
run "curl -s http://localhost:$WEB_PORT/; echo"
echo "→ Le compteur continue : les données sont dans le volume db-data."
pause

etape "8. Panne de base de données : que voit l'application ?"
run "compose stop db"
run "curl -s -o /dev/null -w 'GET /health → HTTP %{http_code}\n' http://localhost:$WEB_PORT/health || true"
run "compose start db"
attendre_http "http://localhost:$WEB_PORT/health"
run "curl -s -w '  → HTTP %{http_code}\n' http://localhost:$WEB_PORT/health"
echo "→ /health renvoie 503 quand la base est absente : c'est ce que surveillera Uptime Kuma (J4)."
pause

etape "9. down -v : on efface AUSSI les données"
run "compose down -v"
run "$DOCKER volume ls --filter name=demo-compose"
echo -e "\n✅ Fin de la démo. À retenir : up -d, ps, logs -f, exec, down, down -v."
