# Exercice 1.1 — Les commandes Git en solo

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S2 — Bloc 2.1 (les bases de Git) et Bloc 2.2 (branches) |
| **Prérequis** | Git installé (`git --version`), un terminal ouvert |
| **Fichiers fournis** | aucun : vous partez d'un dossier vide |

## Objectif

Refaire seul, sans copier-coller, le cycle de base de Git : *modifier → indexer → valider → brancher → fusionner*. Vous devez pouvoir dire, à chaque étape, **dans quelle zone** se trouve votre modification : répertoire de travail, index (*staging area*) ou commit.

## Consignes

1. Créez un dossier de travail et initialisez un dépôt dont la branche principale s'appelle `main` :
   ```bash
   mkdir ~/exo-git-solo && cd ~/exo-git-solo
   git init -b main
   ```
2. Si ce n'est pas déjà fait sur votre poste, configurez votre identité (une seule fois par machine) :
   ```bash
   git config --global user.name "Prénom Nom"
   git config --global user.email "vous@example.com"
   ```
3. Créez un fichier `README.md` contenant la ligne `# TaskFlow`. Lancez `git status`. **Notez** comment Git qualifie ce fichier.
4. Ajoutez le fichier à l'index, relancez `git status` et notez la différence.
5. Validez avec le message `chore: initialise le projet` (format *Conventional Commits*).
6. Créez un fichier `.gitignore` qui ignore le dossier `node_modules/` et tout fichier `.env`. Créez ensuite un fichier `.env` contenant `DATABASE_URL=postgres://taskflow:taskflow@localhost:5432/taskflow`. Vérifiez avec `git status` que `.env` **n'apparaît pas**. Validez le `.gitignore` seul (`chore: ajoute le .gitignore`).
7. Créez et basculez sur une branche `feature/health` **en une seule commande**.
8. Sur cette branche, créez `api/app.js` contenant `// GET /health renvoie { status: "ok" }`, puis validez (`feat(api): ajoute la route /health`).
9. Revenez sur `main`. Le fichier `api/app.js` existe-t-il ? Expliquez pourquoi.
10. Fusionnez `feature/health` dans `main`. Lisez le message affiché par Git : s'agit-il d'un *fast-forward* ou d'un *merge commit* ?
11. Affichez l'historique sous forme de graphe compact.
12. Supprimez la branche `feature/health`, désormais fusionnée.

## Résultat attendu

```text
$ git log --oneline --graph
* 3c4d5e6 (HEAD -> main) feat(api): ajoute la route /health
* 2b3c4d5 chore: ajoute le .gitignore
* 1a2b3c4 chore: initialise le projet
```

(Les identifiants de commit seront différents chez vous.) `git status` affiche « rien à valider, la copie de travail est propre » et le fichier `.env` n'a jamais été versionné.

## Indices

<details>
<summary>Indice 1 — étapes 3 à 5</summary>

Un fichier que Git ne connaît pas encore est dit *untracked* (non suivi). La commande pour le passer dans l'index commence par `git add`, celle pour valider par `git commit -m`.
</details>

<details>
<summary>Indice 2 — étapes 7 et 10</summary>

`git switch -c <nom>` crée **et** bascule. Comme `main` n'a reçu aucun nouveau commit depuis la création de la branche, Git peut simplement « avancer le pointeur » de `main` : c'est un *fast-forward*.
</details>

<details>
<summary>Indice 3 — étapes 11 et 12</summary>

`git log --oneline --graph` pour le graphe ; `git branch -d <nom>` pour supprimer une branche fusionnée (`-d` refuse si la branche n'est pas fusionnée, c'est une sécurité).
</details>

## Pour aller plus loin

- Lancez `git log --oneline --graph --all` : qu'apporte `--all` ?
- Que se passe-t-il si vous faites `git branch -d` sur une branche **non** fusionnée ?
