# eliza-trader-starter

A working ElizaOS agent that does **gasless token swaps** and remembers its
users — built on two published plugins:

- [`@orkid-labs/plugin-orkid`](https://github.com/orkid-labs/plugin-orkid) —
  quote, execute, dry-run, confirm, and track swaps on the Orkid gasless
  swap engine
- [`@orkid-labs/plugin-mempalace`](https://github.com/orkid-labs/plugin-mempalace) —
  persistent agent memory via MemPalace MCP (stdio or HTTP transport)

## What the agent does

- **Quotes and executes** swaps on Base, Ethereum, and Arbitrum
- **Gasless fills** — the solver pays gas; the user signs a Permit2
- **Safety-first**: always quotes first, never executes without an explicit
  `confirmed`, defaults to dry-run calldata
- **Persistent memory** — user preferences and past swaps survive restarts
- **Rebate-eligible** — volume through a partner API key accrues rebates

## Quickstart (Docker)

```bash
cp .env.example .env
# fill in OPENAI_API_KEY and ORKID_USER_ADDRESS at minimum
# add ORKID_API_KEY for partner volume tracking + rebates

docker build -t eliza-trader-starter .
docker run --env-file .env -p 3000:3000 eliza-trader-starter
```

## Quickstart (local dev)

```bash
elizaos create --type project trader-agent --yes
cd trader-agent
bun add @orkid-labs/plugin-orkid @orkid-labs/plugin-mempalace
# copy character.json into your project and point elizaos at it
elizaos start
```

## Sandbox mode — keyless

Set `ORKID_API_URL=sandbox` (the literal string) in `.env`. The sandbox
never submits transactions — `route` quotes and dry-run `solve` calldata
work **with no API key**. Anonymous callers are rate-limited per IP;
a sandbox key raises the limit.

```bash
curl -X POST https://sandbox.orkidlabs.com/v1/route \
  -H 'Content-Type: application/json' \
  -d '{"from":"USDC","to":"WETH","amount":"25","chain":"base"}'
```

`from`/`to` accept token symbols or addresses; `chain` is
`base` | `ethereum` | `arbitrum`. (Sandbox paths are `/v1/*` — no `/api`
prefix.)

## Get an API key (production + rebates)

- **Self-serve** — `POST https://orkidlabs.xyz/api/v1/signup`
  with `{ "email": "you@example.com", "project": "your-agent" }`
- **Partner tier** (rebate terms + higher limits) —
  `https://orkidlabs.xyz/partner` or `api@orkidlabs.com`

Production requests pass the key as `X-ORKID-API-Key: <key>`.

## Semantics that matter

- `route` = quote only, non-billable, doesn't count as volume
- `solve` = execution, billable, rebate-eligible volume
- `dryRun` solve = calldata only, non-billable

## Notes

- Polygon same-chain execution is paused; bridging is available.
- Fill record is public and auditable — median settled cost ~33bps vs
  oracle mid on audited fills, vs ~91bps on external public routers.
