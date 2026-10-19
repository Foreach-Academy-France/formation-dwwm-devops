#!/usr/bin/env bash
# =============================================================================
# Démo J4 — Bloc 6.1 : supervision avec Uptime Kuma
#   Usage   : bash demo.sh             (pauses : la configuration se fait dans le navigateur)
#             DEMO_AUTO=1 bash demo.sh  (sans pause : vérifie seulement que tout démarre)
#   Ports   : KUMA_PORT (3001), CIBLE_PORT (8088)
#   Effet   : démarre Uptime Kuma + une cible nginx qui imite /health, coupe la cible
#             pour déclencher une alerte, puis « docker compose down -v » à la fin
#             (KEEP=1 pour laisser la stack tourner après la démo).
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
KEEP="${KEEP:-0}"
DOCKER="${DOCKER:-docker}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d -t demo-kuma-XXXXXX)"
export KUMA_PORT="${KUMA_PORT:-3001}" CIBLE_PORT="${CIBLE_PORT:-8088}"

cp -r "$HERE/compose.yaml" "$HERE/cible" "$WORKDIR/"
cd "$WORKDIR"

compose() { "$DOCKER" compose "$@"; }

cleanup() {
  if [[ "$KEEP" == "1" ]]; then
    echo -e "\n📁 Stack conservée. Pour l'arrêter : cd $WORKDIR && docker compose down -v && rm -rf $WORKDIR"
    return
  fi
  cd "$WORKDIR" && compose down -v --remove-orphans >/dev/null 2>&1 || true
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Stack demo-uptime-kuma arrêtée, volume supprimé"
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }
attendre_http() {   # attendre_http URL [secondes]
  for _ in $(seq 1 "${2:-90}"); do curl -sS -o /dev/null "$1" 2>/dev/null && return 0; sleep 1; done
  echo "⚠ $1 ne répond pas" >&2; return 1
}

etape "1. Démarrer Uptime Kuma et la cible"
run "cat compose.yaml"
run "compose up -d"
attendre_http "http://localhost:$CIBLE_PORT/health" 30
echo "(Uptime Kuma met 10 à 30 s à démarrer…)"
attendre_http "http://localhost:$KUMA_PORT" 120
run "compose ps"
run "curl -s http://localhost:$CIBLE_PORT/health; echo"
run "curl -s -o /dev/null -w 'Uptime Kuma → HTTP %{http_code} (redirection vers /setup ou /dashboard)\n' http://localhost:$KUMA_PORT"
pause

etape "2. Dans le navigateur : créer le compte et la première sonde"
cat <<TXT
  1. Ouvrir http://localhost:$KUMA_PORT → créer le compte administrateur (local, démo).
  2. « Ajouter une sonde » :
       Type        : HTTP(s) - Mot-clé
       Nom         : TaskFlow (démo) /health
       URL         : http://cible/health          ← nom du SERVICE Compose, pas localhost !
       Mot-clé     : "status":"ok"
       Intervalle  : 20 s   ·   Nouvelles tentatives : 1
  3. Enregistrer : la sonde passe au VERT, le temps de réponse s'affiche.
TXT
pause

etape "3. Incident ! La cible tombe"
run "compose stop cible"
run "curl -s -o /dev/null -w 'GET /health → HTTP %{http_code}\n' http://localhost:$CIBLE_PORT/health || true"
echo "→ Dans Uptime Kuma : la sonde passe au ROUGE après l'intervalle + la nouvelle tentative (~40 s)."
pause

etape "4. Rétablissement"
run "compose start cible"
attendre_http "http://localhost:$CIBLE_PORT/health" 30
run "curl -s http://localhost:$CIBLE_PORT/health; echo"
echo "→ La sonde repasse au VERT ; l'historique garde la trace de la panne (durée, heure)."
pause

etape "5. Et pour la prod TaskFlow ?"
cat <<TXT
  Sonde « HTTP(s) - Mot-clé » sur la stack taskflow-prod (étape 4 du fil rouge) :
       URL     : https://host.docker.internal/health   (ou :<HTTPS_PORT> si vous avez changé le port)
       Option  : « Ignorer les erreurs TLS/SSL »  (certificat auto-signé)
       Mot-clé : "db":"up"
  Notifications (à montrer, pas à configurer) : e-mail SMTP, Discord, Slack, Telegram…
  Page de statut publique : « Pages de statut » → nouvelle page → ajouter la sonde.
TXT
echo -e "\n✅ Fin de la démo Uptime Kuma."
