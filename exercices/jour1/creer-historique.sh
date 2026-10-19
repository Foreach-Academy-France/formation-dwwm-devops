#!/usr/bin/env bash
# =============================================================================
# Construit un dépôt TaskFlow « historique » reproductible pour l'exercice 03.
#   Auteurs et dates sont fixés : les hash de commit sont identiques sur
#   toutes les machines (même version de Git).
#   Usage : bash creer-historique.sh            → crée un dossier /tmp/historique.XXXXXX
#           bash creer-historique.sh --print    → idem + affiche le graphe
#   Nettoyage : rm -rf <chemin affiché>
# =============================================================================
set -euo pipefail

REPO_DIR="$(mktemp -d -t historique.XXXXXX)"
cd "$REPO_DIR"

git init -q -b main
git config commit.gpgsign false
git config tag.gpgsign false

# Compteur de minutes pour des dates croissantes et déterministes
MINUTE=0

# commit_as <nom> <fichier> <contenu> <message>
commit_as() {
  local name="$1" file="$2" content="$3" message="$4"
  local email
  email="$(echo "$name" | tr '[:upper:]' '[:lower:]')@taskflow.example"
  MINUTE=$((MINUTE + 7))
  local date
  date="$(printf '2026-10-12T09:%02d:00+02:00' "$MINUTE")"
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$content" >> "$file"
  git add "$file"
  GIT_AUTHOR_NAME="$name" GIT_AUTHOR_EMAIL="$email" GIT_AUTHOR_DATE="$date" \
  GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" GIT_COMMITTER_DATE="$date" \
    git commit -q -m "$message"
}

# merge_as <nom> <branche> <message> [--ff]
merge_as() {
  local name="$1" branch="$2" message="$3" mode="${4:---no-ff}"
  local email
  email="$(echo "$name" | tr '[:upper:]' '[:lower:]')@taskflow.example"
  MINUTE=$((MINUTE + 7))
  local date
  date="$(printf '2026-10-12T09:%02d:00+02:00' "$MINUTE")"
  GIT_AUTHOR_NAME="$name" GIT_AUTHOR_EMAIL="$email" GIT_AUTHOR_DATE="$date" \
  GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" GIT_COMMITTER_DATE="$date" \
    git merge -q "$mode" -m "$message" "$branch"
}

commit_as "Sarah" README.md "# TaskFlow" "chore: initialise le projet TaskFlow"
commit_as "Sarah" api/src/app.js "// API Express" "feat(api): crée l'application Express"

# Branche 1 : fusionnée avec un merge commit (--no-ff)
git switch -q -c feature/health
commit_as "Yanis" api/src/app.js "// GET /health" "feat(api): ajoute la route GET /health"
commit_as "Yanis" api/tests/app.test.js "// test /health" "test(api): teste la route /health"

# Pendant ce temps, main avance
git switch -q main
commit_as "Sarah" .gitignore "node_modules/" "chore: ajoute le .gitignore"
merge_as "Sarah" feature/health "Merge branch 'feature/health'"

# Branche 2 : fusionnée en fast-forward (main n'a pas bougé entre-temps)
git switch -q -c fix/titre-page
commit_as "Inès" front/index.html "<title>TaskFlow</title>" "fix(front): corrige le titre de la page"
git switch -q main
merge_as "Inès" fix/titre-page "" --ff-only

# Tag annoté de version
MINUTE=$((MINUTE + 7))
TAG_DATE="$(printf '2026-10-12T09:%02d:00+02:00' "$MINUTE")"
GIT_COMMITTER_NAME="Sarah" GIT_COMMITTER_EMAIL="sarah@taskflow.example" GIT_COMMITTER_DATE="$TAG_DATE" \
  git tag -a v1.0.0 -m "Version 1.0.0"

# Branche 3 : pas encore fusionnée
git switch -q -c feature/docker
commit_as "Yanis" api/Dockerfile "FROM node:20-alpine" "build(api): ajoute un Dockerfile"
git switch -q main

echo "Dépôt créé : $REPO_DIR"
echo "Nettoyage : rm -rf $REPO_DIR"
if [[ "${1:-}" == "--print" ]]; then
  echo
  git log --oneline --graph --all --decorate
fi
