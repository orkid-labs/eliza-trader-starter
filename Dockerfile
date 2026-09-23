# Use the official Bun image as base
FROM oven/bun:1.4 AS base

WORKDIR /app

# Copy character and env files
COPY character.json ./
COPY .env.example ./.env

# Install elizaos CLI
RUN bun add -g elizaos

# Create the project and install the Orkid plugins
RUN elizaos create --type project trader-agent --yes && \
    cd trader-agent && \
    bun add @orkid-labs/plugin-orkid @orkid-labs/plugin-mempalace

# Copy the character file into the project
COPY character.json ./trader-agent/src/character.ts

# Build the project
RUN cd trader-agent && bun run build

EXPOSE 3000

WORKDIR /app/trader-agent
CMD ["elizaos", "start"]
