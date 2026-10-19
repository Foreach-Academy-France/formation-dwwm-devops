# Exercice 3.3 — Lire un log d'échec CI

| | |
|---|---|
| **Durée** | 15 min |
| **Séquence** | S4 — Bloc 4.2 (pipeline de vérification, service container Postgres) |
| **Prérequis** | démo `demo-actions-hello` ; avoir vu un run dans l'onglet Actions |
| **Fichiers fournis** | [`log-ci-1.txt`](log-ci-1.txt), [`log-ci-2.txt`](log-ci-2.txt), [`ci-extrait.yml`](ci-extrait.yml) |

## Objectif

Quand une PR devient rouge, le réflexe n'est ni de relancer en espérant, ni d'appeler à l'aide : c'est de **lire le log** avec méthode. Vous allez diagnostiquer deux échecs réels du pipeline de TaskFlow.

### Méthode en 4 questions

1. **Quel job** et **quel step** ont échoué ? (cherchez `##[error]` et remontez)
2. Quelle est **la première** ligne d'erreur utile ? (pas la dernière : souvent la conséquence)
3. Qu'est-ce qui a **changé** dans la PR ?
4. Quelle est la **correction**, et **où** (code, lockfile, workflow) ?

## Consignes

### Log n° 1 — [`log-ci-1.txt`](log-ci-1.txt)

1. Quel step a échoué ? Les steps précédents ont-ils réussi ?
2. Recopiez la ligne qui explique **la cause**.
3. Quel fichier la PR a-t-elle modifié… et lequel a-t-elle oublié ?
4. Quelle commande l'auteur doit-il lancer **sur son poste**, et quel(s) fichier(s) doit-il commiter ?
5. Pourquoi ne pas simplement remplacer `npm ci` par `npm install` dans le workflow ?

### Log n° 2 — [`log-ci-2.txt`](log-ci-2.txt) et [`ci-extrait.yml`](ci-extrait.yml)

6. Les tests **unitaires** passent-ils ? Et les tests d'**intégration** ?
7. Recopiez l'erreur. Que signifie `ECONNREFUSED 127.0.0.1:5432` ?
8. Le service Postgres a-t-il bien démarré ? Citez la ligne qui le prouve.
9. Dans `ci-extrait.yml`, les steps tournent **directement sur la machine** du runner, pas dans un conteneur. Le service `postgres`, lui, tourne dans un conteneur. Que manque-t-il pour que `localhost:5432` mène au conteneur ?
10. Écrivez la correction du fichier `ci-extrait.yml`.

## Résultat attendu

Pour chaque log : le step en échec, la ligne-cause recopiée, la cause en une phrase, la correction précise. Le corrigé est dans [`solutions.md`](solutions.md).

## Indices

<details>
<summary>Indice 1 — log n° 1</summary>

`npm ci` installe **exactement** ce qui est écrit dans `package-lock.json` et refuse si `package.json` demande autre chose. Regardez la ligne `Missing: … from lock file` et la liste des fichiers modifiés tout en bas.
</details>

<details>
<summary>Indice 2 — log n° 2</summary>

`ECONNREFUSED` = « personne n'écoute à cette adresse et ce port ». Le conteneur Postgres écoute bien sur **son** port 5432, mais ce port n'est pas relié au port 5432 **de la machine** du runner.
</details>

<details>
<summary>Indice 3 — log n° 2, la clé manquante</summary>

Comme `-p` avec `docker run`, ou `ports:` dans Compose : un service de workflow accepte aussi une clé `ports:`.
</details>
