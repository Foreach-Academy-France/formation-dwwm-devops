# =============================================================================
# Runner GitHub Actions self-hosted du lab TaskFlow
# Base : myoung34/github-runner (Ubuntu 24.04 + agent actions/runner ; il
# s'enregistre tout seul au démarrage avec REPO_URL + RUNNER_TOKEN).
# Cette image fournit déjà : docker CLI, plugin « docker compose », git, curl, jq.
# On ajoute seulement une vérification au build : si une future version de
# l'image de base perdait un outil, le build échouerait ici, pas pendant un déploiement.
# =============================================================================
FROM docker.io/myoung34/github-runner:ubuntu-noble

USER root
RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && docker --version && docker compose version && curl --version | head -n1 && jq --version
