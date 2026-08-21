# Local devnet and 100 traders

The devnet is disposable localhost evidence, not a simulated mainnet claim.

```sh
bun install --frozen-lockfile
./scripts/devnet-up.sh
./scripts/devnet-deploy.sh
bun run scenario:devnet
./scripts/devnet-down.sh
```

`devnet-up.sh` starts Anvil with 100 funded accounts derived from a public test mnemonic and records
its PID under `.devnet/`. Never fund or reuse these accounts on a public network.

The product implementation owns `script/DevnetDeploy.s.sol` and writes `.devnet/deployment.json`.
`scenarios/run.ts` handles account derivation, concurrency, receipts and reporting;
`scenarios/trade.ts` owns the hook-specific router call. Replace the seed adapter before claiming
interaction evidence.

The scenario is green only when all intended transactions are mined successfully and the report
checks product postconditions such as balances, liabilities, winners or NFTs. Preserve failed
transaction hashes and causes in `reports/`.

Always stop the retained PID at handoff unless the user asks to keep it running.
