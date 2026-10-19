# Exercice 1.3 — Lire un historique `git log --graph`

| | |
|---|---|
| **Durée** | 15 min |
| **Séquence** | S2 — Bloc 2.1 (`git log --oneline --graph`) et Bloc 2.2 (fast-forward vs merge commit) |
| **Prérequis** | exercices 1.1 et 1.2 |
| **Fichiers fournis** | [`historique.txt`](historique.txt) (sortie de Git à lire), [`creer-historique.sh`](creer-historique.sh) (recrée le même dépôt pour vérifier vos réponses) |

## Objectif

Savoir lire un graphe d'historique : retrouver les branches, les fusions, les tags et l'endroit où pointe `HEAD`. C'est ce que vous ferez chaque fois que vous arriverez sur un projet existant.

## Le graphe à lire

Voici la sortie de `git log --oneline --graph --all --decorate` sur un petit dépôt TaskFlow (aussi disponible dans [`historique.txt`](historique.txt)) :

```text
* 93db9eb (feature/docker) build(api): ajoute un Dockerfile
* fd16415 (HEAD -> main, tag: v1.0.0, fix/titre-page) fix(front): corrige le titre de la page
*   3b7627e Merge branch 'feature/health'
|\  
| * 24df34a (feature/health) test(api): teste la route /health
| * f1f8d16 feat(api): ajoute la route GET /health
* | 057cd1f chore: ajoute le .gitignore
|/  
* 8f17968 feat(api): crée l'application Express
* 20bc9b4 chore: initialise le projet TaskFlow
```

> Rappel de lecture : le commit le plus **récent** est **en haut**. Chaque `*` est un commit, les traits `|`, `/` et `\` relient un commit à son ou ses parents.

## Consignes

Répondez **sans lancer de commande**, uniquement en lisant le graphe :

1. Combien de commits contient ce dépôt au total ?
2. Sur quelle branche êtes-vous actuellement ? Sur quel commit ?
3. Quel est le premier commit du projet ?
4. Quel commit est un *merge commit* ? Comment le reconnaissez-vous ? Quels sont ses deux parents ?
5. Pendant que `feature/health` était développée, un commit a été fait sur `main`. Lequel ?
6. La branche `fix/titre-page` a été fusionnée dans `main`. Était-ce un *fast-forward* ou un *merge commit* ? Justifiez.
7. Sur quel commit le tag `v1.0.0` est-il posé ? La version 1.0.0 contient-elle la route `/health` ? Et le Dockerfile ?
8. Quelle branche n'est pas encore fusionnée dans `main` ? Quelle commande l'intégrerait, et serait-ce un fast-forward ?
9. Quelles branches pourriez-vous supprimer sans rien perdre avec `git branch -d` ?

### Vérification sur un vrai dépôt (5 min)

```bash
bash creer-historique.sh --print
cd <chemin affiché>
```

Les identifiants sont **les mêmes** que ci-dessus (auteurs et dates sont fixés dans le script). Vérifiez vos réponses avec :

```bash
git log --oneline --graph --all --decorate
git show --stat 3b7627e          # détails du merge commit
git branch --merged main         # branches déjà fusionnées dans main
git log --oneline main..feature/docker   # commits de feature/docker absents de main
```

Supprimez le dossier temporaire à la fin.

## Résultat attendu

Neuf réponses courtes, vérifiées avec les commandes ci-dessus. Le corrigé est dans [`solutions.md`](solutions.md).

## Indices

<details>
<summary>Indice 1 — repérer un merge commit</summary>

Un merge commit a **deux parents** : dans le graphe, on voit deux traits qui se rejoignent sur lui (`|\` juste en dessous). Son message par défaut commence par `Merge branch`.
</details>

<details>
<summary>Indice 2 — fast-forward</summary>

Lors d'un fast-forward, Git ne crée **aucun** commit : il déplace juste l'étiquette de la branche. Résultat : deux étiquettes (`main` et `fix/titre-page`) se retrouvent sur **le même** commit, et aucun commit « Merge » n'apparaît.
</details>

<details>
<summary>Indice 3 — ce que contient un tag</summary>

Un tag désigne un commit **et tout ce qui est en dessous** (ses ancêtres). Ce qui est au-dessus (plus récent) n'en fait pas partie.
</details>
