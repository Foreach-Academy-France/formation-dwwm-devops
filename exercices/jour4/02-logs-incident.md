# Exercice 4.2 — Lire des logs d'incident

| | |
|---|---|
| **Durée** | 20 min |
| **Séquence** | S6 — Bloc 6.1 (logs, monitoring, erreurs) ; entraînement à la méthode de l'étape 5 du fil rouge |
| **Prérequis** | savoir lire une ligne de log Nginx et une ligne JSON ; avoir vu `docker compose ps` et `docker compose logs` |
| **Fichiers fournis** | dossier [`logs/`](logs/) : `nginx-access.log`, `nginx-error.log`, `api.log`, `db.log`, `compose-ps.txt`, `df-h.txt` |

## Le scénario

Un mardi matin, 9 h 50. Uptime Kuma envoie une alerte : **TaskFlow `/health` répond 503**. Des utilisateurs signalent depuis une dizaine de minutes : « La page s'affiche, mais je ne peux plus ajouter ni cocher de tâche. »

Personne n'a déployé depuis deux jours. Vous êtes d'astreinte. Vous avez récupéré les fichiers du dossier `logs/` sur le poste qui héberge la stack `taskflow-prod` :

| Fichier | Obtenu avec |
|---|---|
| `compose-ps.txt` | `docker compose -p taskflow-prod ps` |
| `nginx-access.log`, `nginx-error.log` | `docker compose -p taskflow-prod logs proxy` |
| `api.log` | `docker compose -p taskflow-prod logs api` (une ligne JSON par requête) |
| `db.log` | `docker compose -p taskflow-prod logs db` |
| `df-h.txt` | quelques commandes système lancées sur le poste |

> **Attention aux fuseaux horaires** : Nginx écrit l'heure locale (`+0200`), l'API et Postgres écrivent en **UTC** (`Z` ou `UTC`). 09:41 à Paris = 07:41 UTC.

## Objectif

Remonter du **symptôme** à la **cause racine** avec méthode, proposer une correction immédiate **et** une correction durable, puis rédiger un mini post-mortem.

## Consignes

Suivez la méthode dans l'ordre : *symptôme → proxy → état des conteneurs → API → base → système*.

1. **Symptôme** — Dans `nginx-access.log` : à quelle heure apparaît la première erreur ? Quelles routes échouent, lesquelles fonctionnent encore ? Pourquoi la page d'accueil s'affiche-t-elle toujours ?
2. **Proxy** — `nginx-error.log` contient-il une erreur liée à l'incident ? Que pouvez-vous en conclure sur la configuration du proxy ?
3. **Conteneurs** — Dans `compose-ps.txt`, quel conteneur est en difficulté ? Que signifient `Restarting (1)` et `(unhealthy)` ?
4. **API** — Dans `api.log`, trouvez la première ligne `"level":"error"`. Recopiez le champ `err`. Comment évolue l'erreur entre 07:41 et 07:48 UTC ?
5. **Base** — Dans `db.log`, trouvez la ligne `PANIC`. Pourquoi Postgres n'arrive-t-il plus à redémarrer ensuite ?
6. **Système** — Dans `df-h.txt`, qu'est-ce qui occupe le disque ? Combien de fichiers, à quelle fréquence, depuis quand ? Qu'est-ce qui manque dans `backup.sh` ?
7. Écrivez la **chaîne causale** complète en une phrase par maillon (de la cause racine jusqu'à l'alerte Uptime Kuma).
8. Proposez :
   - les **commandes de remédiation immédiate** (libérer de la place sans perdre de sauvegarde utile, relancer la base, vérifier) ;
   - **trois actions durables** pour que cela ne se reproduise pas.
9. Rédigez un mini post-mortem *sans blâme* (10 lignes maximum) : résumé, impact, chronologie (heures locales), cause racine, actions.

## Résultat attendu

Une chaîne causale du type : *disque plein à cause de X* → *Postgres ne peut plus écrire* → *l'API renvoie 500* → *`/health` renvoie 503* → *alerte*. Des commandes de remédiation qui ne suppriment **pas** toutes les sauvegardes, et des actions durables concrètes. Corrigé dans [`solutions.md`](solutions.md).

## Indices

<details>
<summary>Indice 1 — lire les codes HTTP</summary>

- `500` : l'API a reçu la requête mais a planté en la traitant (souvent une erreur de base de données).
- `502` : le proxy n'a pas réussi à joindre le service suivant (conteneur arrêté, mauvais nom…).
- `503` : le service répond « je ne suis pas en état de servir ». Notre route `/health` renvoie 503 quand la base est `down`.

Ici il n'y a **aucune** 502 : le proxy et le front joignent bien l'API.
</details>

<details>
<summary>Indice 2 — le code d'erreur Postgres</summary>

Le code `53100` correspond à `disk_full`. Le message `No space left on device` est l'erreur du **système** remontée par Postgres, puis par l'API.
</details>

<details>
<summary>Indice 3 — la remédiation</summary>

On ne supprime pas tout : on garde par exemple les sauvegardes **complètes** des derniers jours, on supprime les fichiers vides ou tronqués, et on compresse. Ensuite : `docker compose -p taskflow-prod restart db` (ou attendre la politique `restart`), puis vérifier `ps`, `/health` et une création de tâche.
</details>
