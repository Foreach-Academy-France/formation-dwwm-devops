# Dockerfile écrit par un collègue pressé.
# Il CONSTRUIT, mais le conteneur ne fonctionne pas et il y a plusieurs mauvaises pratiques.
# À vous de trouver et corriger les problèmes (voir 02-dockerfile-a-corriger.md).

FROM docker.io/library/node:latest

COPY . .

RUN npm install

ENV DATABASE_URL=postgres://taskflow:SuperSecret2026@db:5432/taskflow
ENV APP_ENV=production

EXPOSE 8080

CMD node src/index.js
