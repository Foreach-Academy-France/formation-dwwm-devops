# Promo DWWM

Le site de présentation de la promo : une page d'accueil qui liste les membres, et **une carte HTML par personne**.
Il est construit à plusieurs, avec Git et GitHub : chaque carte arrive par une Pull Request relue par un pair.

## Voir le site

Pas d'installation : ouvrez `index.html` dans votre navigateur (double-clic, ou `xdg-open index.html` sous Linux,
`open index.html` sous macOS, `explorer.exe index.html` sous WSL).

## Structure

```
.
├── index.html              # page d'accueil : la liste <ul class="promo"> des membres
├── style.css               # styles communs (variables CSS en haut du fichier)
├── cartes/
│   └── exemple.html        # modèle de carte : à copier en cartes/<prenom>.html
├── CONTRIBUTING.md         # règles de contribution : branches, commits, Pull Requests
└── .github/
    └── pull_request_template.md   # texte pré-rempli de chaque Pull Request
```

## Ajouter sa carte

En résumé (le détail est dans [`CONTRIBUTING.md`](CONTRIBUTING.md)) :

1. créer une branche `feature/carte-<prenom>` ;
2. copier `cartes/exemple.html` en `cartes/<prenom>.html` et le personnaliser ;
3. ajouter **une** ligne dans la liste `<ul class="promo">` de `index.html` ;
4. commiter, pousser, ouvrir une Pull Request et demander une revue.

## Règles de la branche `main`

`main` est protégée : on n'y pousse jamais directement. Tout passe par une Pull Request approuvée par au moins une
autre personne.
