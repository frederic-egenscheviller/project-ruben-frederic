FROM node:18-slim AS build

WORKDIR /usr/local/app

COPY package*.json ./

RUN npm ci --omit=dev && npm cache clean --force
RUN find node_modules -type d -name "test" -o -name "docs" -o -name "__tests__" | xargs rm -rf \
 && find node_modules -type f -name "*.md" -delete

COPY . .

FROM node:18-alpine AS final

WORKDIR /usr/local/app

COPY --from=build /usr/local/app ./

ENV PORT 4000

EXPOSE 4000

CMD ["node", "server.js"]
