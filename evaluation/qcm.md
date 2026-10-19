# QCM — Formation DWWM DevOps

**Nom :** ______________________ **Prénom :** ______________________ **Date :** ____ / ____ / ________

**Durée** : 15 minutes · **Questions** : 20 · **Évaluation formative** (non bloquante)

> Chaque question comporte **une seule bonne réponse** parmi les quatre propositions (A, B, C, D).
> Reportez vos réponses dans la **grille en fin de document**. Aucune pénalité pour une mauvaise réponse.
> Les exemples s'appuient sur le projet fil rouge **TaskFlow** (API Node 20 + Express + PostgreSQL 16, front Vite servi par nginx).

---

## Séquence 1 — Introduction au DevOps

**1.** Quelle est la différence entre **livraison continue** (*continuous delivery*) et **déploiement continu** (*continuous deployment*) ?

- A. La livraison continue concerne le front, le déploiement continu concerne l'API.
- B. En livraison continue, l'application est toujours prête à être mise en production mais un humain déclenche la mise en prod ; en déploiement continu, chaque changement validé part en production sans intervention humaine.
- C. La livraison continue se fait par FTP, le déploiement continu par Git.
- D. Il n'y a aucune différence, ce sont deux traductions du même terme.

---

**2.** Que signifie l'acronyme **CALMS**, souvent utilisé pour décrire la culture DevOps ?

- A. Cloud, Agile, Linux, Monitoring, Sécurité
- B. Code, Automatisation, Logs, Merge, Serveur
- C. Culture, Automatisation, Lean, Mesure, Partage
- D. Conteneurs, Actions, Load-balancing, Métriques, Sécurité

---

**3.** Qu'est-ce que l'**intégration continue** (CI) ?

- A. Intégrer souvent son travail dans la branche principale, avec une vérification automatique (lint, tests, build) à chaque push ou PR.
- B. Déployer l'application en production toutes les nuits.
- C. Travailler sur une branche personnelle pendant plusieurs semaines avant de la fusionner.
- D. Installer automatiquement les mises à jour du système d'exploitation du serveur.

---

## Séquence 2 — Git avancé et travail collaboratif

**4.** Que fait la commande `git switch -c feature/health` ?

- A. Elle supprime la branche `feature/health`.
- B. Elle fusionne la branche `feature/health` dans la branche courante.
- C. Elle envoie la branche `feature/health` sur GitHub.
- D. Elle crée la branche `feature/health` et se place dessus.

---

**5.** Lors d'un conflit, vous lisez ceci dans `index.html` :

```
<<<<<<< HEAD
<li>Alice</li>
=======
<li>Bruno</li>
>>>>>>> feature/carte-bruno
```

Que représente la ligne `<li>Alice</li>` ?

- A. La version de la branche que vous êtes en train de fusionner (`feature/carte-bruno`).
- B. La version d'origine, avant les deux modifications.
- C. La version de la branche sur laquelle vous êtes placé (HEAD), avant la fusion.
- D. Une ligne ajoutée automatiquement par Git pour résoudre le conflit.

---

**6.** Quelle est la « règle d'or » du `git rebase` ?

- A. Ne jamais rebaser une branche déjà partagée (poussée et utilisée par d'autres personnes).
- B. Toujours rebaser `main` sur sa branche de fonctionnalité.
- C. Ne rebaser qu'après avoir créé un tag.
- D. Rebaser uniquement avec l'option `--force`.

---

**7.** TaskFlow est en version `v1.4.2` (SemVer). Vous corrigez un bug sans changer l'API ni ajouter de fonctionnalité. Quelle est la nouvelle version ?

- A. `v2.0.0`
- B. `v1.4.3`
- C. `v1.5.0`
- D. `v1.4.2-fix`

---

## Séquence 3 — Docker

**8.** Quelle phrase décrit correctement la relation entre une **image** et un **conteneur** Docker ?

- A. Une image est un conteneur arrêté.
- B. Un conteneur est un fichier `.zip` qui contient une image.
- C. Une image est une machine virtuelle complète avec son propre noyau.
- D. Une image est un modèle en lecture seule ; un conteneur est une instance de cette image en cours d'exécution (comme un objet créé à partir d'une classe).

---

**9.** Dans `api/Dockerfile`, pourquoi écrit-on `COPY package*.json ./` puis `RUN npm ci --omit=dev` **avant** `COPY . .` ?

- A. Pour profiter du cache : tant que `package.json` / `package-lock.json` ne changent pas, Docker réutilise la couche `npm ci` et le build est beaucoup plus rapide.
- B. Parce que Docker refuse de copier plus de deux fichiers à la fois.
- C. Pour que les fichiers `.env` soient inclus dans l'image.
- D. Parce que `npm ci` doit toujours être la dernière instruction d'un Dockerfile.

---

**10.** Que fait l'option `-p 8080:80` dans `docker run -p 8080:80 docker.io/library/nginx:1.27-alpine` ?

- A. Elle limite le conteneur à 80 % du CPU et 8080 Mo de RAM.
- B. Elle redirige le port 80 de l'hôte vers le port 8080 du conteneur.
- C. Elle publie le port 80 du conteneur sur le port 8080 de votre machine (hôte).
- D. Elle lance 80 conteneurs nginx sur le port 8080.

---

**11.** Vous lancez PostgreSQL avec `docker run -d --name db docker.io/library/postgres:16-alpine`, vous créez des tâches, puis vous faites `docker rm -f db` et relancez la même commande : vos tâches ont disparu. Pourquoi ?

- A. PostgreSQL 16 efface sa base à chaque démarrage.
- B. Il fallait utiliser `docker stop` au lieu de `docker rm`.
- C. L'image `postgres:16-alpine` est en lecture seule.
- D. Aucun volume n'était monté sur `/var/lib/postgresql/data` : les données vivaient dans la couche du conteneur, supprimée avec lui.

---

**12.** Dans le `compose.yaml` de TaskFlow, le service `api` doit se connecter au service `db`. Quelle valeur de `DATABASE_URL` est correcte ?

- A. `postgres://taskflow:taskflow@localhost:5432/taskflow`
- B. `postgres://taskflow:taskflow@db:5432/taskflow`
- C. `postgres://taskflow:taskflow@127.0.0.1:3000/taskflow`
- D. `postgres://taskflow:taskflow@taskflow.localhost:8080/taskflow`

---

## Séquence 4 — CI/CD avec GitHub Actions

**13.** Où doit se trouver un fichier de workflow GitHub Actions pour être pris en compte ?

- A. Dans `.github/workflows/`, avec l'extension `.yml` ou `.yaml`.
- B. À la racine du dépôt, sous le nom `Jenkinsfile`.
- C. Dans `api/tests/`.
- D. Dans les paramètres du dépôt (*Settings*), il n'y a pas de fichier.

---

**14.** Dans un workflow, que signifie `needs: test` sur le job `build` ?

- A. Le job `build` s'exécute en parallèle du job `test`.
- B. Le job `build` installe automatiquement les dépendances de test.
- C. Le job `build` est ignoré si le job `test` existe.
- D. Le job `build` attend que le job `test` se termine **avec succès** avant de démarrer.

---

**15.** *(Théorie — vrai serveur)* Sur un vrai serveur distant, le job de déploiement se connecterait en SSH et aurait besoin d'une clé SSH privée. Quelle est la bonne pratique ?

- A. L'écrire directement dans `release.yml`, le dépôt étant privé.
- B. La mettre dans un fichier `deploy/id_ed25519` commité dans le dépôt.
- C. L'enregistrer comme **secret** du dépôt (*Settings → Secrets and variables → Actions*), par exemple `SSH_PRIVATE_KEY`, et l'utiliser avec `${{ secrets.SSH_PRIVATE_KEY }}`.
- D. La passer dans une variable `vars.SSH_PRIVATE_KEY`, visible dans les logs.

---

**16.** Pourquoi le job `deploy` de TaskFlow utilise-t-il `runs-on: [self-hosted, lab]` plutôt que `ubuntu-latest` ?

- A. Parce que les runners GitHub ne savent pas exécuter `docker compose`.
- B. Parce que la « prod » (`taskflow-prod`) tourne sur votre poste, injoignable depuis les serveurs de GitHub ; le runner self-hosted, lui, tourne sur votre poste, va chercher les jobs chez GitHub et pilote le Docker local (socket monté) pour mettre à jour la stack.
- C. Parce que `ubuntu-latest` est payant pour les dépôts publics.
- D. Parce que les secrets ne sont disponibles que sur un runner self-hosted.

---

## Séquence 5 — Déploiement d'une application

**17.** Dans `compose.prod.yaml`, quel est le rôle du conteneur `proxy` (Nginx configuré en **reverse proxy**) ?

- A. Être le seul service qui publie des ports (80/443), gérer le HTTPS (certificat TLS) et transmettre les requêtes au service `front` (`proxy_pass http://front:80`).
- B. Compiler le front Vite à chaque requête.
- C. Remplacer PostgreSQL pour stocker les tâches.
- D. Envoyer les images Docker sur ghcr.io.

---

**18.** Que faire du fichier `.env` de la « prod » (mot de passe PostgreSQL, tag d'image…) ?

- A. Le commiter dans le dépôt pour que le CI puisse le lire.
- B. Le copier dans l'image Docker de l'API avec `COPY .env .`.
- C. Le publier dans le README pour que l'équipe le retrouve.
- D. Le créer uniquement dans le dossier de déploiement (`~/taskflow-prod/.env`), protégé par `chmod 600`, jamais dans Git ; seul `.env.example` (sans valeurs sensibles) est versionné.

---

## Séquence 6 — Supervision et bonnes pratiques

**19.** Après un merge, `https://taskflow.localhost` affiche **502 Bad Gateway**. Quelle démarche de diagnostic est la plus méthodique ?

- A. Redémarrer l'ordinateur, puis attendre de voir si le problème revient.
- B. Partir du symptôme et suivre le chemin de la requête : logs du conteneur `proxy` (Nginx) → `docker compose ps` (état des conteneurs) → `docker compose logs api` → cause → correction.
- C. Annuler tous les commits de la semaine avec `git reset --hard`.
- D. Supprimer le volume PostgreSQL pour repartir de zéro.

---

**20.** L'endpoint `GET /health` de l'API TaskFlow répond `503` avec `{"status":"ok","db":"down",...}`. Que pouvez-vous en conclure ?

- A. L'API est arrêtée.
- B. Nginx est mal configuré.
- C. Le processus de l'API tourne, mais il n'arrive pas à joindre la base de données PostgreSQL.
- D. Tout fonctionne : 503 est un code de succès.

---

## Grille de réponses

Cochez **une seule case** par question.

| N° | A | B | C | D | | N° | A | B | C | D |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | ☐ | ☐ | ☐ | ☐ | | 11 | ☐ | ☐ | ☐ | ☐ |
| 2 | ☐ | ☐ | ☐ | ☐ | | 12 | ☐ | ☐ | ☐ | ☐ |
| 3 | ☐ | ☐ | ☐ | ☐ | | 13 | ☐ | ☐ | ☐ | ☐ |
| 4 | ☐ | ☐ | ☐ | ☐ | | 14 | ☐ | ☐ | ☐ | ☐ |
| 5 | ☐ | ☐ | ☐ | ☐ | | 15 | ☐ | ☐ | ☐ | ☐ |
| 6 | ☐ | ☐ | ☐ | ☐ | | 16 | ☐ | ☐ | ☐ | ☐ |
| 7 | ☐ | ☐ | ☐ | ☐ | | 17 | ☐ | ☐ | ☐ | ☐ |
| 8 | ☐ | ☐ | ☐ | ☐ | | 18 | ☐ | ☐ | ☐ | ☐ |
| 9 | ☐ | ☐ | ☐ | ☐ | | 19 | ☐ | ☐ | ☐ | ☐ |
| 10 | ☐ | ☐ | ☐ | ☐ | | 20 | ☐ | ☐ | ☐ | ☐ |

**Score : ______ / 20**
