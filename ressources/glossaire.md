# Glossaire DevOps

Les termes de la formation, expliqués simplement. Ordre alphabétique.

| Terme | Explication |
|---|---|
| **Action (GitHub Actions)** | Brique réutilisable utilisée dans une étape (`uses: actions/checkout@v4`). Comme une fonction toute faite. |
| **Agile** | Façon de travailler par petites livraisons fréquentes plutôt qu'un gros projet livré à la fin. |
| **API** | Interface par laquelle des programmes se parlent. Ici : le serveur de TaskFlow répond à `/api/tasks`. |
| **apt** | Gestionnaire de paquets de Debian/Ubuntu : `sudo apt install nginx`. |
| **Artefact** | Fichier produit par un pipeline et conservé : dossier `dist/`, rapport de tests, image Docker. |
| **Auto-signé (certificat)** | Certificat TLS fabriqué par vous-même, sans autorité reconnue. Chiffre bien, mais le navigateur avertit. Parfait en local, interdit en production publique. |
| **Backup / sauvegarde** | Copie des données (ici `pg_dump` de la base). Une sauvegarde jamais testée en restauration n'est pas une sauvegarde. |
| **Bind mount** | Dossier de votre poste monté dans un conteneur. Voir *volume*. |
| **Branche** | Ligne de travail parallèle dans Git ; permet de développer sans toucher `main`. |
| **Build** | Étape qui transforme le code en quelque chose d'exécutable (compilation, `npm run build`, construction d'une image). |
| **CALMS** | Culture, Automatisation, Lean, Mesure, Partage : les piliers du DevOps. |
| **CD (livraison continue)** | *Continuous Delivery* : le code est toujours prêt à être déployé, un humain appuie sur le bouton. |
| **CD (déploiement continu)** | *Continuous Deployment* : chaque changement validé part en production automatiquement, sans humain. |
| **Certificat** | Document numérique qui prouve l'identité d'un site et permet le chiffrement (HTTPS). |
| **CI (intégration continue)** | *Continuous Integration* : à chaque push, on construit et on teste automatiquement pour détecter vite les erreurs. |
| **Clé SSH (publique / privée)** | Paire de fichiers : la **publique** se donne (cadenas), la **privée** reste secrète (clé). Remplace le mot de passe. |
| **Commit** | Photo (enregistrement) de votre projet à un instant, avec un message. |
| **Conflit** | Deux personnes ont modifié les mêmes lignes ; Git demande à un humain de choisir. |
| **Conteneur** | Processus isolé qui embarque tout ce dont une application a besoin. Plus léger qu'une machine virtuelle : il partage le noyau de l'hôte. |
| **Conventional Commits** | Convention de messages (`feat:`, `fix:`, `docs:`...) qui rend l'historique lisible. |
| **Cron** | Planification de tâches : `0 6 * * 1` = lundis à 6 h. |
| **DevOps** | Culture et pratiques qui rapprochent développeurs (Dev) et exploitants (Ops) : on construit **et** on fait tourner, avec de l'automatisation. |
| **DORA (métriques)** | 4 mesures de la performance d'une équipe : fréquence de déploiement, délai de livraison, taux d'échec, temps de rétablissement. |
| **Docker** | Outil pour construire et lancer des conteneurs. |
| **Docker Compose** | Décrit plusieurs conteneurs dans un fichier `compose.yaml` et les lance ensemble (`docker compose up`). |
| **Dockerfile** | Recette de construction d'une image, instruction par instruction. |
| **Environnement (dev / test / prod)** | Lieux où tourne l'application : votre poste (dev), un essai (test), le vrai (prod). Même code, configuration différente. |
| **Environment (GitHub)** | Réglage GitHub (ex. `production`) avec ses propres secrets et éventuellement une validation manuelle avant déploiement. |
| **Fast-forward** | Fusion triviale : la branche cible n'a pas bougé, Git avance simplement le pointeur. |
| **GitHub Flow** | Workflow simple : `main` toujours déployable, travail en branches courtes, Pull Request, revue, merge. |
| **Git Flow** | Workflow plus lourd avec `main`, `develop`, `feature/*`, `hotfix/*`. |
| **ghcr.io** | *GitHub Container Registry* : registre d'images Docker de GitHub. |
| **GITHUB_TOKEN** | Jeton temporaire créé automatiquement à chaque workflow, avec des droits limités (`permissions:`). |
| **Healthcheck** | Test automatique de bonne santé d'un service (`/health`, `pg_isready`). Compose ou Docker marque le conteneur *healthy* / *unhealthy*. |
| **Hôte** | La machine qui fait tourner les conteneurs (ici : votre poste). |
| **HTTP / HTTPS** | Protocole du web / sa version chiffrée (par TLS). Cadenas dans le navigateur. |
| **Image (Docker)** | Modèle figé, en lecture seule, à partir duquel on lance des conteneurs. Composée de couches. |
| **Infrastructure as Code** | Décrire l'infrastructure dans des fichiers versionnés (compose, workflows) plutôt que de cliquer à la main. |
| **Job** | Ensemble d'étapes qui s'exécute sur un runner. Plusieurs jobs tournent en parallèle sauf si `needs:` les ordonne. |
| **Journal / log** | Messages écrits par un programme pour raconter ce qu'il fait. Premier réflexe en cas de panne. |
| **JSON (logs)** | Un événement par ligne au format JSON : lisible par les outils de recherche. |
| **Label (runner)** | Étiquette d'un runner (`self-hosted`, `lab`) ; `runs-on:` s'en sert pour choisir où exécuter. |
| **Lint / linter** | Outil qui détecte les fautes de style et erreurs probables sans exécuter le code (ESLint). |
| **Merge** | Fusion d'une branche dans une autre. |
| **Monitoring / supervision** | Surveiller en continu qu'un service fonctionne et alerter (Uptime Kuma). |
| **Nginx** | Serveur web et **reverse proxy** très répandu. |
| **Pipeline** | Chaîne automatique d'étapes : lint, tests, build, publication, déploiement. |
| **PaaS** | *Platform as a Service* : hébergeur qui exécute votre application sans que vous gériez le serveur (Render, Railway). |
| **Port** | Numéro de « porte » d'une machine : 80 (HTTP), 443 (HTTPS), 22 (SSH), 5432 (PostgreSQL). `-p 8080:80` = port 8080 de l'hôte vers 80 du conteneur. |
| **Post-mortem (sans blâme)** | Compte rendu d'un incident : chronologie, cause, correction, prévention. On cherche les failles du système, pas un coupable. |
| **Production (prod)** | Environnement réel utilisé par les vrais utilisateurs. Ici : la stack `taskflow-prod` sur votre poste. |
| **Pull Request (PR)** | Demande de fusion d'une branche sur GitHub : lieu de la discussion et de la revue de code. |
| **Rebase** | Rejouer vos commits au-dessus d'une autre base pour un historique linéaire. Ne jamais le faire sur une branche partagée. |
| **Registre (registry)** | Entrepôt d'images (Docker Hub, ghcr.io). `docker push` envoie, `docker pull` télécharge. |
| **Release** | Version publiée et nommée (tag `v1.2.0`) avec ses notes. |
| **Repository (dépôt)** | Projet versionné avec Git. |
| **Reverse proxy** | Serveur placé devant vos applications : unique point d'entrée, gère HTTPS et redirige vers le bon service. |
| **Revue de code** | Relecture du code d'un collègue avant le merge. |
| **Rollback** | Retour à la version précédente après un déploiement raté (redéployer l'ancien tag). |
| **Runner** | Machine (ou conteneur) qui exécute les jobs GitHub Actions. *GitHub-hosted* : fourni par GitHub. *Self-hosted* : le vôtre. |
| **Secret** | Information confidentielle (mot de passe, jeton, clé). Jamais dans Git ni dans une image ; stocké dans les *Secrets* GitHub ou un `.env` protégé. |
| **SemVer** | *Semantic Versioning* `MAJEUR.MINEUR.CORRECTIF` : 2.4.1. Majeur = rupture, mineur = nouveauté compatible, correctif = bug corrigé. |
| **Service (Compose)** | Un conteneur décrit dans `compose.yaml` (`db`, `api`, `front`). Son nom sert d'adresse réseau interne. |
| **Smoke test** | Test minimal après déploiement : « est-ce que ça démarre ? » (`curl -f .../health`). |
| **SHA (de commit)** | Identifiant unique d'un commit (ex. `a1b2c3d`). Sert à tagger précisément les images. |
| **SSH** | *Secure Shell* : connexion chiffrée à une machine distante (port 22). |
| **sudo** | Exécuter une commande avec les droits administrateur. |
| **Step (étape)** | Une action ou une commande dans un job. |
| **Tag** | Étiquette fixe sur un commit (`v1.0.0`), ou version d'une image (`api:1.0.0`). |
| **TLS** | *Transport Layer Security* : chiffrement qui protège HTTPS (successeur de SSL). |
| **Trigger / déclencheur** | Événement qui lance un workflow : `push`, `pull_request`, `workflow_dispatch`, `schedule`. |
| **Uptime Kuma** | Outil de supervision simple : vérifie périodiquement qu'une URL répond et prévient sinon. |
| **VM (machine virtuelle)** | Ordinateur simulé avec son propre système complet ; plus lourd qu'un conteneur. |
| **Volume (Docker)** | Espace de stockage géré par Docker qui survit à la suppression du conteneur : indispensable pour une base de données. |
| **VPS** | *Virtual Private Server* : serveur virtuel loué chez un hébergeur, accessible par SSH. Dans le lab, votre poste en tient le rôle. |
| **Workflow** | Fichier YAML de GitHub Actions décrivant déclencheurs, jobs et étapes. |
| **YAML** | Format de fichier de configuration basé sur l'indentation (espaces, jamais de tabulation). Compose et Actions l'utilisent. |
| **12 factors (config)** | Principe : la configuration (mots de passe, URL) vient de l'environnement (`.env`), pas du code. |
| **502 / 503 / 504** | Erreurs HTTP côté serveur : 502 = l'application derrière le proxy ne répond pas ; 503 = service indisponible (ex. base de données down) ; 504 = trop lent. |
| **200 / 201 / 204 / 301 / 404 / 500** | Succès / créé / succès sans contenu / redirection permanente / introuvable / erreur interne. |
