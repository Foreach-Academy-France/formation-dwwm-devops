# Démo — Premier workflow GitHub Actions

| | |
|---|---|
| **Jour / bloc** | J3 après-midi — Bloc 4.1 « GitHub Actions : concepts » |
| **Durée** | 20 min |
| **Prérequis** | un compte GitHub, [GitHub CLI](https://cli.github.com/) authentifié (`gh auth login`) pour la variante automatique ; un vidéoprojecteur sur l'onglet *Actions* |
| **Ce qu'on montre** | workflow / événement / job / step / runner / action ; syntaxe YAML (indentation, listes, clés) ; déclencheurs `push`, `pull_request`, `workflow_dispatch`, `schedule` (commenté) ; contextes `${{ github.* }}` ; `needs` ; sorties de step ; résumé du run ; un job qui échoue |

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `hello.yml` | workflow commenté ligne à ligne, à copier dans `.github/workflows/` d'un dépôt de test |
| `demo.sh` | prépare un dépôt jetable avec le workflow ; avec `DEMO_GH_REPO`, crée le dépôt privé sur GitHub, pousse et suit le run |

`hello.yml` est validé avec [actionlint](https://github.com/rhysd/actionlint) (`nix run nixpkgs#actionlint -- hello.yml` ou `docker run --rm -v "$PWD:/repo" -w /repo docker.io/rhysd/actionlint:1.7.12 hello.yml`).

## Préparer (avant la séance)

```bash
# Variante automatique : crée le dépôt privé « hello-actions-demo » et pousse
DEMO_GH_REPO=hello-actions-demo bash demos/demo-actions-hello/demo.sh

# Variante manuelle (si vous préférez tout taper devant la salle)
gh repo create hello-actions-demo --private --clone && cd hello-actions-demo
mkdir -p .github/workflows && cp ../demos/demo-actions-hello/hello.yml .github/workflows/
git add . && git commit -m "ci: premier workflow hello" && git push
```

Après la séance : `gh repo delete hello-actions-demo --yes`.

## Déroulé minuté

| Min | Dire | Taper / montrer | Question à poser à la salle |
|---|---|---|---|
| 0-4 | « Un workflow est un fichier YAML dans `.github/workflows/`. GitHub le lit à chaque événement. » Rappel YAML : indentation = 2 espaces, **jamais** de tabulation ; `clé: valeur` ; `- ` = élément de liste ; `\|` = bloc multi-ligne. | `hello.yml` à l'écran, repérer `on`, `jobs`, `steps` | « Combien de jobs ? Combien de steps dans le premier ? » |
| 4-7 | « `on:` = les événements. Ici : push sur `main`, toute PR, et un bouton manuel avec un paramètre. » | Bloc `on:` ; `schedule` commenté | « Si je pousse sur une branche `feature/x` sans PR, le workflow se lance-t-il ? » (non) |
| 7-10 | « Le push a déclenché un **run**. Chaque job tourne sur un **runner** : une VM Ubuntu neuve, détruite après. » | Onglet *Actions* → le run → le job `hello` → déplier les steps | « Pourquoi faut-il `actions/checkout` pour voir nos fichiers ? » (la VM est vide au départ) |
| 10-12 | « Les `${{ … }}` sont des **expressions** évaluées par GitHub avant l'exécution. » | Step « Qui m'a déclenché ? » | « D'où vient la valeur de `github.actor` ? » |
| 12-14 | « `uses:` = une **action** (code réutilisable) ; `run:` = une commande shell. » | Step checkout ; step `ls -la` | « Où trouver d'autres actions ? » (Marketplace) |
| 14-16 | « `needs: hello` : le job `tests` attend. Sans `needs`, les jobs tournent **en parallèle**. » | Le graphe des jobs en haut du run ; le résumé (`GITHUB_STEP_SUMMARY`) | « Pour TaskFlow, quels jobs pourraient tourner en parallèle ? » (lint et tests ; front et api) |
| 16-18 | « Déclenchement manuel : bouton *Run workflow* avec le paramètre. » | `gh workflow run hello.yml -f prenom=Alice` ou le bouton | « À quoi cela servira-t-il au J4 ? » (rollback : redéployer un tag) |
| 18-20 | « Un step qui renvoie un code ≠ 0 fait **échouer** le job (croix rouge) et les jobs qui en dépendent. » | Décommenter `exit 1`, commit dans une PR → check rouge sur la PR | « Que voit le relecteur de la PR ? Doit-il fusionner ? » (transition vers les checks requis) |

## Pièges à anticiper

- Fichier hors de `.github/workflows/` ou extension `.yaml`/`.yml` oubliée : rien ne se passe, aucun message d'erreur.
- Erreur d'indentation : GitHub affiche *Invalid workflow file* dans l'onglet Actions avec le numéro de ligne → bonne occasion de montrer la lecture de l'erreur.
- `workflow_dispatch` n'apparaît qu'une fois le workflow présent sur la **branche par défaut**.
- Les minutes Actions sont gratuites et illimitées pour les dépôts publics, limitées (2 000 min/mois) pour les privés : suffisant pour la formation.
