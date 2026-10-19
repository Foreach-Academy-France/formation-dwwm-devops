# Démo — Supervision avec Uptime Kuma

| | |
|---|---|
| **Jour / bloc** | J4 fin d'après-midi — Bloc 6.1 « Logs, monitoring, erreurs » |
| **Durée** | 15 min |
| **Prérequis** | Docker Compose, ports **3001** et **8088** libres (`KUMA_PORT`, `CIBLE_PORT`) ; image `louislam/uptime-kuma:1.23.16` pré-téléchargée (≈ 450 Mo) ; idéalement la stack `taskflow-prod` de l'étape 4 qui tourne pour l'étape 5 |
| **Ce qu'on montre** | supervision « de l'extérieur » (sonde HTTP sur `/health`) ; vérification par mot-clé ; détection d'une panne et rétablissement ; historique ; notifications et page de statut (montrées) ; lien avec le `/health` et les healthchecks de TaskFlow |

## Contenu du dossier

| Fichier | Rôle |
|---|---|
| `compose.yaml` | `uptime-kuma` (port 3001, volume `kuma-data`, `host.docker.internal` pour joindre la prod locale) + `cible` (nginx qui imite `GET /health` de l'API TaskFlow) |
| `cible/default.conf` | config nginx de la cible : `/health` → `{"status":"ok","db":"up",…}` |
| `demo.sh` | démarre, guide la configuration dans le navigateur, coupe et rétablit la cible, nettoie |

## Lancer

```bash
docker pull docker.io/louislam/uptime-kuma:1.23.16       # avant la séance
bash demos/demo-uptime-kuma/demo.sh
KEEP=1 bash demos/demo-uptime-kuma/demo.sh               # laisser Kuma tourner après la démo
DEMO_AUTO=1 bash demos/demo-uptime-kuma/demo.sh          # test sans pause (démarrage + coupure + nettoyage)
```

Uptime Kuma se configure **dans le navigateur** (pas de fichier de config) : le script fait des pauses pendant que vous cliquez.

## Mode d'emploi : surveiller `/health`

1. Ouvrir http://localhost:3001, créer le compte administrateur (local, mot de passe de démo).
2. **Ajouter une sonde** :

   | Champ | Valeur pour la cible de démo | Valeur pour la prod TaskFlow locale |
   |---|---|---|
   | Type | HTTP(s) - Mot-clé | HTTP(s) - Mot-clé |
   | URL | `http://cible/health` | `https://host.docker.internal/health` (ajouter `:<HTTPS_PORT>` si vous n'utilisez pas 443) |
   | Mot-clé | `"status":"ok"` | `"db":"up"` |
   | Intervalle | 20 s | 60 s |
   | Nouvelles tentatives | 1 | 2 |
   | Options avancées | — | **Ignorer les erreurs TLS/SSL** (certificat auto-signé) |

3. Enregistrer : la sonde passe au vert. Le mot-clé permet de détecter un `/health` qui répond `200`… mais avec `"db":"down"` ? Non : l'API renvoie alors **503**, la sonde échoue déjà sur le code HTTP. Le mot-clé protège contre une page d'erreur servie en `200` par un proxy mal configuré.
4. (Montrer seulement) **Paramètres → Notifications** : e-mail SMTP, Discord, Slack, Telegram… et **Pages de statut** pour une page publique.

> Pourquoi `http://cible/health` et pas `http://localhost:8088/health` ? Dans le conteneur Kuma, `localhost` désigne **le conteneur Kuma lui-même**. On utilise le nom du service Compose (même réseau), ou `host.docker.internal` pour atteindre un port publié sur le poste.

## Déroulé minuté

| Min | Étape | Dire | Taper / montrer | Question à poser à la salle |
|---|---|---|---|---|
| 0-2 | 1 | « Les logs disent ce qui s'est passé ; la supervision nous **prévient** quand ça casse, avant les utilisateurs. » | `compose up -d`, `curl /health` | « Comment savez-vous aujourd'hui que votre site est tombé ? » |
| 2-6 | 2 | « Uptime Kuma interroge `/health` à intervalle régulier, comme un utilisateur robot. » | Création du compte et de la sonde | « Pourquoi une sonde sur `/health` plutôt que sur la page d'accueil ? » (vérifie aussi la base) |
| 6-9 | 3 | « Simulons une panne. » | `compose stop cible` → sonde rouge | « Pourquoi Kuma attend-il une nouvelle tentative avant d'alerter ? » (éviter les fausses alertes) |
| 9-11 | 4 | « On rétablit : l'historique garde la durée de la panne. » | `compose start cible` → vert | « Quelle information mettriez-vous dans un post-mortem ? » (heure de début, de fin, durée) |
| 11-15 | 5 | « Même chose sur notre prod TaskFlow en HTTPS. » Healthcheck Docker (interne, redémarre) **vs** Uptime Kuma (externe, alerte). Citer Prometheus + Grafana pour les métriques. | Sonde `https://host.docker.internal/health` avec *Ignorer TLS* ; coupure de l'API : `docker compose -p taskflow-prod stop api` puis `start api` | « Uptime Kuma tourne sur la même machine que la prod : quel est le problème ? » (si la machine tombe, plus d'alerte → superviser depuis ailleurs) |

## Pièges à anticiper

- Premier démarrage lent (10-30 s, migration de la base SQLite interne) : le script attend.
- `host.docker.internal` : défini par `extra_hosts: host-gateway` (Docker Engine ≥ 20.10, Docker Desktop, Podman ≥ 4).
- Sonde rouge sur la prod alors que le site marche dans le navigateur : option *Ignorer les erreurs TLS* oubliée (certificat auto-signé).
- Le volume `kuma-data` contient le compte et les sondes : `down -v` les efface (voulu en fin de démo).
