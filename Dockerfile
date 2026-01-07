# ======================
# BUILD STAGE
# ======================
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN node -v && npm -v && ls -la
RUN npm ci

COPY . .
RUN npm run build

# ======================
# PRODUCTION STAGE
# ======================
FROM node:20-alpine

WORKDIR /usr/src/app

RUN addgroup -S nestjs && adduser -S nestjs -G nestjs

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /usr/src/app/dist ./dist

ENV NODE_ENV=production

RUN chown -R nestjs:nestjs /usr/src/app
USER nestjs

EXPOSE 3000
CMD ["node", "dist/main.js"]
