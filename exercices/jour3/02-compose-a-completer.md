# Exercice 3.2 — Le `compose.yaml` de TaskFlow à compléter

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S3 — Blocs 3.5 (Docker Compose) et 3.6 (base de données conteneurisée) ; prépare l'étape 2 du fil rouge |
| **Prérequis** | exercice 3.1 ; démo `demo-compose` ; un dépôt `taskflow` avec `api/Dockerfile` et `front/Dockerfile` (étape 1 du fil rouge) pour la partie test |
| **Fichiers fournis** | [`compose-a-trous.yaml`](compose-a-trous.yaml), [`.env.example`](.env.example) |

## Objectif

Compléter un `compose.yaml` qui démarre **toute** l'application TaskFlow (base, API, front) en une commande, avec un volume, des healthchecks, un ordre de démarrage fiable et un mot de passe lu depuis `.env`.

## Consignes

1. Ouvrez [`compose-a-trous.yaml`](compose-a-trous.yaml). Chaque `___` correspond à un numéro de question. Écrivez vos réponses dans un tableau **avant** de modifier le fichier :

   | N° | Question | Votre réponse |
   |---|---|---|
   | 1 | Image Postgres 16 alpine, nom complet | |
   | 2 | Nom du volume des données | |
   | 3 | Commande Postgres qui teste si la base est prête | |
   | 4 | Faut-il publier le port 5432 de `db` ? Pourquoi ? | |
   | 5 | Dossier de build de l'API | |
   | 6 | Port d'écoute de l'API | |
   | 7 | Hôte de la base vu depuis le conteneur `api` | |
   | 8 | Condition de `depends_on` | |
   | 9 | Route de santé de l'API | |
   | 10 | Politique de redémarrage | |
   | 11 | Port publié du front | |
   | 12 | Service dont dépend le front | |
   | 13 | Clé de premier niveau des volumes | |
   | 14 | Nom du volume | |

2. Complétez le fichier, puis copiez-le à la racine de votre dépôt `taskflow` sous le nom `compose.yaml`, avec le fichier d'exemple d'environnement :
   ```bash
   cp compose-a-trous.yaml ~/taskflow/compose.yaml
   cp .env.example ~/taskflow/.env.example
   cd ~/taskflow
   cp .env.example .env              # puis changez le mot de passe dans .env
   grep -n '^\.env$' .gitignore      # .env doit être ignoré par Git !
   ```
3. Validez **sans rien lancer** : `docker compose config`. Il ne doit plus rester un seul `___`.
4. Que se passe-t-il si vous supprimez temporairement `.env` et relancez `docker compose config` ? À quoi sert la syntaxe `${POSTGRES_PASSWORD:?…}` ?
5. Lancez la stack et suivez le démarrage :
   ```bash
   docker compose up -d --build
   docker compose ps
   ```
   Observez dans quel ordre les services passent à `healthy`.
6. Testez : `curl http://localhost:8080/health` puis ouvrez http://localhost:8080 et créez une tâche.
7. Faites `docker compose down` puis `docker compose up -d` : la tâche est-elle toujours là ? Et après `docker compose down -v` ?

## Résultat attendu

```text
$ docker compose ps
NAME               SERVICE   STATUS                    PORTS
taskflow-db-1      db        Up 30 seconds (healthy)   5432/tcp
taskflow-api-1     api       Up 25 seconds (healthy)   3000/tcp
taskflow-front-1   front     Up 10 seconds             0.0.0.0:8080->80/tcp

$ curl http://localhost:8080/health
{"status":"ok","db":"up","version":"dev","env":"local"}
```

Seul le front publie un port. Les données survivent à `down` mais pas à `down -v`.

## Indices

<details>
<summary>Indice 1 — les noms</summary>

Dans Compose, chaque **nom de service** (`db`, `api`, `front`) devient un nom d'hôte sur le réseau créé automatiquement : c'est ce nom qu'on met dans `DATABASE_URL`. Le volume s'appelle comme vous voulez, mais **le même nom** aux questions 2 et 14 (par exemple `pgdata`).
</details>

<details>
<summary>Indice 2 — santé et redémarrage</summary>

- L'outil Postgres de test de connexion s'appelle `pg_isready`.
- Les trois conditions possibles de `depends_on` sont `service_started`, `service_healthy` et `service_completed_successfully`.
- Les politiques de `restart` : `no`, `always`, `on-failure`, `unless-stopped`.
</details>

<details>
<summary>Indice 3 — le port de la base</summary>

Qui a besoin de joindre la base ? Uniquement le conteneur `api`, **via le réseau interne** de Compose. Publier `5432` l'exposerait sur votre machine (et sur un serveur, potentiellement à Internet). On peut l'ajouter **temporairement** pour se connecter avec un client graphique, mais pas par défaut.
</details>
