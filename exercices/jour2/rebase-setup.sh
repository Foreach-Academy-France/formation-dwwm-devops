#!/usr/bin/env bash
# =============================================================================
# Exercice 2.1 — prépare un dépôt jetable pour pratiquer le rebase interactif.
#   Usage : bash rebase-setup.sh
#   Résultat : un dossier temporaire (ex. /tmp/rebase-exo.XXXXXX) avec
#     - main               : 3 commits, dont un ajouté APRÈS la création de la branche
#     - feature/tri-taches : 5 commits « brouillon » (wip, fix typo, oups…)
#   Nettoyage : rm -rf <chemin affiché>
# =============================================================================
set -euo pipefail

REPO_DIR="$(mktemp -d -t rebase-exo.XXXXXX)"
cd "$REPO_DIR"

git init -q -b main
git config user.name "Apprenant DWWM"
git config user.email "apprenant@example.com"
git config commit.gpgsign false

mkdir -p api/src front/src
cat > api/src/app.js <<'JS'
const express = require('express');

function createApp({ repository }) {
  const app = express();
  app.use(express.json());

  app.get('/api/tasks', async (req, res) => {
    res.json(await repository.list());
  });

  return app;
}

module.exports = { createApp };
JS
echo "# TaskFlow" > README.md
git add . && git commit -q -m "feat(api): liste des tâches"

echo "node_modules/" > .gitignore
git add . && git commit -q -m "chore: ajoute le .gitignore"

# --- Branche de fonctionnalité avec un historique « brouillon » ---------------
git switch -q -c feature/tri-taches

sed -i "s|    res.json(await repository.list());|    const tasks = await repository.list();\n    // TODO tri\n    res.json(tasks);|" api/src/app.js
git commit -q -am "wip"

sed -i "s|    // TODO tri|    tasks.sort((a, b) => a.done - b.done);|" api/src/app.js
git commit -q -am "tri des taches par statut (non terminées d'abord)"

sed -i "s|(a, b) => a.done - b.done|(a, b) => Number(a.done) - Number(b.done)|" api/src/app.js
git commit -q -am "fix typo"

cat >> README.md <<'MD'

## API

- `GET /api/tasks` : renvoie les tâches, les non terminées d'abord.
MD
git commit -q -am "docs: documente le tri dans le README"

echo "console.log('debug tri', tasks.length);" > debug.js
git add debug.js && git commit -q -m "oups, fichier de debug"

# --- Pendant ce temps, main avance --------------------------------------------
git switch -q main
cat > front/src/api.js <<'JS'
export async function fetchTasks() {
  const res = await fetch('/api/tasks');
  return res.json();
}
JS
git add . && git commit -q -m "feat(front): client API fetchTasks"

git switch -q feature/tri-taches

echo
echo "Dépôt de l'exercice prêt : $REPO_DIR"
echo
git log --oneline --graph --all --decorate
echo
echo "Étape suivante :  cd $REPO_DIR"
echo "Nettoyage final : rm -rf $REPO_DIR"
