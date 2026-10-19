# Démo — Premiers pas avec Docker

| | |
|---|---|
| **Jour / bloc** | J2 matin — Bloc 3.2 « Docker Engine et images » |
| **Durée** | 20 min |
| **Prérequis** | Docker (ou Podman) fonctionnel, `curl`, ports **8081** et **8082** libres (sinon `DEMO_PORT=8090`) ; images pré-téléchargées si le Wi-Fi est faible (voir ci-dessous) |
| **Ce qu'on montre** | client/daemon/registre ; image vs conteneur (classe vs instance) ; `run`, `ps`, `logs`, `exec`, `stop`, `rm` ; ports `-p` ; données éphémères ; bind mount ; même noyau que l'hôte |

## Lancer

```bash
bash demos/demo-docker-premiers-pas/demo.sh
DEMO_PORT=8090 bash demos/demo-docker-premiers-pas/demo.sh   # si 8081/8082 sont pris
DEMO_AUTO=1 bash demos/demo-docker-premiers-pas/demo.sh      # test sans pause
```

Avant le cours (réseau de salle souvent lent) :

```bash
docker pull docker.io/library/hello-world:latest
docker pull docker.io/library/nginx:1.27-alpine
docker pull docker.io/library/alpine:3.21
```

Le script supprime ses conteneurs (`demo-dpp-*`) à la fin, même en cas d'interruption (Ctrl+C). Les images restent en cache pour la suite de la journée.

## Déroulé minuté

| Min | Étape | Dire | Taper / montrer | Question à poser à la salle |
|---|---|---|---|---|
| 0-2 | 1 | « `docker` est un **client** qui parle à un **daemon** ; les images viennent d'un **registre** (Docker Hub, ghcr.io). » | `docker version` | « Où sont stockées les images que je télécharge ? » |
| 2-5 | 2 | « `run` = télécharger l'image si besoin + créer + démarrer un conteneur. » | Sortie de hello-world ; `ps -a` montre `Exited (0)` | « Pourquoi le conteneur est-il arrêté ? » (son processus principal est terminé) |
| 5-8 | 3 | « `-d` = en arrière-plan ; `-p 8081:80` = port de l'hôte → port du conteneur. » | Navigateur sur http://localhost:8081 | « Dans `-p 8081:80`, lequel est le port du conteneur ? Et pour TaskFlow, que mettrait-on pour l'API ? » (`-p 3000:3000`) |
| 8-11 | 4 | « `logs` = la sortie standard du processus ; `exec` = lancer une commande **dans** un conteneur qui tourne. » | Logs d'accès, `os-release` (Alpine), modification de la page | « Le conteneur est sous Alpine, ma machine non : comment est-ce possible ? » |
| 11-13 | 5 | « Image = **classe**, conteneur = **instance**. Deux instances, deux états. » | Le 2e conteneur affiche la page d'origine | « Si je modifie un conteneur, l'image est-elle modifiée ? » (non) |
| 13-15 | 6 | « Supprimer le conteneur = perdre ses données. Pour une base de données, c'est un drame. » | Page d'origine revenue | « Que se passerait-il pour Postgres sans volume ? » → bloc 3.4 |
| 15-17 | 7 | « Un *bind mount* monte un dossier de l'hôte : pratique en dev. » | Page servie depuis `/tmp/...` | « Quelle différence avec un volume nommé ? » |
| 17-19 | 8 | « `--rm` = conteneur jetable. Même `uname -r` : le noyau est **partagé**. » | Comparer les deux `uname -r` | « Pourquoi un conteneur démarre-t-il en 1 s alors qu'une VM met 30 s ? » |
| 19-20 | 9 | Récapitulatif du cycle de vie. | `images`, `stop`, `rm` | « Différence entre `stop` et `rm` ? » |

## Pièges à anticiper

- **Podman** : le `:Z` du bind mount sert à SELinux (Fedora) ; il est ignoré ailleurs. `docker version` peut afficher un format différent : le script retombe sur `docker --version`.
- **Port déjà utilisé** (`address already in use`) : relancer avec `DEMO_PORT=8090`.
- **Docker Desktop** arrêté : `Cannot connect to the Docker daemon` → c'est l'occasion d'illustrer client/daemon.
- Insistez sur les noms d'image **pleinement qualifiés** (`docker.io/library/nginx:1.27-alpine`) : registre / dépôt / tag. Jamais `latest` en production.
