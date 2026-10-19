# Exercice 1.2 — Kata : résoudre un conflit de fusion

| | |
|---|---|
| **Durée** | 15 min (à refaire deux fois si vous avez le temps : c'est un *kata*, on répète le geste) |
| **Séquence** | S2 — Bloc 2.4 (conflits) |
| **Prérequis** | exercice 1.1 ; VS Code conseillé (mais pas obligatoire) |
| **Fichiers fournis** | [`kata-conflit-setup.sh`](kata-conflit-setup.sh) |

## Objectif

Provoquer, lire et résoudre un conflit, exactement comme celui du TP 1 (tout le monde ajoute sa ligne dans le même `<ul>`), mais seul et sans risque : le dépôt est jetable.

## Mise en place

```bash
bash kata-conflit-setup.sh
```

Le script crée un dépôt temporaire et affiche son chemin (par exemple `/tmp/kata-conflit.Ab12Cd`). Placez-vous dedans avec la commande `cd` qu'il affiche.

Le dépôt contient trois branches :

| Branche | Contenu |
|---|---|
| `main` | `index.html` avec une liste de deux apprenants (Karim, Léa) |
| `feature/carte-alice` | ajoute `<li>Alice</li>` après Léa |
| `feature/carte-bob` | ajoute `<li>Bob</li>` après Léa — **au même endroit** |

## Consignes

1. Affichez le graphe des branches : `git log --oneline --graph --all`. Dessinez-le sur papier.
2. Depuis `main`, fusionnez `feature/carte-alice`. Quel type de fusion Git effectue-t-il ?
3. Fusionnez maintenant `feature/carte-bob`. Git annonce un conflit : **ne paniquez pas**. Lancez `git status` et notez ce qu'il affiche.
4. Ouvrez `index.html` (avec `cat`, `nano` ou VS Code). Repérez les trois marqueurs `<<<<<<<`, `=======` et `>>>>>>>`. Pour chaque bloc, indiquez d'où vient le contenu.
5. Résolvez le conflit : la liste finale doit contenir **Karim, Léa, Alice, Bob** dans cet ordre, sans aucun marqueur.
6. Indiquez à Git que le conflit est résolu, puis terminez la fusion.
7. Affichez le graphe final.
8. Vérifiez qu'il ne reste aucun marqueur dans le dépôt : `git grep -n '<<<<<<<\|>>>>>>>'` ne doit rien afficher.
9. Nettoyage : revenez dans votre dossier personnel et supprimez le dossier temporaire (commande affichée par le script).

## Résultat attendu

```html
  <ul>
    <li>Karim</li>
    <li>Léa</li>
    <li>Alice</li>
    <li>Bob</li>
  </ul>
```

```text
*   1ede807 (HEAD -> main) Merge branch 'feature/carte-bob'
|\
| * 5f36a2b (feature/carte-bob) feat: ajoute la carte de Bob
* | 01bfe10 (feature/carte-alice) feat: ajoute la carte d'Alice
|/
* c3e504b feat: page de la promo avec deux apprenants
```

(Les identifiants de commit sont différents à chaque exécution du script.)

## Indices

<details>
<summary>Indice 1 — lire les marqueurs</summary>

Entre `<<<<<<< HEAD` et `=======` : la version de la branche **sur laquelle vous êtes** (`main`, qui contient déjà Alice). Entre `=======` et `>>>>>>> feature/carte-bob` : la version **qui arrive**. Résoudre, c'est écrire à la main la version finale et supprimer les trois lignes de marqueurs.
</details>

<details>
<summary>Indice 2 — terminer la fusion</summary>

Une fois le fichier corrigé et enregistré : `git add index.html` (« ce fichier est résolu »), puis `git commit` (Git propose déjà un message `Merge branch ...` : enregistrez et quittez l'éditeur).
</details>

<details>
<summary>Indice 3 — tout annuler pour recommencer</summary>

En plein conflit, `git merge --abort` remet le dépôt dans l'état d'avant la fusion. Pratique pour refaire le kata.
</details>

## Question de réflexion

Pourquoi Git n'a-t-il pas pu décider tout seul ? Dans quel cas deux personnes qui modifient le même fichier **ne** provoquent **pas** de conflit ?
