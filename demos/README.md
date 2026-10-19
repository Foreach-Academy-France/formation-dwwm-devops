# Démos formateur

Démos live des matinées (et des débuts d'après-midi). Chaque dossier est **autonome** : un `README.md` avec le déroulé minuté (« dire / taper / montrer / question à poser à la salle ») et, quand c'est pertinent, un `demo.sh` rejouable.

## Index

| Démo | Jour / bloc | Durée | Prérequis | Ce qu'on montre |
|---|---|---|---|---|
| [demo-git-branches](demo-git-branches/) | J1 — Bloc 2.2 | 15 min | Git ≥ 2.28 | une branche = un pointeur ; fast-forward vs merge commit ; `log --oneline --graph` |
| [demo-git-conflit](demo-git-conflit/) | J1 — Bloc 2.4 | 15 min | Git ≥ 2.28, VS Code | provoquer un conflit (même `<ul>` que le TP 1), lire les marqueurs, résoudre, `merge --abort` |
| [demo-docker-premiers-pas](demo-docker-premiers-pas/) | J2 — Bloc 3.2 | 20 min | Docker, ports 8081-8082 | image vs conteneur ; `run`, `ps`, `logs`, `exec`, `stop`, `rm` ; `-p` ; données éphémères ; bind mount ; noyau partagé |
| [demo-dockerfile](demo-dockerfile/) | J2 — Bloc 3.3 | 25 min | Docker, port 3001, `node:20` + `node:20-alpine` | Dockerfile naïf (1,1 Go, root, `.env` embarqué) vs optimisé (≈ 140 Mo, `USER node`, `HEALTHCHECK`) ; cache et ordre des instructions ; `.dockerignore` |
| [demo-compose](demo-compose/) | J3 — Blocs 3.5-3.6 | 25 min | Compose v2, ports 3002 et 8081 | web + Postgres 16 + Adminer ; `.env` ; DNS par nom de service ; `depends_on: service_healthy` ; volume ; `/health` en 503 quand la base tombe |
| [demo-actions-hello](demo-actions-hello/) | J3 — Bloc 4.1 | 20 min | compte GitHub, `gh` | workflow commenté : événements, jobs, steps, runner, actions, contextes, `needs`, `workflow_dispatch`, job en échec |
| [demo-ssh-serveur](demo-ssh-serveur/) | J4 — Bloc 5.1 | 15 min | VPS du formateur **ou** Docker (variante de secours) | **démo formateur, non reproduite par les apprenants** : clé ed25519, `ssh-copy-id`, `~/.ssh/config`, non-root + `sudo`, `PasswordAuthentication no`, `ufw`, `scp` |
| [demo-uptime-kuma](demo-uptime-kuma/) | J4 — Bloc 6.1 | 15 min | Compose, ports 3001 et 8088 | sonde HTTP + mot-clé sur `/health`, panne simulée, rétablissement, application à la prod `taskflow-prod` en HTTPS |

## Conventions des scripts `demo.sh`

- `bash` strict (`set -euo pipefail`), chaque commande est **affichée en vert avant d'être exécutée** : la salle lit ce que vous tapez.
- Une pause (`Entrée pour continuer…`) entre chaque étape. `DEMO_AUTO=1` supprime les pauses pour tester avant le cours :

  ```bash
  for d in demos/demo-*/; do [ -f "$d/demo.sh" ] && DEMO_AUTO=1 bash "$d/demo.sh" >/dev/null && echo "OK $d"; done
  ```

- Tout est créé dans un dossier temporaire (`mktemp`) et **nettoyé à la fin**, y compris après Ctrl+C (`trap … EXIT`) : conteneurs, volumes, images construites. Les images de base téléchargées restent en cache.
- Les démos Git créent un dépôt jetable dans `/tmp` (`KEEP=1` pour le conserver et le faire explorer).
- `DOCKER=podman` est accepté ; les images sont **pleinement qualifiées** (`docker.io/library/…`) pour fonctionner aussi avec Podman.
- Ports modifiables par variables d'environnement (voir chaque README) si un port est déjà pris.

## Avant le premier jour

Le réseau de salle est souvent lent : pré-téléchargez les images la veille.

```bash
for img in \
  docker.io/library/hello-world:latest docker.io/library/nginx:1.27-alpine docker.io/library/alpine:3.21 \
  docker.io/library/node:20 docker.io/library/node:20-alpine \
  docker.io/library/postgres:16-alpine docker.io/library/adminer:4 \
  docker.io/louislam/uptime-kuma:1.23.16 docker.io/linuxserver/openssh-server:version-10.2_p1-r0; do
  docker pull "$img"
done
```
