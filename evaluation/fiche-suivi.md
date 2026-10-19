# Fiche de suivi formateur — DWWM DevOps

**Session :** ______________________ **Dates :** du ____ / ____ au ____ / ____ / ________ **Formateur :** Fabrice Claeys

> Usage interne. Une ligne par apprenant ; cocher au moment où le formateur constate l'étape **sur le poste ou le dépôt de l'apprenant** (points de contrôle ci-dessous).
> Imprimer en paysage (A4 ou A3).

**Légende :** ✓ validé · ~ partiel (aide nécessaire / incomplet) · ✗ non fait · (vide) pas encore vérifié

## Tableau de suivi

| # | Apprenant | Dépôt (`github.com/…/taskflow`) | TP0 | TP1 | Repo | É1 Docker | É2 Compose | É3 CI | É4a Manuel | É4b Auto | É5 Incident | QCM /20 | Prés. /10 | Note /100 | Validé O/N | Commentaires |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | | | | | | | | | | | | | | | | |
| 2 | | | | | | | | | | | | | | | | |
| 3 | | | | | | | | | | | | | | | | |
| 4 | | | | | | | | | | | | | | | | |
| 5 | | | | | | | | | | | | | | | | |
| 6 | | | | | | | | | | | | | | | | |
| 7 | | | | | | | | | | | | | | | | |
| 8 | | | | | | | | | | | | | | | | |
| 9 | | | | | | | | | | | | | | | | |
| 10 | | | | | | | | | | | | | | | | |
| 11 | | | | | | | | | | | | | | | | |
| 12 | | | | | | | | | | | | | | | | |

Colonnes : **TP0** cartographie du pipeline · **TP1** Git collaboratif · **Repo** mise en place du dépôt `taskflow` · **É1** à **É5** étapes du fil rouge · **QCM** formatif · **Prés.** critère 7 de la grille · **Note** total de la [grille](grille-evaluation.md) · **Validé** : ≥ 50 et critères 1-5 au moins « Partiel ».

---

## Points de contrôle par jour

Pour valider une étape (✓), **tous** les points de contrôle doivent être observés. S'il en manque un ou deux : ~.

### Jour 1 — Culture DevOps & Git collaboratif

**TP0 — Cartographie d'un pipeline**
- [ ] Liste d'au moins 4 problèmes de « La Fromagerie » (déploiement FTP manuel, pas de tests, vendredi soir, pas de retour arrière…)
- [ ] Schéma du pipeline cible TaskFlow : étapes code → build → test → release → deploy → monitor, avec un outil et un déclencheur par étape
- [ ] Sait distinguer à l'oral CI / livraison continue / déploiement continu

**TP1 — Projet collaboratif** (se termine en J2)
- [ ] Branche `feature/carte-<prenom>` créée et poussée
- [ ] PR ouverte, **relue par un pair** (commentaire ou approbation visible)
- [ ] Conflit sur `index.html` résolu : les deux lignes conservées, plus aucun marqueur `<<<<<<<` (`git grep '<<<<<<<'` vide)
- [ ] (J2) Branche rebasée sur `main` avant merge, tag `v1.0.0` et release GitHub créés

### Jour 2 — Git (fin) & Docker

**Mise en place du dépôt `taskflow`**
- [ ] Dépôt créé depuis le starter, `npm test` vert dans `api/` et `front/` en local
- [ ] `main` protégée (PR obligatoire) : tentative de `git push origin main` refusée
- [ ] URL du dépôt notée dans le tableau

**Étape 1 — Dockeriser TaskFlow**
- [ ] PostgreSQL lancé en conteneur avec un volume nommé et un réseau dédié
- [ ] `api/Dockerfile` construit ; `curl localhost:3000/health` → `"db":"up"` depuis le conteneur api connecté au réseau
- [ ] `front/Dockerfile` multi-stage + `nginx.conf` ; http://localhost:8080 affiche TaskFlow et liste les tâches
- [ ] Après `docker rm -f` du conteneur PostgreSQL et relance avec le même volume, les tâches sont toujours là

### Jour 3 — Docker Compose & intégration continue

**Étape 2 — Compose**
- [ ] `docker compose up -d --build` démarre db + api + front ; `docker compose ps` : `db` et `api` en `(healthy)`
- [ ] `.env.example` versionné, `.env` ignoré par Git
- [ ] Test « nouvel arrivant » réussi par le binôme (clone → `cp .env.example .env` → une commande)
- [ ] PR relue par le binôme et mergée

**Étape 3 — Pipeline CI**
- [ ] `ci.yml` vert sur une PR (lint + tests api avec service postgres + tests et build front)
- [ ] Test cassé volontairement → PR rouge → bouton *Merge* bloqué (check requis) → corrigé
- [ ] `release.yml` : images `ghcr.io/<owner>/taskflow-api` et `taskflow-front` visibles dans *Packages*, tags SHA + `latest`

### Jour 4 — Déploiement, automatisation, supervision

**Étape 4a — Déploiement manuel**
- [ ] `~/taskflow-prod/` contient `compose.prod.yaml`, `nginx/taskflow.conf`, `deploy.sh`, `backup.sh`, et `.env` en `chmod 600` (`ls -l ~/taskflow-prod/`)
- [ ] Certificat auto-signé généré par `gen-cert.sh` dans `~/taskflow-prod/certs/` ; ni `.env` ni `certs/` dans le dépôt (`git status` propre)
- [ ] `docker compose -p taskflow-prod ps` : db, api, front, proxy Up ; seul `proxy` publie des ports
- [ ] `curl -kfsS https://taskflow.localhost/health` → `"status":"ok"` ; `curl -sI http://taskflow.localhost` → `301` vers HTTPS
- [ ] `backup.sh` produit un dump horodaté **et** une restauration a été testée

**Étape 4b — Déploiement automatique**
- [ ] Runner `lab-runner` **Idle** dans *Settings → Actions → Runners* (socket Docker et `DEPLOY_DIR` montés)
- [ ] Job `deploy` (`[self-hosted, lab]`, `needs: build`) vert : copie dans `$DEPLOY_DIR`, `deploy.sh <sha court>`, smoke test `/health` dans le log
- [ ] Modification du titre → PR → merge → visible sur `https://taskflow.localhost` sans geste manuel ; `/health` affiche le nouveau SHA
- [ ] Rollback via `workflow_dispatch` (input `tag`) essayé

**Étape 5 — Analyse d'un incident**
- [ ] Démarche suivie dans l'ordre : symptôme (502) → `docker compose -p taskflow-prod logs proxy` → `ps` → `logs api` → cause
- [ ] Cause identifiée : variable `DATABASE_URL` mal nommée dans `.env` ; correction appliquée, `/health` de nouveau OK
- [ ] Post-mortem rédigé dans `docs/INCIDENTS.md` (chronologie, cause, correction, action préventive, sans blâme)

**Évaluation**
- [ ] QCM rendu (note reportée)
- [ ] Présentation passée ; fiche de notation de la [grille](grille-evaluation.md) complétée et signée

---

## Notes de session

| Date | Apprenant | Observation (difficulté, aide apportée, point fort) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |
| | | |
