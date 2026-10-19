# Exercice 4.1 — La configuration Nginx du proxy à corriger

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S5 — Blocs 5.2 (reverse proxy : `server`, `location`, `proxy_pass`, `X-Forwarded-*`, `nginx -t`) et 5.3 (HTTPS) |
| **Prérequis** | Docker et Docker Compose ; avoir vu le rôle du conteneur `proxy` dans `compose.prod.yaml` |
| **Fichiers fournis** | [`taskflow-casse.conf`](taskflow-casse.conf), dossier [`nginx-labo/`](nginx-labo/) (`compose.yaml` + `gen-cert.sh`) |

## Contexte

Dans la « production » de TaskFlow (stack `taskflow-prod`), un seul conteneur publie des ports : **`proxy`** (Nginx). Il reçoit tout le trafic sur 80 et 443, gère le HTTPS, et transmet les requêtes au conteneur **`front`** (port 80 dans le réseau de la stack), qui sert le site et relaie `/api` vers l'API.

```text
navigateur ──https──▶ proxy :443 ──http──▶ front :80 ──▶ api :3000 ──▶ db :5432
             http ──▶ proxy :80  ──301──▶ (redirection vers https)
```

Le conteneur `proxy` monte :

| Sur le poste (`~/taskflow-prod/`) | Dans le conteneur |
|---|---|
| `nginx/taskflow.conf` | `/etc/nginx/conf.d/default.conf` |
| `certs/taskflow.crt`, `certs/taskflow.key` | `/etc/nginx/certs/` |

Un collègue a écrit `deploy/nginx/taskflow.conf`… et le proxy ne démarre pas. Le fichier contient **6 problèmes**.

## Objectif

Corriger la configuration, la **tester avant de l'appliquer** (`nginx -t`) et vérifier le résultat : redirection HTTP → HTTPS et site servi en HTTPS.

## Consignes

### Mise en place du labo

Le dossier `nginx-labo/` reproduit la partie réseau de la stack : un `front` factice (un Nginx qui affiche « Welcome to nginx! ») et le `proxy`. Il utilise les ports **8880** (HTTP) et **8443** (HTTPS) pour ne pas gêner votre vraie stack.

```bash
cd nginx-labo
bash gen-cert.sh                              # certificat auto-signé dans ./certs/
cp ../taskflow-casse.conf taskflow.conf       # la configuration à corriger
docker compose up -d
docker compose ps
```

### Diagnostic

1. Le conteneur `proxy` est-il démarré ? Lisez ses logs : `docker compose logs proxy`. Quelle est la **première** erreur ?
2. Le conteneur étant arrêté, `docker compose exec proxy nginx -t` est impossible. Testez la configuration dans un conteneur temporaire :
   ```bash
   docker compose run --rm --no-deps proxy nginx -t
   ```
3. Corrigez l'erreur dans `taskflow.conf`, relancez le test, et recommencez tant que le test échoue.
4. Quand `nginx -t` affiche `test is successful`, démarrez le proxy (`docker compose up -d`) et testez :
   ```bash
   curl -I http://localhost:8880/
   curl -k https://localhost:8443/
   ```
   Obtenez-vous une redirection ? Une page ? Que disent les logs du proxy (`docker compose logs --tail 5 proxy`) ?
5. Le test de syntaxe passe, mais il reste des problèmes **de fonctionnement**. Trouvez-les tous et remplissez le tableau :

   | Ligne | Problème | Conséquence | Correction |
   |---|---|---|---|

6. Une fois le proxy démarré, appliquez vos corrections **sans couper le service** :
   ```bash
   docker compose exec proxy nginx -t && docker compose exec proxy nginx -s reload
   ```
7. Vérifiez le résultat final (voir ci-dessous), puis nettoyez : `docker compose down`.

## Résultat attendu

```text
$ docker compose exec proxy nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

$ curl -sI -H 'Host: taskflow.localhost' http://localhost:8880/ | grep -i -E '^HTTP|^location'
HTTP/1.1 301 Moved Permanently
Location: https://taskflow.localhost/

$ curl -sk https://localhost:8443/ | grep title
<title>Welcome to nginx!</title>
```

(Dans le labo, la redirection pointe vers le port 443 standard et non 8443 : c'est normal, la vraie stack écoute sur 80/443.)

## Indices

<details>
<summary>Indice 1 — les deux erreurs qui empêchent le démarrage</summary>

- Chaque directive Nginx se termine par `;` : le message `directive "…" is not terminated by ";"` donne la ligne.
- `cannot load certificate "…": No such file or directory` : regardez **où** les certificats sont montés dans le conteneur (tableau ci-dessus) et comparez avec les deux lignes `ssl_certificate*`.
</details>

<details>
<summary>Indice 2 — la 502</summary>

Le log d'erreur indique `connect() failed (111: Connection refused) while connecting to upstream … upstream: "http://127.0.0.1:8080/"`. Dans un conteneur, `127.0.0.1` désigne **le conteneur lui-même** (ici le proxy), pas votre machine ni le front. Comment s'appelle le service à joindre, et sur quel port écoute-t-il **dans le réseau** de la stack ?
</details>

<details>
<summary>Indice 3 — ce qui reste</summary>

- Le bloc `listen 80` devrait-il servir le site, ou **rediriger** ? (`return 301 https://$host$request_uri;`)
- Le bloc `listen 443` ne déclare pas de `server_name`.
- L'application ne voit pas l'IP du visiteur ni le fait qu'il est en HTTPS : il manque `X-Real-IP`, `X-Forwarded-For` et `X-Forwarded-Proto`.
</details>

## Question de réflexion

Pourquoi est-ce une bonne pratique que **seul** le proxy publie des ports, et que `front`, `api` et `db` n'en publient aucun ?
