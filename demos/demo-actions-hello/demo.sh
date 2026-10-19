#!/usr/bin/env bash
# =============================================================================
# Démo J3 — Bloc 4.1 : premier workflow GitHub Actions
#   Usage   : bash demo.sh
#               → prépare un dépôt local jetable contenant .github/workflows/hello.yml
#             DEMO_GH_REPO=hello-actions-demo bash demo.sh
#               → crée en plus le dépôt PRIVÉ sur GitHub avec `gh`, pousse, suit le run
#             DEMO_AUTO=1 bash demo.sh   (sans pause, pour tester la partie locale)
#   Effet   : dossier temporaire supprimé à la fin. Le dépôt GitHub éventuel est
#             conservé (commande de suppression affichée).
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
DEMO_GH_REPO="${DEMO_GH_REPO:-}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(mktemp -d -t demo-actions-XXXXXX)"

cleanup() {
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Dossier temporaire supprimé ($WORKDIR)"
  if [[ -n "$DEMO_GH_REPO" ]]; then
    echo "   Dépôt GitHub conservé. Pour le supprimer : gh repo delete $DEMO_GH_REPO --yes"
  fi
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }

cd "$WORKDIR"

etape "1. Un dépôt de test avec un workflow"
run "git init -q -b main ."
run "git config user.name \"\$(git config --global user.name || echo Formateur)\""
run "git config user.email \"\$(git config --global user.email || echo formateur@example.com)\""
echo "# Démo GitHub Actions" > README.md
run "mkdir -p .github/workflows"
run "cp '$HERE/hello.yml' .github/workflows/hello.yml"
run "find . -path ./.git -prune -o -type f -print"
pause

etape "2. Lire le workflow (structure : on → jobs → steps)"
run "grep -v '^\s*#' .github/workflows/hello.yml | grep -v '^\s*$' | sed -n '1,30p'"
pause

etape "3. Commit"
run "git add . && git commit -q -m 'ci: premier workflow hello'"
run "git log --oneline"
pause

if [[ -z "$DEMO_GH_REPO" ]]; then
  etape "4. (mode local) Pour publier sur GitHub"
  cat <<TXT
Relancez avec DEMO_GH_REPO=<nom> pour créer le dépôt privé automatiquement, ou à la main :

  gh repo create hello-actions-demo --private --source . --push
  gh run watch                 # suivre le run dans le terminal
  gh workflow run hello.yml -f prenom=Alice    # déclenchement manuel (workflow_dispatch)

Puis montrez l'onglet « Actions » du dépôt dans le navigateur.
TXT
  echo -e "\n✅ Partie locale terminée."
  exit 0
fi

command -v gh >/dev/null || { echo "❌ gh (GitHub CLI) est requis pour DEMO_GH_REPO" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "❌ gh n'est pas authentifié : gh auth login" >&2; exit 1; }

etape "4. Créer le dépôt privé et pousser"
run "gh repo create '$DEMO_GH_REPO' --private --source . --push"
pause

etape "5. Suivre le run déclenché par le push"
sleep 5
run "gh run list --limit 3"
run "gh run watch \"\$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')\" --exit-status || true"
pause

etape "6. Déclenchement manuel avec un paramètre (workflow_dispatch)"
run "gh workflow run hello.yml -f prenom='la salle'"
sleep 5
run "gh run list --limit 3"
echo -e "\n✅ Montrez maintenant l'onglet Actions : jobs, steps, logs, résumé, durée."
