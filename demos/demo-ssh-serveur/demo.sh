#!/usr/bin/env bash
# =============================================================================
# Démo J4 — Bloc 5.1 : SSH par clé — VARIANTE DE SECOURS (sans vrai serveur)
#   Démo FORMATEUR uniquement : les apprenants ne la reproduisent pas.
#   Usage   : bash demo.sh             (pauses entre les étapes)
#             DEMO_AUTO=1 bash demo.sh  (sans pause, pour tester)
#             SSH_PORT=2224 bash demo.sh  (port local, 2223 par défaut)
#   Effet   : génère une clé ed25519 JETABLE dans un dossier temporaire (votre ~/.ssh
#             n'est pas touché), lance un conteneur sshd « serveur » (linuxserver/openssh-server),
#             s'y connecte, puis supprime conteneur, clé et dossier à la fin.
# =============================================================================
set -euo pipefail

DEMO_AUTO="${DEMO_AUTO:-0}"
DOCKER="${DOCKER:-docker}"
SSH_PORT="${SSH_PORT:-2223}"
IMAGE="docker.io/linuxserver/openssh-server:version-10.2_p1-r0"
CONTAINER="demo-ssh-serveur"
WORKDIR="$(mktemp -d -t demo-ssh-XXXXXX)"
CFG="$WORKDIR/ssh_config"

cleanup() {
  "$DOCKER" rm -f "$CONTAINER" >/dev/null 2>&1 || true
  rm -rf "$WORKDIR"
  echo -e "\n🧹 Conteneur $CONTAINER, clé jetable et dossier temporaire supprimés"
}
trap cleanup EXIT

etape() { echo -e "\n\033[1;34m=== $* ===\033[0m"; }
pause() {
  if [[ "$DEMO_AUTO" == "1" ]]; then return 0; fi
  read -r -p $'\n▶ Entrée pour continuer… ' _
}
run() { echo -e "\033[1;32m\$ $*\033[0m"; eval "$*"; }

etape "1. Générer une paire de clés (privée = secrète, publique = à distribuer)"
run "ssh-keygen -t ed25519 -C 'demo-formateur' -N '' -f '$WORKDIR/id_ed25519' -q"
run "ls -l '$WORKDIR'"
run "cat '$WORKDIR/id_ed25519.pub'"
echo "→ La clé PUBLIQUE se copie sur le serveur. La clé PRIVÉE ne quitte jamais votre poste."
echo "  (En vrai : ajoutez une phrase de passe ; ici -N '' pour la démo.)"
pause

etape "2. « Louer un serveur » : un conteneur sshd qui connaît notre clé publique"
run "$DOCKER run -d --name $CONTAINER -p $SSH_PORT:2222 \
  -e PUID=1000 -e PGID=1000 -e TZ=Europe/Paris \
  -e USER_NAME=deploy -e PUBLIC_KEY=\"\$(cat '$WORKDIR/id_ed25519.pub')\" \
  -e PASSWORD_ACCESS=false -e SUDO_ACCESS=true -e USER_PASSWORD=demo-sudo \
  $IMAGE >/dev/null"
echo "(équivalent de « ssh-copy-id deploy@serveur » : la clé publique va dans ~/.ssh/authorized_keys)"
for _ in $(seq 1 30); do
  "$DOCKER" exec "$CONTAINER" sh -c 'test -s /config/.ssh/authorized_keys && pgrep -f "sshd" >/dev/null' 2>/dev/null && break
  sleep 1
done
sleep 2
run "$DOCKER exec $CONTAINER cat /config/.ssh/authorized_keys"
pause

etape "3. Un alias dans la config SSH (en vrai : ~/.ssh/config)"
cat > "$CFG" <<CONF
Host demo-serveur
    HostName localhost
    Port $SSH_PORT
    User deploy
    IdentityFile $WORKDIR/id_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    UserKnownHostsFile $WORKDIR/known_hosts
CONF
run "cat '$CFG'"
pause

etape "4. Se connecter : aucune question de mot de passe"
run "ssh -F '$CFG' demo-serveur 'echo \"Connecté en tant que : \$(whoami) sur \$(hostname)\"; id'"
run "cat '$WORKDIR/known_hosts' | cut -c1-80"
echo "→ À la 1re connexion, l'empreinte du serveur est mémorisée dans known_hosts."
echo "  Si elle change un jour : alerte « REMOTE HOST IDENTIFICATION HAS CHANGED » (possible attaque)."
pause

etape "5. Le mot de passe est refusé (PasswordAuthentication no)"
run "$DOCKER exec $CONTAINER grep -E '^(PasswordAuthentication|PermitRootLogin)' /config/sshd/sshd_config || true"
run "ssh -F '$CFG' -o PubkeyAuthentication=no -o PreferredAuthentications=password -o BatchMode=yes demo-serveur true 2>&1 || true"
run "ssh -F '$CFG' -o BatchMode=yes -l root demo-serveur true 2>&1 || true"
echo "→ Ni mot de passe, ni root : seules les clés autorisées de l'utilisateur deploy passent."
pause

etape "6. Copier un fichier (scp) et lancer une commande à distance"
echo "IMAGE_TAG=abc1234" > "$WORKDIR/exemple.env"
run "scp -F '$CFG' -q '$WORKDIR/exemple.env' demo-serveur:/config/exemple.env"
run "ssh -F '$CFG' demo-serveur 'chmod 600 ~/exemple.env && ls -l ~/exemple.env && cat ~/exemple.env'"
echo "→ C'est exactement ce que ferait un job de déploiement : scp des fichiers, puis ssh 'docker compose up -d'."
pause

etape "7. sudo : l'utilisateur deploy n'est pas root, mais peut le devenir ponctuellement"
run "ssh -F '$CFG' demo-serveur 'echo demo-sudo | sudo -S -p \"\" whoami'"
echo -e "\n✅ Fin de la démo SSH. Sur un vrai serveur, ajouter : pare-feu (ufw), mises à jour, fail2ban."
