# Jour 1 — Solutions des exercices guidés

> À ouvrir **après** avoir cherché (et utilisé les indices). Lire une solution sans avoir essayé ne fait rien retenir.

---

## Exercice 1.1 — Les commandes Git en solo

```bash
mkdir ~/exo-git-solo && cd ~/exo-git-solo
git init -b main

echo "# TaskFlow" > README.md
git status                      # README.md : « Fichiers non suivis » (untracked)
git add README.md
git status                      # README.md : « Modifications qui seront validées » (dans l'index)
git commit -m "chore: initialise le projet"

printf 'node_modules/\n.env\n' > .gitignore
echo "DATABASE_URL=postgres://taskflow:taskflow@localhost:5432/taskflow" > .env
git status                      # seul .gitignore apparaît, .env est ignoré
git add .gitignore
git commit -m "chore: ajoute le .gitignore"

git switch -c feature/health
mkdir api
echo '// GET /health renvoie { status: "ok" }' > api/app.js
git add api/app.js
git commit -m "feat(api): ajoute la route /health"

git switch main
ls api                          # « Aucun fichier ou dossier de ce type »
git merge feature/health        # « Mise à jour ... Fast-forward »
git log --oneline --graph
git branch -d feature/health
```

**Réponses aux questions :**

- Étape 3 : le fichier est *non suivi* (*untracked*) : il est dans le répertoire de travail, Git ne le connaît pas.
- Étape 4 : il passe dans « Modifications qui seront validées » : il est dans l'**index**.
- Étape 9 : `api/app.js` n'existe pas sur `main`. En changeant de branche, Git remet le répertoire de travail dans l'état du dernier commit de cette branche ; le fichier n'existe que dans les commits de `feature/health`.
- Étape 10 : **fast-forward**, car `main` n'avait pas avancé depuis la création de la branche ; Git déplace simplement le pointeur `main`.
- Pour aller plus loin : `--all` affiche **toutes** les branches, pas seulement celle sur laquelle on est. `git branch -d` sur une branche non fusionnée est refusé (« la branche n'est pas totalement fusionnée ») ; `-D` force la suppression (et fait perdre les commits).

---

## Exercice 1.2 — Kata conflit

```bash
bash kata-conflit-setup.sh
cd /tmp/kata-conflit.XXXXXX          # le chemin affiché par le script

git log --oneline --graph --all
git merge feature/carte-alice        # Fast-forward : main n'avait pas bougé
git merge feature/carte-bob          # CONFLICT (content): Merge conflict in index.html
git status                           # « Chemins non fusionnés : modifié des deux côtés : index.html »
```

Contenu du fichier en conflit :

```html
    <li>Léa</li>
<<<<<<< HEAD
    <li>Alice</li>
=======
    <li>Bob</li>
>>>>>>> feature/carte-bob
  </ul>
```

- `<<<<<<< HEAD` → `=======` : la version de `main` (branche courante), qui contient déjà Alice.
- `=======` → `>>>>>>> feature/carte-bob` : la version de la branche qu'on fusionne.

Résolution : on garde les deux lignes et on supprime les trois marqueurs :

```html
    <li>Léa</li>
    <li>Alice</li>
    <li>Bob</li>
  </ul>
```

```bash
git add index.html
git commit                           # message proposé : Merge branch 'feature/carte-bob'
git log --oneline --graph --all
git grep -n '<<<<<<<\|>>>>>>>'       # n'affiche rien
cd ~ && rm -rf /tmp/kata-conflit.XXXXXX
```

Dans VS Code, les boutons « Accept Current / Accept Incoming / **Accept Both Changes** » font la même chose : ici, *Accept Both* donne directement le bon résultat.

**Question de réflexion :** Git fusionne automatiquement quand les modifications touchent des **zones différentes** du fichier (lignes éloignées). Il y a conflit quand les deux branches modifient **les mêmes lignes** (ou des lignes adjacentes) : Git ne peut pas deviner l'ordre ou le contenu voulu, c'est une décision humaine.

---

## Exercice 1.3 — Lire un historique

1. **9 commits** (9 lignes avec `*`).
2. `HEAD -> main` : vous êtes sur **`main`**, au commit `fd16415`.
3. `20bc9b4 chore: initialise le projet TaskFlow` (tout en bas).
4. **`3b7627e Merge branch 'feature/health'`** : deux traits s'y rejoignent (`|\` en dessous). Ses parents : `057cd1f` (côté `main`) et `24df34a` (dernier commit de `feature/health`).
5. `057cd1f chore: ajoute le .gitignore` : il est sur la colonne de gauche, entre la création de la branche (`8f17968`) et la fusion.
6. **Fast-forward** : `fix/titre-page` et `main` pointent sur le **même** commit `fd16415`, et il n'y a pas de commit « Merge branch 'fix/titre-page' ».
7. `v1.0.0` est sur `fd16415`. La version 1.0.0 **contient** `/health` (`f1f8d16` est un ancêtre de `fd16415` via le merge). Elle **ne contient pas** le Dockerfile (`93db9eb` est plus récent, au-dessus).
8. `feature/docker`. Commande : `git switch main && git merge feature/docker`. Ce serait un **fast-forward** : `feature/docker` part directement de `main` (`fd16415`) et `main` n'a pas avancé depuis.
9. `feature/health` et `fix/titre-page` (déjà fusionnées) : `git branch --merged main` les liste. `feature/docker` serait refusée par `git branch -d`.

---

## Exercice 1.4 — Réparer ses erreurs

```bash
cd ~/exo-git-solo

# Cas 1 — modification non indexée
echo "n'importe quoi" > README.md
git status && git diff
git restore README.md

# Cas 2 — fichier ajouté par erreur à l'index
echo "mes notes" > notes-perso.txt
git add .
git restore --staged notes-perso.txt
git status                           # notes-perso.txt : non suivi
rm notes-perso.txt

# Cas 3 — corriger le dernier message de commit (non poussé)
echo "Gestionnaire de tâches" >> README.md
git commit -am "docs: decsription du projet"
git commit --amend -m "docs: description du projet"
git log --oneline -3                 # un seul commit docs:, nouvel identifiant

# Cas 4 — annuler un commit déjà partagé
echo "BUG" >> api/app.js
git commit -am "feat(api): change la route"
git revert HEAD --no-edit
git log --oneline -4                 # 2 commits ajoutés : le commit fautif + le Revert
cat api/app.js                       # plus de ligne BUG
```

**Question de réflexion :** `--amend` **remplace** un commit par un autre (nouvel identifiant). Si ce commit a déjà été poussé, l'historique local et celui de GitHub divergent : il faudrait un `push --force`, qui efface le commit chez tout le monde et casse les branches de vos collègues. `git revert` **ajoute** un commit inverse : l'historique existant n'est jamais modifié, tout le monde peut faire un simple `git pull`.
