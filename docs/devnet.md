# Local devnet and 100 traders

The devnet is disposable localhost evidence, not a simulated mainnet claim.

```sh
bun install --frozen-lockfile
./scripts/devnet-check.sh
```

`devnet-check.sh` runs the complete lifecycle with cleanup traps and prints `DEVNET_OK` only after
deployment, the scenario and shutdown all succeed. It binds a unique ownership token before
startup, so signals and readiness failures stop only the Anvil process it created. The full check
also exercises those two cleanup paths. Use the individual commands when developing one stage;
always run the wrapper before completion.

`devnet-up.sh` starts Anvil with 100 funded accounts derived from a public test mnemonic and records
its PID under `.devnet/`. Never fund or reuse these accounts on a public network.

The product implementation owns `script/DevnetDeploy.s.sol` and writes `.devnet/deployment.json`.
The deploy wrapper copies that manifest to the ignored `ui/public/deployment.json`; shutdown removes
the UI copy so verification leaves the tracked tree unchanged.
`scenarios/run.ts` handles account derivation, concurrency, receipts and reporting;
`scenarios/trade.ts` owns the hook-specific router call. Replace the seed adapter before claiming
interaction evidence.

The runner preflights every prepared call with `eth_call`, then submits with an explicit gas limit
instead of concurrently estimating against changing pool state. The default is `1,000,000` gas;
override it with `TRADER_GAS_LIMIT` or set `gas` on a prepared trade when the production action has
an evidenced bound. A failure report records its stage, selector, value, gas limit, transaction hash,
gas used and post-receipt replay error when available.

The scenario is green only when all intended transactions are mined successfully and the report
checks product postconditions such as balances, liabilities, winners or NFTs. Preserve failed
transaction hashes and causes in `reports/`.

Completion requires `DEVNET_OK`, a checked report, no listener on the configured port and a clean
tracked tree. Preserve `.devnet/deployment.json` and `reports/` as ignored evidence.
