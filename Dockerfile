# ── Stage 1: Build the React app ────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and install ALL dependencies (including devDependencies)
# We need vite and react plugins to build
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build-time environment variables
# These get baked into the JavaScript bundle at build time
ARG VITE_API_URL
ARG VITE_STORE_NAME
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_STORE_NAME=$VITE_STORE_NAME

# Build the React app — produces the dist/ folder
RUN npm run build

# ── Stage 2: Serve with nginx ────────────────────────────────────────────────
FROM nginx:alpine AS production

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/

# Copy the built React app from Stage 1
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
