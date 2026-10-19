# Démo — SSH par clé et sécurisation d'un serveur

> ⚠️ **Démo formateur uniquement.** Les apprenants **ne la reproduisent pas** : dans les TP, leur poste joue le rôle du serveur (`~/taskflow-prod/`) et le déploiement automatique passe par un runner local. Cette démo montre ce qui **change sur un vrai serveur** (VPS) pour qu'ils sachent le faire en entreprise et puissent en parler à l'oral du titre pro.

| | |
|---|---|
| **Jour / bloc** | J4 matin — Bloc 5.1 « Le serveur » (théorie + démo) |
| **Durée** | 15 min |
| **Prérequis (variante A)** | un VPS ou serveur du formateur (Debian/Ubuntu) joignable, un compte avec `sudo`, une **session de secours ouverte** (console web de l'hébergeur) avant de toucher à `sshd_config` |
| **Prérequis (variante B, secours)** | Docker/Podman, client OpenSSH, port **2223** libre ; image `docker.io/linuxserver/openssh-server:version-10.2_p1-r0` pré-téléchargée |
| **Ce qu'on montre** | paire de clés ed25519 (publique / privée) ; `ssh-copy-id` ; `~/.ssh/config` ; empreinte et `known_hosts` ; utilisateur non-root + `sudo` ; désactivation du mot de passe et de root dans `sshd_config` ; pare-feu `ufw` ; `scp` ; lien avec un job de déploiement par `ssh` |

## Variante A — sur un vrai serveur (recommandée)

Remplacez `203.0.113.10` par l'IP de votre serveur. Gardez **une session SSH ou la console de l'hébergeur ouverte** pendant toute la démo : une erreur dans `sshd_config` peut vous enfermer dehors.

| Min | Dire | Taper | Montrer / question à poser à la salle |
|---|---|---|---|
| 0-2 | « Un serveur loué n'a ni écran ni clavier : on l'administre à distance avec **SSH** (*Secure Shell*), un terminal chiffré. » | — | Schéma au tableau : poste ⇄ Internet ⇄ serveur. « Qui peut essayer de se connecter à mon serveur ? » (tout Internet : montrer `sudo journalctl -u ssh \| grep -c Failed` ou `lastb \| head`) |
| 2-4 | « On remplace le mot de passe par une **paire de clés** : la publique est un cadenas qu'on pose sur le serveur, la privée est la seule clé qui l'ouvre. » | `ssh-keygen -t ed25519 -C "formateur@demo"` (avec phrase de passe) | `ls -l ~/.ssh/` : `id_ed25519` (600) et `id_ed25519.pub`. « Laquelle puis-je envoyer par e-mail ? » |
| 4-6 | « On pose le cadenas sur le serveur. » | `ssh-copy-id -i ~/.ssh/id_ed25519.pub deploy@203.0.113.10` | Sur le serveur : `cat ~/.ssh/authorized_keys`. « Que se passe-t-il si quelqu'un vole ma clé publique ? » (rien) |
| 6-7 | « Un alias évite de retenir IP, utilisateur et clé. » | Ajouter dans `~/.ssh/config` :<br>`Host taskflow-prod`<br>`  HostName 203.0.113.10`<br>`  User deploy`<br>`  IdentityFile ~/.ssh/id_ed25519` | `ssh taskflow-prod` → connecté sans mot de passe. Montrer `~/.ssh/known_hosts` et expliquer l'empreinte demandée à la 1re connexion. |
| 7-9 | « On ne travaille **jamais** en root : un utilisateur dédié, qui utilise `sudo` ponctuellement. » | `sudo adduser deploy && sudo usermod -aG sudo,docker deploy` (déjà fait avant la démo, le montrer) ; `id` | « Pourquoi le groupe `docker` équivaut-il presque à root ? » (lien avec le socket Docker monté par le runner du TP) |
| 9-12 | « Une fois la clé testée, on ferme les portes : plus de mot de passe, plus de root. » | `sudoedit /etc/ssh/sshd_config.d/99-durcissement.conf` :<br>`PasswordAuthentication no`<br>`PermitRootLogin no`<br>`KbdInteractiveAuthentication no`<br>puis `sudo sshd -t && sudo systemctl reload ssh` | **Dans un autre terminal**, vérifier : `ssh taskflow-prod` OK ; `ssh -o PubkeyAuthentication=no deploy@203.0.113.10` → *Permission denied (publickey)*. « Pourquoi tester dans un 2e terminal avant de fermer le 1er ? » |
| 12-14 | « Le pare-feu ne laisse entrer que ce qui est utile : SSH, HTTP, HTTPS. » | `sudo ufw allow OpenSSH && sudo ufw allow 80,443/tcp && sudo ufw enable && sudo ufw status verbose` | « Pourquoi autoriser OpenSSH **avant** `ufw enable` ? » — Mentionner : `unattended-upgrades`, `fail2ban`. ⚠️ Docker publie ses ports en contournant `ufw` : ne publier que le proxy (comme dans `compose.prod.yaml` du TP). |
| 14-15 | « Pour déployer : copier les fichiers puis lancer la commande à distance. C'est ce que ferait un workflow GitHub Actions sur un vrai serveur. » | `scp compose.prod.yaml taskflow-prod:~/taskflow-prod/` puis `ssh taskflow-prod 'cd ~/taskflow-prod && ./deploy.sh abc1234'` | Montrer l'extrait de workflow ci-dessous. « Où doit être stockée la clé privée utilisée par GitHub ? » (secret `SSH_PRIVATE_KEY`, jamais dans le dépôt) |

Extrait de job pour un vrai serveur (montré, non pratiqué) :

```yaml
deploy:
  runs-on: ubuntu-latest
  needs: build
  environment: production
  steps:
    - uses: actions/checkout@v4
    - name: Clé SSH
      run: |
        install -m 700 -d ~/.ssh
        echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519
        echo "${{ secrets.SSH_KNOWN_HOSTS }}" > ~/.ssh/known_hosts
    - name: Copier et déployer
      run: |
        scp compose.prod.yaml deploy/deploy.sh deploy@${{ vars.SERVER_IP }}:~/taskflow-prod/
        ssh deploy@${{ vars.SERVER_IP }} "cd ~/taskflow-prod && ./deploy.sh ${GITHUB_SHA::7}"
```

**Après la démo** : retirer la clé de démo du serveur (`authorized_keys`) si elle n'a pas vocation à rester.

## Variante B — secours, sans serveur (conteneur sshd jetable)

```bash
docker pull docker.io/linuxserver/openssh-server:version-10.2_p1-r0   # avant la séance
bash demos/demo-ssh-serveur/demo.sh
SSH_PORT=2224 bash demos/demo-ssh-serveur/demo.sh     # si 2223 est occupé
DEMO_AUTO=1 bash demos/demo-ssh-serveur/demo.sh       # test sans pause
```

Le script ne touche **ni** à votre `~/.ssh` **ni** à votre `known_hosts` : clé, config et empreintes sont créées dans un dossier `mktemp`, et tout (conteneur compris) est supprimé à la fin, même après Ctrl+C.

| Min | Étape du script | Ce qu'on montre | Question à poser à la salle |
|---|---|---|---|
| 0-2 | 1. `ssh-keygen` | clé privée (600) / clé publique | « Laquelle reste sur mon poste ? » |
| 2-4 | 2. conteneur sshd | la clé publique se retrouve dans `authorized_keys` (équivalent de `ssh-copy-id`) | « Que fait `ssh-copy-id` exactement ? » |
| 4-5 | 3. alias | bloc `Host` d'une config SSH | « Quel intérêt d'un alias ? » |
| 5-7 | 4. connexion | `whoami` → `deploy`, empreinte ajoutée à `known_hosts` | « Que signifie l'avertissement *Permanently added … to the list of known hosts* ? » |
| 7-9 | 5. refus | `PasswordAuthentication no` ; connexion par mot de passe **et** en root refusées | « Pourquoi les robots qui testent des mots de passe échouent-ils maintenant ? » |
| 9-11 | 6. `scp` + `ssh` | fichier copié, `chmod 600`, commande à distance | « Quel fichier de TaskFlow mériterait un `chmod 600` ? » (`.env`) |
| 11-12 | 7. `sudo` | `whoami` → `root` ponctuellement | « Pourquoi ne pas se connecter directement en root ? » (traçabilité, erreurs, surface d'attaque) |

Puis terminer avec le pare-feu `ufw` et l'extrait de workflow **en slides** (non démontrables dans un conteneur).

## Pièges à anticiper

- **S'enfermer dehors** (variante A) : toujours `sshd -t` avant `reload`, tester dans un 2e terminal, garder la console de l'hébergeur.
- `WARNING: UNPROTECTED PRIVATE KEY FILE!` : clé privée en 644 → `chmod 600 ~/.ssh/id_ed25519`.
- Sous Windows : OpenSSH est inclus (PowerShell) ; `ssh-copy-id` n'existe pas → `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh deploy@IP "cat >> ~/.ssh/authorized_keys"`.
- Variante B : `localhost` est déjà dans votre `known_hosts` sur un autre port ? Sans effet, le script utilise son propre fichier.
