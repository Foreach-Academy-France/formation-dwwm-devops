#!/usr/bin/env bash
# =============================================================================
# Génère un certificat auto-signé pour taskflow.localhost dans ./certs/
#   certs/taskflow.crt  (certificat, public)
#   certs/taskflow.key  (clé privée : ne JAMAIS la commiter)
# Utilise openssl s'il est installé, sinon un conteneur Alpine.
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p certs

if [[ -f certs/taskflow.crt && -f certs/taskflow.key ]]; then
  echo "Certificat déjà présent dans certs/ (supprimez-le pour le régénérer)."
  exit 0
fi

OPENSSL_ARGS=(req -x509 -nodes -days 365 -newkey rsa:2048
  -keyout /out/taskflow.key -out /out/taskflow.crt
  -subj "/CN=taskflow.localhost"
  -addext "subjectAltName=DNS:taskflow.localhost")

if command -v openssl >/dev/null 2>&1; then
  openssl "${OPENSSL_ARGS[@]/\/out/certs}"
else
  docker run --rm -v "$PWD/certs:/out" docker.io/library/alpine:3.21 \
    sh -c "apk add --no-cache openssl >/dev/null && openssl ${OPENSSL_ARGS[*]@Q} && chmod 644 /out/taskflow.key"
fi

echo "Certificat créé :"
ls -l certs/
