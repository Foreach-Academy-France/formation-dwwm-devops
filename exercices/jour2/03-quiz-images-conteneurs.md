# Exercice 2.3 — Quiz : images, conteneurs, couches

| | |
|---|---|
| **Durée** | 10 min (puis 5 min de correction collective) |
| **Séquence** | S3 — Blocs 3.1 (VM vs conteneur), 3.2 (Docker Engine et images), 3.4 (volumes, réseaux, variables) |
| **Prérequis** | démo `demo-docker-premiers-pas` |
| **Fichiers fournis** | aucun |

## Objectif

Vérifier que le vocabulaire Docker est clair avant d'écrire le Dockerfile de TaskFlow. Une seule bonne réponse par question, sauf mention contraire. Répondez seul, **sans** chercher sur Internet, puis vérifiez certaines réponses dans le terminal.

---

**1.** Quelle analogie décrit le mieux la relation entre une image et un conteneur ?

- A. Une image est un conteneur arrêté.
- B. Une image est comme une **classe**, un conteneur comme une **instance** de cette classe.
- C. Une image est un fichier `.zip` du code source, le conteneur est le serveur.
- D. Ce sont deux mots pour la même chose.

**2.** Par rapport à une machine virtuelle, un conteneur :

- A. embarque son propre noyau Linux complet ;
- B. nécessite un hyperviseur comme VirtualBox ;
- C. est un processus isolé qui **partage le noyau** de la machine hôte ;
- D. ne peut exécuter qu'un seul langage.

**3.** Vous lancez `docker run -d -p 8080:80 docker.io/library/nginx:1.27-alpine`. À quelle adresse ouvrez-vous la page dans votre navigateur ?

- A. `http://localhost:80`
- B. `http://localhost:8080`
- C. `http://nginx:8080`
- D. `http://localhost:1.27`

**4.** Vous avez lancé un conteneur `docker.io/library/postgres:16-alpine` **sans volume**, créé une table, puis fait `docker rm -f` sur le conteneur. Vous en relancez un nouveau. La table :

- A. est toujours là, car l'image a été modifiée ;
- B. a disparu, car les données vivaient dans la couche inscriptible du conteneur supprimé ;
- C. est toujours là, car Postgres sauvegarde automatiquement sur Docker Hub ;
- D. est présente mais vide.

**5.** Quelle commande affiche **aussi** les conteneurs arrêtés ?

- A. `docker ps`
- B. `docker ps -a`
- C. `docker images`
- D. `docker logs`

**6.** Que fait `docker exec -it taskflow-db psql -U taskflow` ?

- A. Crée un nouveau conteneur à partir de l'image `psql`.
- B. Lance la commande `psql` **à l'intérieur** du conteneur déjà démarré `taskflow-db`, en mode interactif.
- C. Copie `psql` sur votre machine.
- D. Redémarre le conteneur `taskflow-db`.

**7.** Dans un Dockerfile, pourquoi copie-t-on `package.json` et `package-lock.json` **avant** le reste du code ?

- A. Parce que Docker refuse de copier plus de deux fichiers à la fois.
- B. Pour que la couche `npm ci` reste **en cache** tant que les dépendances ne changent pas : les reconstructions sont beaucoup plus rapides.
- C. Pour réduire la taille de l'image de moitié.
- D. C'est obligatoire pour que `EXPOSE` fonctionne.

**8.** Deux conteneurs `api` et `db` sont sur le même réseau Docker *bridge* personnalisé `taskflow-net`. Dans `DATABASE_URL`, quel hôte l'API doit-elle utiliser pour joindre Postgres ?

- A. `localhost`
- B. `127.0.0.1`
- C. `db` (le nom du conteneur, résolu par le DNS interne de Docker)
- D. l'adresse IP de votre box Internet

**9.** Où mettre le mot de passe de la base de données de TaskFlow ? (**deux** bonnes réponses)

- A. Dans le Dockerfile, avec `ENV POSTGRES_PASSWORD=...`.
- B. Au lancement, avec `-e POSTGRES_PASSWORD=...` ou `--env-file .env`.
- C. Dans un fichier `.env` **non versionné** (présent dans `.gitignore` et `.dockerignore`).
- D. Dans le `README.md` pour que l'équipe le retrouve.

**10.** L'image `docker.io/library/node:20-alpine` est-elle un meilleur choix que `docker.io/library/node:latest` pour l'API TaskFlow ? Pourquoi ?

- A. Non, `latest` est toujours la version la plus stable.
- B. Oui : la version de Node est **fixée** (même résultat demain qu'aujourd'hui) et l'image Alpine est beaucoup plus **légère**.
- C. Non, Alpine ne permet pas d'exécuter Node.
- D. C'est indifférent, Docker choisit automatiquement la bonne version.

---

## Vérifications dans le terminal (5 min)

Une fois le quiz rempli, vérifiez vous-même les questions 3, 5 et 6 :

```bash
docker run -d --name quiz-web -p 8080:80 docker.io/library/nginx:1.27-alpine
curl -I http://localhost:8080          # question 3
docker stop quiz-web
docker ps                              # question 5 : le conteneur a disparu de la liste…
docker ps -a                           # …mais il existe toujours
docker start quiz-web
docker exec -it quiz-web sh -c 'nginx -v; hostname'   # question 6 (même principe)
docker rm -f quiz-web
```

## Indices

<details>
<summary>Indice 1</summary>

Pour `-p`, la règle est toujours `-p <port de VOTRE machine>:<port DANS le conteneur>`.
</details>

<details>
<summary>Indice 2</summary>

Une image est **en lecture seule**. Tout ce qu'un conteneur écrit va dans sa propre couche, qui disparaît avec lui… sauf si le dossier est monté sur un **volume**.
</details>

Corrigé dans [`solutions.md`](solutions.md).
