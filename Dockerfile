# Build Stage 1

FROM node:22-alpine AS build
WORKDIR /app

RUN corepack enable

# Copy package.json and your lockfile
COPY package.json ./

# Install dependencies
RUN npm i

# Copy the entire project
COPY . ./

# Build the project
RUN npm run build

# Build Stage 2

FROM node:22-alpine
WORKDIR /

# Only `.output` folder is needed from the build stage
COPY --from=build /app/.output/ ./

# Change the port and host
ENV PORT=80
ENV HOST=0.0.0.0

EXPOSE 80

CMD ["node", "server/index.mjs"]