# Contribuer au site « Promo DWWM »

Merci de contribuer ! Ces règles sont courtes : elles permettent à plusieurs personnes de travailler en même temps
sans se marcher dessus.

## 1. Le principe : GitHub Flow

- `main` contient toujours un site qui fonctionne. **Personne ne pousse directement sur `main`.**
- Chaque changement se fait sur **sa propre branche**, part de la dernière version de `main`, et revient dans `main`
  par une **Pull Request** (PR : demande de fusion) relue par une autre personne.

```
main     ──●──────────────●──────────●──▶
            \            /          /
feature/…    ●───●──────●   (PR relue, puis fusionnée)
```

## 2. Nommer sa branche

Format : `<type>/<sujet-court>`, en minuscules, sans accent ni espace (des tirets à la place).

| Type | Quand | Exemple |
|---|---|---|
| `feature/` | Ajout de contenu ou de fonctionnalité | `feature/carte-alice`, `feature/carte-jean-baptiste` |
| `feature/` (style) | Modification visuelle de sa carte | `feature/style-alice` |
| `fix/` | Correction d'une erreur | `fix/lien-casse-accueil` |
| `docs/` | Documentation seulement | `docs/readme-installation` |

```bash
git switch main
git pull
git switch -c feature/carte-<prenom>
```

## 3. Écrire ses messages de commit (Conventional Commits)

Format : `<type>: <description à l'impératif, en minuscules, sans point final>`

| Type | Usage | Exemple |
|---|---|---|
| `feat` | Nouveau contenu, nouvelle fonctionnalité | `feat: ajoute la carte d'Alice` |
| `fix` | Correction | `fix: corrige le lien vers la carte de Jean-Baptiste` |
| `style` | Mise en forme, CSS, sans changer le contenu | `style: change la couleur de l'avatar d'Alice` |
| `docs` | Documentation (README, CONTRIBUTING) | `docs: précise la convention de nommage` |
| `refactor` | Réorganisation sans changement visible | `refactor: regroupe les variables CSS` |
| `chore` | Tâche annexe (configuration, outillage) | `chore: ajoute le modèle de Pull Request` |

Règles :

- **un commit = une idée** ; mieux vaut trois petits commits qu'un gros « modifs diverses » ;
- la description dit **ce que fait** le commit, pas ce que vous avez fait (`ajoute`, pas `ajouté`) ;
- jamais de commit nommé `wip`, `test`, `modif` ou `aaa` sur une branche destinée à `main`.

## 4. Ajouter sa carte

1. Copiez le modèle : `cp cartes/exemple.html cartes/<prenom>.html`.
2. Personnalisez le titre, l'initiale de l'avatar, le nom et les trois rubriques. Restez bienveillant : ce site est public.
3. Ajoutez **une seule ligne** dans `index.html`, dans la liste `<ul class="promo">`, juste au-dessus du commentaire :

   ```html
   <li><a href="cartes/<prenom>.html">Prénom</a></li>
   ```

4. Vérifiez dans le navigateur : la carte s'affiche, le lien depuis l'accueil fonctionne, le lien « Retour » aussi.

## 5. Ouvrir une Pull Request

1. `git push -u origin feature/carte-<prenom>`
2. Sur GitHub, bouton **Compare & pull request**. Le texte de la PR est pré-rempli : complétez chaque rubrique.
3. À droite, **Reviewers** : choisissez une personne du groupe.
4. Une fois la PR **approuvée** et sans conflit, cliquez sur **Merge pull request**, puis **Delete branch**.

## 6. Relire la Pull Request d'un autre membre

Onglet **Files changed** de la PR :

- le code fait-il ce que dit la description ? Le lien depuis l'accueil pointe-t-il vers le bon fichier ?
- le nom de branche et les messages de commit respectent-ils ce guide ?
- y a-t-il un fichier en trop (`.DS_Store`, copie de sauvegarde) ?

Commentez **une ligne** en cliquant sur le `+` bleu dans la marge. Soyez précis et bienveillant :

| À éviter | À préférer |
|---|---|
| « C'est faux. » | « Le lien pointe vers `cartes/Alice.html` mais le fichier s'appelle `alice.html` : sous Linux, la casse compte. » |
| « Pas terrible le CSS. » | « Suggestion : utiliser `var(--color-accent)` plutôt que `#2f5bea`, pour rester cohérent avec le reste du site. » |

Puis **Review changes** > *Comment* (remarque), *Request changes* (à corriger avant fusion) ou *Approve* (prêt à fusionner).

## 7. En cas de conflit

GitHub affiche *This branch has conflicts that must be resolved* : quelqu'un a modifié les mêmes lignes avant vous.
Résolvez-le **en local** :

```bash
git switch main && git pull                 # récupérer la dernière version de main
git switch feature/carte-<prenom>
git merge main                              # Git signale le conflit dans index.html
# ouvrez index.html, gardez les DEUX lignes, supprimez les marqueurs <<<<<<< ======= >>>>>>>
git add index.html
git commit --no-edit                        # garde le message de fusion proposé par Git
git push
```

Avant de pousser, vérifiez qu'il ne reste aucun marqueur : `grep -n '<<<<<<<\|>>>>>>>' index.html` ne doit rien afficher.
