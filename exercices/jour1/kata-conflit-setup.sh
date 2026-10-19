#!/usr/bin/env bash
# =============================================================================
# Kata conflit — prépare un dépôt Git jetable avec un conflit garanti.
#   Usage : bash kata-conflit-setup.sh
#   Résultat : un dossier /tmp/kata-conflit.XXXXXX contenant un dépôt avec
#     - main                : index.html avec une liste <ul> de 2 apprenants
#     - feature/carte-alice : ajoute « Alice » à la fin de la liste
#     - feature/carte-bob   : ajoute « Bob » à la fin de la liste (même endroit)
#   Merger les deux branches dans main provoque un conflit sur le <ul>.
#   Nettoyage : rm -rf <chemin affiché>
# =============================================================================
set -euo pipefail

REPO_DIR="$(mktemp -d -t kata-conflit.XXXXXX)"
cd "$REPO_DIR"

git init -q -b main
git config user.name "Formateur DWWM"
git config user.email "formateur@example.com"
git config commit.gpgsign false

cat > index.html <<'HTML'
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>Promo DWWM</title>
</head>
<body>
  <h1>Promo DWWM</h1>
  <ul>
    <li>Karim</li>
    <li>Léa</li>
  </ul>
</body>
</html>
HTML
git add index.html
git commit -q -m "feat: page de la promo avec deux apprenants"

git switch -q -c feature/carte-alice
sed -i 's|    <li>Léa</li>|    <li>Léa</li>\n    <li>Alice</li>|' index.html
git commit -q -am "feat: ajoute la carte d'Alice"

git switch -q main
git switch -q -c feature/carte-bob
sed -i 's|    <li>Léa</li>|    <li>Léa</li>\n    <li>Bob</li>|' index.html
git commit -q -am "feat: ajoute la carte de Bob"

git switch -q main

echo
echo "Dépôt du kata prêt : $REPO_DIR"
echo
git log --oneline --graph --all --decorate
echo
echo "Étape suivante :  cd $REPO_DIR"
echo "Nettoyage final : rm -rf $REPO_DIR"
