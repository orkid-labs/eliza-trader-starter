# ElizaOS trading agent — Orkid gasless swaps + MemPalace memory
FROM oven/bun:1.4

WORKDIR /app

# elizaOS CLI (v1.7.x — @elizaos/cli provides the `elizaos` binary)
RUN bun add -g @elizaos/cli

# Scaffold the agent project
RUN elizaos create --type project trader-agent --yes

WORKDIR /app/trader-agent

# Orkid plugins + model providers (Groq free-tier or OpenAI)
RUN bun add @orkid-labs/plugin-orkid @orkid-labs/plugin-mempalace \
    @elizaos/plugin-groq @elizaos/plugin-openai

# Orkid Trader character (replaces the scaffold's default Eliza)
COPY src/character.ts src/character.ts

# Build the project
RUN bun run build

EXPOSE 3000
CMD ["elizaos", "start"]
