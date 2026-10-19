# Démo — Provoquer, lire et résoudre un conflit

| | |
|---|---|
| **Jour / bloc** | J1 après-midi — Bloc 2.4 « Conflits » (prépare le conflit volontaire du TP 1) |
| **Durée** | 15 min |
| **Prérequis** | Git ≥ 2.28, VS Code (pour la résolution graphique en étape 6) |
| **Ce qu'on montre** | pourquoi un conflit arrive (même ligne modifiée des deux côtés), lecture des marqueurs `<<<<<<<` / `=======` / `>>>>>>>`, résolution, `git add` + commit, `git merge --abort` |

## Lancer

```bash
bash demos/demo-git-conflit/demo.sh              # en salle : à l'étape 6, résolvez dans VS Code
KEEP=1 bash demos/demo-git-conflit/demo.sh       # garde le dépôt /tmp
DEMO_AUTO=1 bash demos/demo-git-conflit/demo.sh  # test sans pause (résolution automatique)
```

Le scénario reprend **exactement** celui du TP 1 (liste `<ul>` de la page « Promo DWWM ») : les apprenants reconnaîtront la situation une heure plus tard.

## Déroulé minuté

| Min | Étape | Dire | Taper / montrer | Question à poser à la salle |
|---|---|---|---|---|
| 0-2 | 1 | « Une page partagée, chacun doit y ajouter son prénom. » | `cat index.html` | « Si deux personnes ajoutent leur ligne au même endroit, que va faire Git ? » (faire voter) |
| 2-4 | 2 | « Alice et Bob partent du **même** commit. » | Graphe en « Y » | « Chacun a-t-il fait quelque chose de faux ? » (non : un conflit n'est pas une faute) |
| 4-5 | 3 | « La première PR fusionnée passe toujours sans conflit. » | Fast-forward | « Pourquoi Alice n'a-t-elle aucun conflit ? » |
| 5-7 | 4 | « Bob fusionne ensuite : Git s'arrête. » | `CONFLICT (content)`, `git status --short` montre `UU` | « Que signifie `UU` ? » (modifié des deux côtés, *unmerged*) |
| 7-10 | 5 | « On lit le fichier : HEAD = ce qui est déjà là ; en bas = ce qui arrive. » | Les marqueurs | « Quelle est la bonne résolution ici ? Garder Alice, Bob, ou les deux ? » |
| 10-13 | 6 | « VS Code propose *Accept Current / Incoming / Both*. Le choix est **métier**, pas technique. » | Ouvrir le fichier dans VS Code, *Accept Both Changes*, enregistrer | « Comment vérifier qu'il ne reste aucun marqueur ? » (`grep '<<<<<<<'`) |
| 13-15 | 7 | « On termine avec `git add` (= « c'est résolu ») puis `git commit`. » | Graphe final | « Comment éviter les conflits ? » (petites PR, `pull` souvent, se parler) — « Et si je panique ? » → `git merge --abort` |

## Pièges à anticiper

- Sur GitHub, le conflit apparaît sur la PR (*This branch has conflicts*) : montrez le bouton *Resolve conflicts* **et** la méthode locale (`git switch feature/... && git merge main`), plus robuste.
- Oublier `git add` après résolution : `git commit` refuse avec *Committing is not possible because you have unmerged files*.
- Supprimer par erreur la ligne de l'autre : insistez sur la relecture du fichier **après** résolution et sur la revue de PR.
