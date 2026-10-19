# Exercice 2.4 — Prouver que les données survivent : volume et réseau

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S3 — Bloc 3.4 (volumes, réseaux, variables d'environnement) ; prépare l'étape 1 du fil rouge |
| **Prérequis** | Docker fonctionnel ; ports `5432` libres (sinon adaptez `-p`) |
| **Fichiers fournis** | aucun |

## Objectif

Lancer la base PostgreSQL 16 de TaskFlow dans un conteneur, sur un **réseau** Docker, avec un **volume nommé**, et **démontrer** que les tâches survivent à la suppression du conteneur. Vous verrez aussi qu'un second conteneur joint la base **par son nom**.

## Consignes

### Partie A — Sans volume (2 min, pour voir le problème)

1. Lancez une base jetable, créez une table, supprimez le conteneur, relancez-en un autre :
   ```bash
   docker run -d --name db-sans-volume -e POSTGRES_PASSWORD=test docker.io/library/postgres:16-alpine
   sleep 5
   docker exec db-sans-volume psql -U postgres -c "CREATE TABLE preuve(id int);"
   docker rm -f db-sans-volume
   docker run -d --name db-sans-volume -e POSTGRES_PASSWORD=test docker.io/library/postgres:16-alpine
   sleep 5
   docker exec db-sans-volume psql -U postgres -c "\dt"
   docker rm -f db-sans-volume
   ```
   Que contient la dernière sortie ?

### Partie B — Avec réseau et volume nommé

2. Créez le réseau `taskflow-net` et le volume `taskflow-pgdata`.
3. Lancez Postgres avec ces caractéristiques :
   - nom du conteneur : `taskflow-db` ;
   - réseau : `taskflow-net` ;
   - volume `taskflow-pgdata` monté sur `/var/lib/postgresql/data` ;
   - variables : `POSTGRES_USER=taskflow`, `POSTGRES_PASSWORD=taskflow`, `POSTGRES_DB=taskflow` ;
   - port `5432` publié sur votre machine ;
   - image : `docker.io/library/postgres:16-alpine`.
4. Attendez que la base soit prête : `docker logs taskflow-db` doit afficher `database system is ready to accept connections`.
5. Créez la table de TaskFlow et ajoutez deux tâches :
   ```bash
   docker exec -i taskflow-db psql -U taskflow -d taskflow <<'SQL'
   CREATE TABLE IF NOT EXISTS tasks (
     id SERIAL PRIMARY KEY,
     title TEXT NOT NULL,
     done BOOLEAN DEFAULT false,
     created_at TIMESTAMPTZ DEFAULT now()
   );
   INSERT INTO tasks (title) VALUES ('Écrire le Dockerfile'), ('Tester le volume');
   SQL
   ```
6. **Supprimez** le conteneur `taskflow-db` (`docker rm -f`). Vérifiez que le volume existe toujours (`docker volume ls`).
7. Relancez **exactement** la même commande qu'à l'étape 3, puis affichez les tâches : `SELECT id, title, done FROM tasks;`.
8. Depuis un **autre** conteneur placé sur le même réseau, connectez-vous à la base en utilisant le nom `taskflow-db` comme hôte :
   ```bash
   docker run --rm --network taskflow-net -e PGPASSWORD=taskflow \
     docker.io/library/postgres:16-alpine \
     psql -h taskflow-db -U taskflow -d taskflow -c "SELECT count(*) FROM tasks;"
   ```
9. Refaites l'étape 8 **sans** `--network taskflow-net`. Que se passe-t-il ? Pourquoi ?
10. Nettoyage complet : conteneur, puis volume, puis réseau.

## Résultat attendu

```text
 id |        title         | done
----+----------------------+------
  1 | Écrire le Dockerfile | f
  2 | Tester le volume     | f
(2 rows)
```

… affiché **après** la suppression et la recréation du conteneur. L'étape 8 renvoie `count = 2` ; l'étape 9 échoue (`could not translate host name "taskflow-db"`).

## Indices

<details>
<summary>Indice 1 — créer réseau et volume</summary>

```bash
docker network create taskflow-net
docker volume create taskflow-pgdata
```
</details>

<details>
<summary>Indice 2 — les options de <code>docker run</code></summary>

`--name`, `--network`, `-v <volume>:<chemin>`, `-e CLE=valeur` (une option `-e` par variable), `-p 5432:5432`, et `-d` pour lancer en arrière-plan. L'image se met **en dernier**.
</details>

<details>
<summary>Indice 3 — l'ordre du nettoyage</summary>

Un volume ou un réseau utilisé par un conteneur ne peut pas être supprimé : supprimez d'abord le conteneur (`docker rm -f`), puis `docker volume rm`, puis `docker network rm`.
</details>

## Question de réflexion

Dans l'étape 1 du fil rouge, l'API tournera dans son propre conteneur. Que vaudra la variable `DATABASE_URL` de l'API : `postgres://taskflow:taskflow@localhost:5432/taskflow` ou `postgres://taskflow:taskflow@taskflow-db:5432/taskflow` ? Pourquoi ?
