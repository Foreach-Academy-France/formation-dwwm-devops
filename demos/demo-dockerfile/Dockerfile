# =============================================================================
# Dockerfile OPTIMISÉ — même application, bonnes pratiques
#   (c'est la base de api/Dockerfile du fil rouge TaskFlow)
# =============================================================================

# ✅ Image légère (Alpine) et version de Node FIXÉE
FROM docker.io/library/node:20-alpine

# ✅ Mode production (certaines bibliothèques, dont Express, s'optimisent)
ENV NODE_ENV=production

WORKDIR /app

# ✅ On copie D'ABORD les seuls fichiers de dépendances…
COPY package.json package-lock.json ./

# ✅ … puis on installe : cette couche reste en cache tant que les dépendances ne changent pas
#    npm ci = installation exacte du lockfile ; --omit=dev = pas de nodemon en prod
RUN npm ci --omit=dev && npm cache clean --force

# ✅ Le code en dernier : c'est ce qui change le plus souvent
COPY src ./src

# ✅ Utilisateur non-root (fourni par l'image node)
USER node

# ✅ Documente le port écouté par l'application
EXPOSE 3000

# ✅ Docker sait si l'application répond vraiment (statut « healthy »)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# ✅ Forme « exec » (tableau JSON) : node reçoit directement SIGTERM
CMD ["node", "src/server.js"]
