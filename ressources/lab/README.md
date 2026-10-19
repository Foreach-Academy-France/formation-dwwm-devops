# Lab

Le lab tient en **un seul conteneur** : le runner GitHub Actions.

```
ressources/lab/
└── runner/     # runner GitHub Actions self-hosted (docker compose up -d --build)
```

## Il n'y a pas de serveur à installer

Il n'y a ni VPS, ni SSH en TP. Le « serveur de production » est **votre propre poste** :

| Élément | Où | Rôle |
|---|---|---|
| Code, workflows | votre dépôt GitHub `taskflow` | CI : lint, tests, build, publication des images sur ghcr.io |
| `~/taskflow-prod/` | dossier de votre poste | **le serveur** : `compose.prod.yaml`, `.env`, `certs/`, `backups/` |
| Stack `taskflow-prod` | Docker de votre poste | db + api + front + `proxy` (Nginx, HTTPS auto-signé) |
| Runner (`runner/`) | conteneur de votre poste | reçoit le job `deploy` de GitHub et lance `./deploy.sh` dans `~/taskflow-prod/` |

Chemin d'un déploiement automatique :

```
git push (merge sur main)
   -> GitHub Actions (cloud) : tests + build + push des images sur ghcr.io
   -> job deploy -> runner (chez vous) -> docker compose pull && up -d dans ~/taskflow-prod
   -> smoke test : curl https://host.docker.internal:<HTTPS_PORT>/health
```

Mise en route : voir `runner/README.md` (à l'étape 4b de la journée 4) et `../../setup-poste.md` pour le poste.
