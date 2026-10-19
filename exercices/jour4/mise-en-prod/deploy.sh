#!/bin/bash
# deploy.sh proposé dans la PR #31 — lancé dans ~/taskflow-prod par le job deploy
cd ~/taskflow-prod
docker compose down -v
docker compose pull
docker compose up -d
echo "Déploiement terminé !"
