# Formation DevOps — DWWM

> Formation de 4 jours (28h) : de « ça marche sur ma machine » à « déployé automatiquement en HTTPS à chaque merge »

**Public** : Titre professionnel **Développeur Web et Web Mobile** (DWWM)
**Durée** : 4 jours × 7h (28 heures)
**Institution** : ForEach Academy
**Formateur** : Fabrice Claeys
**Prérequis** : HTML, CSS, JavaScript · développement d'une application web (PHP, Node.js ou autre) · utilisation de Git et GitHub · bases Linux
**Dates** : à confirmer

📺 **Site de la formation (slides, TP en PDF)** : https://foreach-academy-france.github.io/formation-dwwm-devops/

---

## Objectifs pédagogiques

À l'issue du module, vous serez capable de :

- Comprendre les principes de la culture DevOps
- Utiliser Git dans une démarche collaborative (branches, Pull Requests, revue de code, conflits)
- Mettre en place un environnement de développement reproductible
- Conteneuriser une application avec Docker et Docker Compose
- Automatiser les tests et le déploiement avec GitHub Actions
- Déployer une application conteneurisée derrière un reverse proxy Nginx en HTTPS (et savoir ce qui change sur un serveur Linux distant : SSH, utilisateur, pare-feu)
- Diagnostiquer les erreurs de déploiement

**Compétences visées (TP DWWM)** : préparer et exécuter le déploiement d'une application · utiliser les outils de gestion de versions · automatiser les tâches répétitives · collaborer avec les équipes de développement · assurer une mise en production fiable.

---

## Organisation

**Chaque journée** : cours et démonstrations en blocs courts (45 min max), exercices guidés, puis TP fil rouge encadré.

```
code → pull request → tests automatiques → image Docker → déploiement → supervision
```

### Projet fil rouge : TaskFlow

Un gestionnaire de tâches volontairement simple — **front** Vite (JavaScript) + **API** Node/Express + **PostgreSQL** — pour que l'effort porte sur le DevOps, pas sur le code. Vous partez d'un projet qui ne tourne qu'en local et vous construisez toute la chaîne autour :

| Étape | Jour | Ce que vous ajoutez au projet |
|-------|------|-------------------------------|
| 1 | J2 | `Dockerfile` de l'API et du front, PostgreSQL en conteneur |
| 2 | J3 | `compose.yaml` : toute l'application démarre en une commande |
| 3 | J3 | Pipeline GitHub Actions : lint + tests + build à chaque PR, images publiées sur ghcr.io |
| 4 | J4 | Déploiement en « production » (Nginx, HTTPS, `.env`, sauvegarde), puis **automatique** à chaque merge |
| 5 | J4 | Analyse d'un incident de déploiement et post-mortem |

**Stack** : Git & GitHub · Docker & Docker Compose · PostgreSQL · GitHub Actions · ghcr.io · Nginx · Uptime Kuma

**Environnement de production** : une stack Docker Compose séparée sur votre poste (`~/taskflow-prod/`), derrière un conteneur Nginx en HTTPS, mise à jour automatiquement par un runner GitHub Actions local. Mêmes gestes qu'un vrai serveur, sans rien payer ; ce qui change sur un VPS (SSH, pare-feu, certbot) est montré en cours. Voir [ressources/lab/](./ressources/lab/).

Plan détaillé bloc par bloc : [plan-cours.md](./plan-cours.md)

---

## Programme

### Jour 1 : Culture DevOps & Git collaboratif

| Horaire | Contenu |
|---------|---------|
| **MATIN — Séquence 1 : Introduction au DevOps** | |
| 9h00-9h45 | **Pourquoi le DevOps ?** Histoire, culture CALMS, cycle de vie d'une application |
| 9h45-10h30 | **CI, livraison continue, déploiement continu** — collaboration Dev / Ops |
| 10h45-11h15 | **Panorama des outils** |
| 11h15-12h15 | **TP0 : Cartographie d'un pipeline** (étude de cas) |
| **APRÈS-MIDI — Séquence 2 : Git collaboratif (1/2)** | |
| 13h15-15h15 | Bases de Git, branches et merge, workflow d'équipe (GitHub Flow, Git Flow simplifié), Pull Request, revue de code, conflits |
| 15h30-17h00 | **TP1 : Projet collaboratif** — branche feature, PR, revue, fusion, conflit |

**Slides** : [Jour 1](./slides/jour1-devops-git.md) · **TP** : [TP0](./tp/tp0-cartographie-pipeline/) · [TP1](./tp/tp1-git-collaboratif/) · **Exercices** : [jour 1](./exercices/jour1/)

---

### Jour 2 : Git (fin) & Docker

| Horaire | Contenu |
|---------|---------|
| **MATIN** | |
| 9h00-10h30 | **Séquence 2 (2/2)** : rebase, versioning (SemVer, tags, releases), fin du TP1, création du repo fil rouge |
| 10h45-12h15 | **Séquence 3 : Docker (1/2)** — virtualisation vs conteneurs, Docker Engine, images, premières commandes |
| **APRÈS-MIDI** | |
| 13h15-14h45 | **Dockerfile**, volumes, réseaux, variables d'environnement |
| 15h00-17h00 | **Fil rouge — Étape 1 : Dockeriser TaskFlow** |

**Slides** : [Jour 2](./slides/jour2-git-docker.md) · **TP** : [Étape 1](./tp/fil-rouge-taskflow/etape1-docker.md) · **Exercices** : [jour 2](./exercices/jour2/)

---

### Jour 3 : Docker Compose & intégration continue

| Horaire | Contenu |
|---------|---------|
| **MATIN — Séquence 3 : Docker (2/2)** | |
| 9h00-10h20 | **Docker Compose**, base de données conteneurisée |
| 10h35-12h15 | **Fil rouge — Étape 2 : Environnement complet avec Compose** |
| **APRÈS-MIDI — Séquence 4 : CI/CD (1/2)** | |
| 13h15-15h15 | **GitHub Actions** : workflows YAML, déclencheurs, jobs, lint, tests, build, secrets, variables, images sur ghcr.io |
| 15h30-17h00 | **Fil rouge — Étape 3 : Pipeline CI** |

**Slides** : [Jour 3](./slides/jour3-compose-ci.md) · **TP** : [Étape 2](./tp/fil-rouge-taskflow/etape2-compose.md) · [Étape 3](./tp/fil-rouge-taskflow/etape3-ci.md) · **Exercices** : [jour 3](./exercices/jour3/)

---

### Jour 4 : Déploiement, automatisation & supervision

| Horaire | Contenu |
|---------|---------|
| **MATIN — Séquence 5 : Déploiement** | |
| 9h00-10h45 | **Le serveur** : VPS et SSH (théorie + démo), configuration, Nginx reverse proxy, variables d'environnement, HTTPS, sauvegarde |
| 11h00-12h15 | **Fil rouge — Étape 4a : Déploiement manuel** |
| **APRÈS-MIDI** | |
| 13h15-14h45 | **Séquence 4 (2/2) : Déploiement continu** — runner, secrets, job de déploiement · **Étape 4b : Déploiement automatique** |
| 15h00-16h00 | **Séquence 6 : Supervision et bonnes pratiques** — logs, monitoring, erreurs, documentation · **Étape 5 : Analyse d'un incident** |
| 16h00-17h00 | **Évaluation** : QCM + présentation de votre pipeline |

**Slides** : [Jour 4](./slides/jour4-deploiement-supervision.md) · **TP** : [Étape 4](./tp/fil-rouge-taskflow/etape4-deploiement.md) · [Étape 5](./tp/fil-rouge-taskflow/etape5-incident.md) · **Exercices** : [jour 4](./exercices/jour4/) · **Évaluation** : [modalités](./evaluation/)

> On déploie d'abord **à la main**, puis on **automatise** ce qu'on vient de faire : *on n'automatise que ce qu'on sait faire manuellement.*

---

## Couverture du programme

| Séquence | Durée | Placement | Travaux pratiques |
|----------|-------|-----------|-------------------|
| 1. Introduction au DevOps | 3h | J1 matin | TP0 — analyse d'un workflow, cartographie d'un pipeline |
| 2. Git avancé et travail collaboratif | 5h | J1 après-midi + J2 début | TP1 — branche feature, PR, revue de code, fusion |
| 3. Docker | 8h | J2 + J3 matin | Étapes 1 et 2 — front, API, PostgreSQL, Docker Compose |
| 4. CI/CD avec GitHub Actions | 6h | J3 après-midi + J4 | Étapes 3 et 4b — build, vérification, déploiement automatique |
| 5. Déploiement d'une application | 4h | J4 matin | Étape 4a — application dockerisée sur un serveur Linux |
| 6. Supervision et bonnes pratiques | 2h | J4 fin | Étape 5 — analyse d'un incident de déploiement |

---

## Évaluation

**Formative** : exercices guidés, quiz de fin de journée, QCM, validation des étapes du fil rouge, revues de code entre pairs.

**Certificative (mise en situation)** — vous devez :
- créer un Dockerfile fonctionnel ;
- créer un fichier Docker Compose ;
- configurer un dépôt GitHub ;
- mettre en place un workflow GitHub Actions ;
- déployer automatiquement une application ;
- présenter votre pipeline DevOps et justifier vos choix techniques.

Détails : [Consigne](./evaluation/mise-en-situation.md) · [Grille (100 points)](./evaluation/grille-evaluation.md) · [QCM](./evaluation/qcm.md)

### Livrables attendus

- un dépôt Git structuré ;
- une application conteneurisée ;
- un Dockerfile et un `compose.yaml` opérationnels ;
- un pipeline CI/CD automatisé avec GitHub Actions ;
- une application déployée sur un serveur de test ;
- une documentation technique décrivant l'architecture et la procédure de déploiement.

---

## Structure du dépôt

```
├── slides/          # Slides Marp, un fichier par jour
├── demos/           # Démos jouées en direct par le formateur
├── exercices/       # Exercices guidés courts, par jour (+ solutions)
├── tp/
│   ├── tp0-cartographie-pipeline/
│   ├── tp1-git-collaboratif/
│   └── fil-rouge-taskflow/   # Énoncés étape par étape + starter/ + solution/
├── evaluation/      # QCM, grille, consigne de mise en situation
└── ressources/      # Installation du poste, cheatsheets, glossaire, lab (runner GitHub Actions)
```

---

## Ressources

### Avant le jour 1
- [Installer son poste](./ressources/setup-poste.md) — Git, VS Code, Docker, Node 20

### Aide-mémoire
- [Cheatsheet Git](./ressources/cheatsheet-git.md)
- [Cheatsheet Docker & Compose](./ressources/cheatsheet-docker.md)
- [Cheatsheet GitHub Actions](./ressources/cheatsheet-github-actions.md)
- [Cheatsheet Linux, SSH & Nginx](./ressources/cheatsheet-linux-ssh-nginx.md)
- [Glossaire](./ressources/glossaire.md)

### Documentation officielle
- [Pro Git (en français)](https://git-scm.com/book/fr/v2)
- [Docker — Get started](https://docs.docker.com/get-started/)
- [Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions (en français)](https://docs.github.com/fr/actions)
- [Nginx — Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Let's Encrypt — Comment ça marche](https://letsencrypt.org/fr/how-it-works/)

### Pour aller plus loin
- *The Phoenix Project*, Gene Kim, Kevin Behr, George Spafford
- *Accelerate*, Nicole Forsgren, Jez Humble, Gene Kim
- [roadmap.sh/devops](https://roadmap.sh/devops)

### Construire les slides en local

```bash
npm install
npm run slides:server   # aperçu live sur http://localhost:8080
npm run build           # HTML dans dist/
```

---

**2026 — Formation DevOps DWWM — ForEach Academy**
