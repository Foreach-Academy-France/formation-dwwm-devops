#!/usr/bin/env bash
# =============================================================================
# Démo J1 — Bloc 2.2 : branches, fast-forward et merge commit
#   Usage   : bash demo.sh            (pauses entre les étapes)
#             DEMO_AUTO=1 bash demo.sh (sans pause, pour tester)
#   Effet   : crée un dépôt jetable dans /tmp (mktemp), le supprime à la fin
#             (KEEP=1 pour le conserver et l'explorer après la démo)
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
KEEP="${KEEP:-0}"
WORKDIR="$(mktemp -d -t demo-git-branches-XXXXXX)"

cleanup() {
  if [[ "$KEEP" == "1" ]]; then
    echo -e "\n📁 Dépôt conservé : $WORKDIR"
  else
    rm -rf "$WORKDIR"
    echo -e "\n🧹 Dépôt jetable supprimé ($WORKDIR)"
  fi
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }
graphe() { run "git log --oneline --graph --all --decorate"; }

cd "$WORKDIR"

etape "1. Un dépôt tout neuf"
run "git init -q -b main ."
run "git config user.name 'Formateur'"
run "git config user.email 'formateur@example.com'"
echo "# TaskFlow" > README.md
run "git add README.md"
run "git commit -q -m 'docs: ajoute le README'"
echo "console.log('TaskFlow API');" > server.js
run "git add server.js"
run "git commit -q -m 'feat: squelette de l API'"
graphe
pause

etape "2. Une branche = un simple pointeur vers un commit"
run "git switch -c feature/health"
run "git branch -v"
run "cat .git/refs/heads/feature/health"
echo "→ main et feature/health pointent sur le MÊME commit : créer une branche ne copie rien."
pause

etape "3. On travaille sur la branche"
echo "app.get('/health', (req, res) => res.json({ status: 'ok' }));" >> server.js
run "git commit -q -am 'feat: ajoute la route /health'"
graphe
echo "→ feature/health a avancé, main est resté en arrière."
pause

etape "4. Merge fast-forward : main n'a pas bougé, Git avance juste le pointeur"
run "git switch main"
run "git merge feature/health"
graphe
echo "→ Pas de commit de merge : l'historique reste une ligne droite."
pause

etape "5. Deux branches qui divergent"
run "git switch -c feature/logs"
echo "console.log(JSON.stringify({ method: 'GET', path: '/', status: 200 }));" >> server.js
run "git commit -q -am 'feat: log JSON par requête'"
run "git switch main"
echo "Lancer avec : npm start" >> README.md
run "git commit -q -am 'docs: explique le démarrage'"
graphe
echo "→ main ET feature/logs ont chacun un commit que l'autre n'a pas."
pause

etape "6. Merge avec commit de fusion (merge commit)"
run "git merge --no-edit feature/logs"
graphe
echo "→ Un commit de merge à DEUX parents réunit les deux lignes."
run "git log -1 --format='Parents du dernier commit : %p'"
pause

etape "7. Ménage : supprimer les branches fusionnées"
run "git branch --merged"
run "git branch -d feature/health feature/logs"
graphe
echo -e "\n✅ Fin de la démo branches."
