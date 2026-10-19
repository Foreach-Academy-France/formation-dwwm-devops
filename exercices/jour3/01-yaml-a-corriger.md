# Exercice 3.1 — YAML à corriger

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S3 — Bloc 3.5 (Docker Compose) et S4 — Bloc 4.1 (syntaxe YAML) |
| **Prérequis** | démos `demo-compose` et `demo-actions-hello` |
| **Fichiers fournis** | [`yaml-a-corriger/ci-casse.yml`](yaml-a-corriger/ci-casse.yml), [`yaml-a-corriger/compose-casse.yaml`](yaml-a-corriger/compose-casse.yaml) |

## Objectif

Le YAML est simple… jusqu'à ce qu'un espace de trop casse tout. Vous allez corriger deux fichiers que leurs outils refusent, en apprenant à **lire les messages d'erreur** et à reconnaître les pièges classiques.

### Rappel des règles du YAML

| Règle | Exemple correct |
|---|---|
| Une clé est suivie de `:` **puis un espace** | `runs-on: ubuntu-latest` |
| L'indentation se fait avec des **espaces**, jamais de tabulation | 2 espaces par niveau |
| Les éléments d'une **liste** commencent par `- ` | `- run: npm ci` |
| Un même bloc est **soit** une liste, **soit** un dictionnaire (clé: valeur), jamais les deux | |
| Un texte sur plusieurs lignes s'écrit avec `|` (retours à la ligne conservés) | `run: \|` puis lignes indentées |

## Consignes

### Partie A — Le fichier Compose (8 min)

1. Copiez le fichier dans un dossier de travail et lancez la validation :
   ```bash
   mkdir -p ~/exo-yaml && cp yaml-a-corriger/compose-casse.yaml ~/exo-yaml/compose.yaml
   cd ~/exo-yaml
   docker compose config
   ```
   (`docker compose config` lit le fichier, le valide et l'affiche « normalisé ». Il ne lance rien.)
2. Lisez le message : il indique un **numéro de ligne**. Corrigez l'erreur, relancez, recommencez jusqu'à ce que le fichier soit affiché sans erreur.
3. Listez dans un tableau chaque erreur trouvée (ligne, problème, correction). Il y en a **5**.
4. Une ligne a l'air mal indentée mais est **valide**. Laquelle ? Faut-il quand même la modifier ?

> Pour cette partie, `docker compose config` peut se plaindre que les dossiers `./api` et `./front` n'existent pas : créez-les vides (`mkdir api front`) pour que seule la syntaxe soit vérifiée.

### Partie B — Le workflow GitHub Actions (12 min)

5. Ouvrez `yaml-a-corriger/ci-casse.yml` dans VS Code. Activez l'affichage des espaces (*View → Render Whitespace*) : repérez la ligne qui contient une **tabulation**.
6. Trouvez et corrigez les erreurs. Il y en a **6** : 5 empêchent la lecture du fichier, **1** laisse un fichier valide mais produit un comportement faux (lisez attentivement le dernier step).
7. Vérifiez votre version avec un validateur au choix :
   - l'extension VS Code **GitHub Actions** (souligne les erreurs) ;
   - en ligne de commande, si `actionlint` est installé : `actionlint ci.yml` ;
   - à défaut, poussez-le dans un dépôt de test : l'onglet **Actions** affiche l'erreur exacte.

## Résultat attendu

- `docker compose config` affiche le fichier complet sans erreur, avec les services `db`, `api`, `front` et le volume `pgdata`.
- Votre `ci.yml` est accepté par le validateur ; le job `front` exécute **trois** commandes distinctes (`npm ci`, `npm test`, `npm run build`).

## Indices

<details>
<summary>Indice 1 — Compose</summary>

Cherchez : un `:` manquant, une liste `- CLE=valeur` mélangée avec `CLE: valeur` dans le même bloc, un service décalé d'**un** espace, un `depends_on` qui n'est ni une liste ni un dictionnaire, et une clé de premier niveau mal orthographiée (au singulier).
</details>

<details>
<summary>Indice 2 — workflow</summary>

Cherchez : un déclencheur sans `:` au milieu d'autres déclencheurs qui en ont, un `runs-on` sans `:`, une clé de `with:` décalée d'un espace, une tabulation, des `steps:` du job `front` dont le premier élément n'est pas une liste.
</details>

<details>
<summary>Indice 3 — l'erreur « silencieuse »</summary>

Sans `|`, YAML **replie** les lignes en une seule : `run:` devient `npm ci npm test npm run build`, c'est-à-dire **une seule** commande `npm ci` avec des arguments bizarres. Le fichier est valide, mais les tests et le build ne sont jamais lancés.
</details>
