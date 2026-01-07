# ======================
# BUILD STAGE
# ======================
FROM node:22-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency files first (cache optimization)
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build NestJS app
RUN npm run build


# ======================
# PRODUCTION STAGE
# ======================
FROM node:22-alpine

WORKDIR /usr/src/app

# Create non-root user for security
RUN addgroup -S nestjs && adduser -S nestjs -G nestjs

# Install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy compiled app
COPY --from=builder /usr/src/app/dist ./dist

ENV NODE_ENV=production

# File permissions
RUN chown -R nestjs:nestjs /usr/src/app
USER nestjs

EXPOSE 3000

CMD ["node", "dist/main.js"]
