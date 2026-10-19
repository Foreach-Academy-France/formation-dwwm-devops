# Évaluation — Formation DWWM DevOps (4 jours, 28h)

**Formation** : DevOps pour le titre professionnel Développeur Web et Web Mobile (DWWM)
**Organisme** : ForEach Academy
**Formateur** : Fabrice Claeys

> Lien avec le titre pro DWWM : activité « Développer la partie back-end d'une application web ou web mobile », compétence « Préparer et exécuter le déploiement d'une application web ». Le pipeline TaskFlow construit pendant la semaine peut être réutilisé comme **preuve dans le dossier professionnel**.

---

## Vue d'ensemble

| Modalité | Type | Quand | Poids | Bloquant ? |
|---|---|---|---|---|
| Exercices guidés (`exercices/jour1..4/`) | Formative | Chaque jour | — | Non |
| Quiz de fin de journée (5 questions dans les slides) | Formative | Fin de J1, J2, J3 | — | Non |
| Validation des étapes du fil rouge par le formateur | Formative | Au fil de l'eau | — | Non (mais conditionne la mise en situation) |
| Revues de code entre pairs (PR) | Formative | J1, J3, J4 | — | Non |
| QCM (20 questions, 15 min) — [qcm.md](qcm.md) | Formative | J4 16h00 | Indicatif /20 | Non |
| **Mise en situation** : présentation du pipeline — [mise-en-situation.md](mise-en-situation.md) + dépôt `taskflow` | **Certificative** | J4 16h15 | **100 points** — [grille-evaluation.md](grille-evaluation.md) | **Oui** |

---

## Évaluation formative

Son but est de vous aider à progresser, pas de vous noter :

- **Exercices guidés** : courts (10–20 min), avec indices progressifs et solutions séparées. Faites-les avant de regarder la solution.
- **Quiz de fin de journée** : 5 questions dans les slides, correction collective immédiate.
- **Validation des étapes du fil rouge** : à la fin de chaque étape (Docker, Compose, CI, déploiement manuel, déploiement automatique, incident), le formateur vérifie avec vous quelques points de contrôle observables et les note dans la [fiche de suivi](fiche-suivi.md). Une étape non validée n'est pas une sanction : c'est un signal pour demander de l'aide.
- **Revues entre pairs** : chaque PR de votre dépôt `taskflow` doit être relue par votre binôme (au moins un commentaire constructif).
- **QCM de J4** (20 questions, 1 bonne réponse sur 4, 15 min) : il vérifie les notions des 6 séquences. Il est **non bloquant** ; sa note figure sur la fiche de suivi et sert au débrief individuel.

---

## Évaluation certificative — mise en situation (100 points)

Vous présentez **votre** pipeline TaskFlow, en direct, à partir de votre dépôt et de votre « production » locale (stack Compose `taskflow-prod` dans `~/taskflow-prod/`, derrière Nginx en HTTPS). Le formateur (jury) note avec la [grille d'évaluation](grille-evaluation.md) :

| # | Critère du programme | Points |
|---|---|---|
| 1 | Dockerfile fonctionnel (api + front, bonnes pratiques) | 15 |
| 2 | Fichier Docker Compose (db + api + front, volume, healthcheck, .env) | 15 |
| 3 | Dépôt GitHub configuré (branche protégée, PR revues, commits propres, tag) | 15 |
| 4 | Workflow GitHub Actions (lint, tests, build, push image) | 20 |
| 5 | Déploiement automatique fonctionnel (HTTPS, smoke test) | 15 |
| 6 | Documentation technique (architecture + procédure de déploiement) | 10 |
| 7 | Présentation du pipeline et justification des choix | 10 |
| | **Total** | **100** |

### Règle de validation

La compétence est **validée** si les deux conditions sont réunies :

1. note totale **≥ 50 / 100** ;
2. **chacun des 5 premiers critères** (Dockerfile, Compose, Dépôt GitHub, Workflow, Déploiement automatique) est **au moins « Partiel »**.

Exemple : 62/100 avec le critère 5 « Non atteint » → **non validé** (il manque une brique du pipeline).

### Rendu attendu

Avant **J4 16h00**, vous déposez (formulaire ou message au formateur) :

- l'**URL de votre dépôt GitHub** `taskflow` ;
- l'accès en lecture du formateur : dépôt public, **ou** formateur invité comme collaborateur (*Settings → Collaborators*) ;
- la confirmation que votre « prod » et votre runner tournent : `docker compose -p taskflow-prod ps` (db, api, front, proxy Up), runner `lab-runner` **Idle** dans *Settings → Actions → Runners*, `curl -kfsS https://taskflow.localhost/health` OK.

Le contenu détaillé des livrables est dans [mise-en-situation.md](mise-en-situation.md).

---

## Déroulé du J4, 16h00 – 17h00

| Horaire | Durée | Activité | Organisation |
|---|---|---|---|
| 16h00 | 15 min | **QCM formatif** (papier ou formulaire) | Individuel, sans document |
| 16h15 | 2 min | Rappel des consignes, ordre de passage affiché | Collectif |
| 16h17 | 36 min | **Présentations** (5 min + 3 min de questions) | Voir organisation ci-dessous |
| 16h53 | 7 min | Débrief collectif : correction express du QCM, retours généraux, rappel du dossier professionnel | Collectif |

### Organisation des présentations selon l'effectif

Une présentation = 5 min + 3 min de questions + 1 min de changement = **9 min**.

- **Jusqu'à 4 apprenants** : passages individuels successifs devant le formateur (4 × 9 = 36 min).
- **Calcul pour 12 apprenants** : 12 × 9 min = 108 min, impossible en 36 min. On organise donc :
  - **3 îlots en parallèle** de 4 apprenants (4 passages × 9 min = 36 min par îlot) ;
  - l'îlot du formateur note en direct ; les deux autres îlots sont animés par un co-jury (formateur associé, référent pédagogique ou tuteur d'entreprise) **ou**, à défaut, les apprenants présentent **en binôme** (2 × 6 binômes, 5 min de démo à deux + 3 min de questions, chacun doit répondre à au moins une question) ;
  - le formateur complète la note du critère 7 sur la base de la démo et des questions, et les critères 1 à 6 en vérifiant les dépôts **le soir même** avec la grille (les commandes de vérification y sont données).
- **Plus de 12 apprenants** : démarrer les présentations dès 14h30 pendant l'étape 5 (incident) pour les premiers volontaires.

> La note des critères 1 à 6 se fonde sur **l'état du dépôt et de la stack `taskflow-prod` au moment de la présentation**. Un commit poussé après 17h00 n'est pas pris en compte.

---

## Fichiers du dossier

| Fichier | Public | Contenu |
|---|---|---|
| [qcm.md](qcm.md) | Apprenants | QCM imprimable, 20 questions, sans réponses |
| `qcm-corrige.md` | **Formateur uniquement** | Réponses commentées — ignoré par Git, jamais publié |
| [grille-evaluation.md](grille-evaluation.md) | Formateur (consultable par les apprenants) | Grille 100 points, niveaux, commandes de vérification |
| [mise-en-situation.md](mise-en-situation.md) | Apprenants | Consigne de l'évaluation certificative |
| [fiche-suivi.md](fiche-suivi.md) | Formateur | Suivi apprenant × étape du fil rouge |
