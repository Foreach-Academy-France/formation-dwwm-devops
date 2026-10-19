# Démo — Branches, fast-forward et merge commit

| | |
|---|---|
| **Jour / bloc** | J1 après-midi — Bloc 2.2 « Branches et merge » |
| **Durée** | 15 min |
| **Prérequis** | Git ≥ 2.28 (pour `git init -b`), un terminal avec une police lisible (zoom ×2) |
| **Ce qu'on montre** | une branche est un pointeur ; fast-forward vs merge commit ; `git log --oneline --graph` comme outil de lecture |

## Lancer

```bash
bash demos/demo-git-branches/demo.sh              # avec pauses (en salle)
KEEP=1 bash demos/demo-git-branches/demo.sh       # conserve le dépôt /tmp pour le laisser explorer
DEMO_AUTO=1 bash demos/demo-git-branches/demo.sh  # sans pause (test avant le cours)
```

Le script crée un dépôt jetable avec `mktemp` dans `/tmp`, affiche chaque commande avant de l'exécuter, et supprime le dépôt à la fin.

## Déroulé minuté

| Min | Étape du script | Dire | Montrer | Question à poser à la salle |
|---|---|---|---|---|
| 0-2 | 1. Dépôt neuf | « On part de zéro : deux commits sur `main`, comme au début de TaskFlow. » | `git log --oneline --graph` : une ligne droite | « Que représente chaque ligne ? Que veut dire `HEAD -> main` ? » |
| 2-5 | 2. Créer une branche | « Une branche n'est qu'un **pointeur** (un fichier de 41 octets) vers un commit. Créer une branche est instantané. » | `cat .git/refs/heads/feature/health` affiche un SHA ; `git branch -v` | « Si je crée 50 branches, combien de fichiers du projet sont copiés ? » (réponse : aucun) |
| 5-7 | 3. Commit sur la branche | « Seul le pointeur de la branche courante avance. » | Le graphe : `feature/health` devant `main` | « Si je fais `git switch main` maintenant, la route `/health` est-elle dans `server.js` ? » |
| 7-9 | 4. Fast-forward | « `main` n'a pas bougé depuis la création de la branche : Git avance simplement l'étiquette. » | Sortie `Fast-forward`, historique toujours linéaire | « Pourquoi n'y a-t-il pas de commit de merge ? » |
| 9-12 | 5. Divergence | « Dans la vraie vie, quelqu'un d'autre a poussé sur `main` pendant que vous travailliez. » | Le graphe en « Y » | « Peut-on encore faire un fast-forward ? Pourquoi ? » |
| 12-14 | 6. Merge commit | « Git crée un commit à **deux parents**. C'est ce que fait le bouton *Merge pull request* de GitHub. » | `%p` affiche deux SHA | « Quel est l'avantage d'un historique qui montre la fusion ? Et l'inconvénient ? » (transition vers le rebase du J2) |
| 14-15 | 7. Ménage | « Une branche fusionnée se supprime : le travail est dans `main`. » | `git branch -d` | « Que se passe-t-il si on supprime une branche **non** fusionnée ? » (`-d` refuse, `-D` force) |

## Taper à la main (variante sans script)

Si la salle est à l'aise, rejouez les étapes 5 et 6 à la main dans le dépôt conservé (`KEEP=1`) en faisant deviner le graphe **avant** de lancer `git log --graph`.

## Pièges à anticiper

- Git < 2.28 : `git init -b main` échoue → `git init && git checkout -b main`.
- Un éditeur s'ouvre au merge : le script utilise `--no-edit`. À la main, expliquez que c'est le message du commit de merge (`:wq` sous vim, ou `git config --global core.editor "code --wait"`).
- Faire le lien : sur GitHub, *Squash and merge* et *Rebase and merge* sont d'autres stratégies, vues au J2.
