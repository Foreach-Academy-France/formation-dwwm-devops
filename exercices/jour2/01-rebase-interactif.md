# Exercice 2.1 — Nettoyer sa branche avec un rebase interactif

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S2 — Bloc 2.5 (rebase) |
| **Prérequis** | exercices du jour 1 ; savoir quitter l'éditeur de votre terminal (voir encadré) |
| **Fichiers fournis** | [`rebase-setup.sh`](rebase-setup.sh) |

## Objectif

Avant d'ouvrir une Pull Request, transformer un historique « brouillon » (`wip`, `fix typo`, `oups`…) en commits propres et lisibles, **et** remettre sa branche à jour par rapport à `main` — le tout avec **une seule** commande : `git rebase -i main`.

> **Règle d'or** : on ne rebase que **sa propre branche, pas encore partagée**. Jamais `main`, jamais une branche sur laquelle un collègue travaille.

## Mise en place

```bash
bash rebase-setup.sh
cd <chemin affiché par le script>
```

Situation de départ (les identifiants changent à chaque exécution) :

```text
* 5b8d793 (HEAD -> feature/tri-taches) oups, fichier de debug
* fb6e7b0 docs: documente le tri dans le README
* b0a911a fix typo
* d5773bc tri des taches par statut (non terminées d'abord)
* f31aabc wip
| * 8fd55a8 (main) feat(front): client API fetchTasks
|/
* 5a1f70e chore: ajoute le .gitignore
* 4b8cf48 feat(api): liste des tâches
```

> **Quel éditeur ?** Git ouvre l'éditeur configuré (souvent `vim` ou `nano`). Pour utiliser `nano` : `git config --global core.editor nano` (enregistrer : `Ctrl+O` puis `Entrée`, quitter : `Ctrl+X`). Pour VS Code : `git config --global core.editor "code --wait"`.

## Consignes

1. Observez le graphe : combien de commits la branche a-t-elle « en retard » sur `main` ? Combien de commits « brouillon » contient-elle ?
2. Regardez ce que contient chaque commit de la branche (`git show --stat <id>` ou `git log -p main..feature/tri-taches`). Identifiez :
   - les commits qui forment **une seule** évolution du code (le tri des tâches) ;
   - le commit qui documente cette évolution ;
   - le commit qui n'aurait **jamais** dû exister.
3. Lancez le rebase interactif **sur `main`** :
   ```bash
   git rebase -i main
   ```
4. Dans la liste qui s'ouvre, modifiez les mots-clés pour obtenir :
   - un commit `feat(api): trie les tâches par statut` qui regroupe `wip`, le tri et `fix typo` ;
   - le commit `docs: documente le tri dans le README` inchangé ;
   - le fichier de debug **supprimé** de l'historique.
5. Enregistrez et quittez. Si Git rouvre l'éditeur pour un message, écrivez `feat(api): trie les tâches par statut`, enregistrez et quittez.
6. Affichez le graphe : `git log --oneline --graph --all`.
7. Vérifiez : `debug.js` n'existe plus, `api/src/app.js` contient bien le tri, et `front/src/api.js` (venu de `main`) est présent.
8. Revenez sur `main` et fusionnez la branche : quel type de fusion obtenez-vous ? Pourquoi ?
9. Supprimez le dossier temporaire.

## Résultat attendu

```text
* 140bb23 (HEAD -> feature/tri-taches) docs: documente le tri dans le README
* f8d2348 feat(api): trie les tâches par statut
* ced80c7 (main) feat(front): client API fetchTasks
* 5217edd chore: ajoute le .gitignore
* a6641d8 feat(api): liste des tâches
```

Historique **linéaire**, deux commits propres au-dessus de `main`, et une fusion en *fast-forward*.

## Indices

<details>
<summary>Indice 1 — les mots-clés utiles</summary>

| Mot-clé | Effet |
|---|---|
| `pick` | garde le commit tel quel |
| `reword` | garde le commit mais permet de **changer son message** |
| `squash` | fusionne avec le commit **du dessus**, et propose de combiner les messages |
| `fixup` | fusionne avec le commit du dessus, **en jetant** son message |
| `drop` | supprime le commit |

Attention : dans cette liste, le commit le plus **ancien** est **en haut** (l'inverse de `git log`).
</details>

<details>
<summary>Indice 2 — la liste à obtenir</summary>

```text
reword f31aabc wip
fixup  d5773bc tri des taches par statut (non terminées d'abord)
fixup  b0a911a fix typo
pick   fb6e7b0 docs: documente le tri dans le README
drop   5b8d793 oups, fichier de debug
```
</details>

<details>
<summary>Indice 3 — en cas de souci</summary>

- Vous êtes perdu au milieu du rebase : `git rebase --abort` remet tout comme avant.
- Vous avez validé un mauvais résultat : `git reflog` montre les anciennes positions de la branche ; `git reset --hard <id>` permet d'y revenir (c'est pour cela qu'on s'entraîne sur un dépôt jetable).
</details>

## Question de réflexion

Si cette branche avait déjà été poussée sur GitHub et récupérée par un collègue, que se passerait-il après votre rebase ? Quelle commande devriez-vous utiliser pour pousser, et pourquoi est-ce risqué ?
