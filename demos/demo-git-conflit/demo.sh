#!/usr/bin/env bash
# =============================================================================
# Démo J1 — Bloc 2.4 : provoquer, lire et résoudre un conflit de merge
#   Usage   : bash demo.sh            (pauses ; vous pouvez résoudre à la main)
#             DEMO_AUTO=1 bash demo.sh (sans pause, résolution automatique)
#   Effet   : dépôt jetable dans /tmp (mktemp), supprimé à la fin (KEEP=1 pour garder)
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
KEEP="${KEEP:-0}"
WORKDIR="$(mktemp -d -t demo-git-conflit-XXXXXX)"

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

cd "$WORKDIR"

etape "1. Situation de départ : une page partagée par toute la promo"
run "git init -q -b main ."
run "git config user.name 'Formateur'"
run "git config user.email 'formateur@example.com'"
cat > index.html <<'HTML'
<h1>Promo DWWM</h1>
<ul>
  <li>Formateur</li>
</ul>
HTML
run "git add index.html"
run "git commit -q -m 'feat: page de la promo'"
run "cat index.html"
pause

etape "2. Alice et Bob créent chacun leur branche depuis le même commit"
run "git switch -q -c feature/carte-alice"
sed -i 's#  <li>Formateur</li>#  <li>Formateur</li>\n  <li>Alice</li>#' index.html
run "git commit -q -am 'feat: ajoute Alice'"
run "git switch -q main"
run "git switch -q -c feature/carte-bob"
sed -i 's#  <li>Formateur</li>#  <li>Formateur</li>\n  <li>Bob</li>#' index.html
run "git commit -q -am 'feat: ajoute Bob'"
run "git switch -q main"
run "git log --oneline --graph --all"
echo "→ Les deux branches modifient la MÊME ligne (juste après « Formateur »)."
pause

etape "3. La PR d'Alice est fusionnée en premier : aucun souci"
run "git merge -q feature/carte-alice"
run "cat index.html"
pause

etape "4. Puis celle de Bob… conflit !"
run "git merge feature/carte-bob || true"
run "git status --short"
pause

etape "5. Lire les marqueurs de conflit"
run "cat index.html"
cat <<'TXT'

  <<<<<<< HEAD                 → ce qui est déjà dans main (la version d'Alice)
  =======                      → séparateur
  >>>>>>> feature/carte-bob    → ce qu'apporte la branche de Bob
TXT
echo "→ Git ne choisit pas à notre place : c'est à l'humain de décider (ici : garder les deux)."
pause

etape "6. Résoudre"
if [[ "$DEMO_AUTO" != "1" ]]; then
  echo "Ouvrez $WORKDIR/index.html dans VS Code (« Accept Both Changes »),"
  echo "enregistrez, puis appuyez sur Entrée. Si vous ne touchez à rien, le script résout pour vous."
  pause
fi
if grep -q '^<<<<<<<\|^=======\|^>>>>>>>' index.html; then
  echo "(résolution automatique : on garde Alice ET Bob)"
  cat > index.html <<'HTML'
<h1>Promo DWWM</h1>
<ul>
  <li>Formateur</li>
  <li>Alice</li>
  <li>Bob</li>
</ul>
HTML
fi
run "cat index.html"
run "grep -q '^<<<<<<<' index.html && echo 'Il reste des marqueurs !' || echo 'Aucun marqueur restant ✔'"
pause

etape "7. Terminer le merge : add + commit"
run "git add index.html"
run "git commit -q --no-edit"
run "git log --oneline --graph --all"
echo -e "\n✅ Conflit résolu. Le commit de merge garde la trace de la résolution."
echo "   Pour annuler un merge en cours au lieu de le résoudre : git merge --abort"
