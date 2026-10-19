# Exercice 1.4 — Réparer ses erreurs avec Git

| | |
|---|---|
| **Durée** | 15 min |
| **Séquence** | S2 — Bloc 2.1 (working dir / index / commit) |
| **Prérequis** | exercice 1.1 (vous réutilisez le dépôt `~/exo-git-solo`) |
| **Fichiers fournis** | aucun |

## Objectif

Connaître les quatre commandes « filet de sécurité » du quotidien et savoir **laquelle utiliser selon la zone** où se trouve l'erreur :

| L'erreur est… | Commande |
|---|---|
| dans le répertoire de travail (pas encore `add`) | `git restore <fichier>` |
| dans l'index (déjà `add`, pas encore commit) | `git restore --staged <fichier>` |
| dans le **dernier** commit, pas encore poussé | `git commit --amend` |
| dans un commit **déjà poussé** / partagé | `git revert <commit>` |

## Consignes

Placez-vous dans `~/exo-git-solo` (exercice 1.1), sur `main`, avec un `git status` propre.

### Cas 1 — « J'ai tout cassé dans mon fichier »

1. Remplacez tout le contenu de `README.md` par `n'importe quoi` (`echo "n'importe quoi" > README.md`).
2. Vérifiez avec `git status` et `git diff` que la modification n'est pas indexée.
3. Annulez la modification pour retrouver la version du dernier commit.

### Cas 2 — « J'ai ajouté le mauvais fichier »

4. Créez `notes-perso.txt`, puis faites `git add .` (oups : vous ne vouliez pas versionner ce fichier).
5. Retirez **uniquement** `notes-perso.txt` de l'index, **sans** supprimer le fichier de votre disque.
6. Vérifiez : `git status` le montre comme *non suivi*. Supprimez-le ensuite à la main.

### Cas 3 — « Faute de frappe dans mon dernier message de commit »

7. Ajoutez une ligne `Gestionnaire de tâches` dans `README.md` et validez avec le message `docs: decsription du projet` (faute volontaire).
8. Corrigez le message du **dernier** commit en `docs: description du projet`.
9. Vérifiez avec `git log --oneline -3` qu'il n'y a qu'un seul commit `docs:` et que son identifiant a changé.

### Cas 4 — « Le commit est déjà sur GitHub et il casse tout »

10. Ajoutez une ligne `BUG` dans `api/app.js` et validez (`feat(api): change la route`). Imaginez que ce commit a été poussé et que vos collègues l'ont récupéré.
11. Annulez ce commit **sans réécrire l'historique**.
12. Affichez l'historique : combien de commits ont été ajoutés ? Le fichier `api/app.js` contient-il encore `BUG` ?

## Résultat attendu

```text
$ git log --oneline -4
d4e5f6a (HEAD -> main) Revert "feat(api): change la route"
c3d4e5f feat(api): change la route
b2c3d4e docs: description du projet
3c4d5e6 feat(api): ajoute la route /health
```

`api/app.js` ne contient plus `BUG`, et `git status` est propre.

## Indices

<details>
<summary>Indice 1 — cas 1 et 2</summary>

Lisez attentivement ce qu'affiche `git status` : Git vous **écrit** la commande à utiliser (« utilisez `git restore <fichier>…` pour annuler… », « utilisez `git restore --staged <fichier>…` pour désindexer »).
</details>

<details>
<summary>Indice 2 — cas 3</summary>

`git commit --amend -m "nouveau message"` remplace le dernier commit par un nouveau (d'où le nouvel identifiant). À ne **jamais** faire sur un commit déjà poussé et partagé.
</details>

<details>
<summary>Indice 3 — cas 4</summary>

`git revert HEAD` crée un **nouveau** commit qui fait l'inverse du dernier. L'historique n'est pas modifié : c'est la méthode sûre sur une branche partagée comme `main`.
</details>

## Question de réflexion

Pourquoi `git commit --amend` est-il dangereux sur un commit déjà poussé, alors que `git revert` ne l'est pas ?
