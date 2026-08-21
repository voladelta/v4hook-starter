# v4hook starter

An opinionated, copyable Uniswap v4 product starter: hook, optional ERC-20/ERC-721 companions,
native-funded Chainlink VRF, real PoolManager tests, local trader scenarios, testnet scripts and a
small Viem frontend.

## Start a project

Copy without the template repository's Git history:

```sh
rsync -a \
  --exclude='.git' --exclude='node_modules' --exclude='out' --exclude='cache' \
  --exclude='broadcast' --exclude='.devnet' --exclude='reports' --exclude='ui/dist' \
  /path/to/v4hook-starter/ /path/to/my-hook/
cd /path/to/my-hook
git init
git add .
git commit -m "chore: initialize v4 hook project"
```

Then tell a coding agent:

> Implement this hook idea: `<idea>`. Follow `AGENTS.md`, work autonomously through implementation,
> review, repair and verification, and stop before any live broadcast.

The agent starts with the repository map in `AGENTS.md`; task-specific detail lives under `docs/`.

## Baseline

```sh
bun install --frozen-lockfile
./scripts/check.sh
```

The baseline contains:

- `src/StarterHook.sol`: replaceable minimal BaseHook example;
- `src/tokens/`: fixed-supply ERC-20 and immutable-minter ERC-721 seeds;
- `src/vrf/`: VRF v2.5 native direct-funding lifecycle reference;
- `test/integration/`: real pinned PoolManager and PositionManager behavior;
- `script/`: Foundry deployment and liquidity scripts;
- `scripts/`: local checks, devnet lifecycle and testnet boundaries;
- `scenarios/`: 100-wallet Viem runner with a hook-specific trade adapter;
- `ui/`: minimal Viem browser client consuming a deployment manifest;
- `vendor/`: one pinned Solidity dependency lane with provenance.

Delete seed contracts and tests the product does not use. Keep contracts, deployment scripts,
manifests, scenarios and UI consumers synchronized.

## Devnet

After the product agent implements `script/DevnetDeploy.s.sol` and `scenarios/trade.ts`:

```sh
bun install --frozen-lockfile
./scripts/devnet-up.sh
./scripts/devnet-deploy.sh
bun run scenario:devnet
./scripts/devnet-down.sh
```

The scenario derives 100 disposable Anvil accounts, sends the intended trades, waits for receipts
and writes `reports/devnet.json`.

## Testnet

```sh
./scripts/testnet-dry-run.sh sepolia
```

Dry-run preparation does not authorize broadcast. The user separately runs
`scripts/testnet-deploy.sh` with a named Foundry keystore account after approving the target network.

## Dependency lane

The starter vendors pinned v4-core, v4-periphery, Permit2, Solmate, OpenZeppelin Contracts,
Forge Std and the minimal Chainlink direct-funding closure. `vendor.lock.json` records exact sources
and revisions; `docs/vendor.md` maps what each tree owns and where an agent should look first. Dapp
dependencies are pinned by `bun.lock`, not Solidity vendor. Bun is the preferred JavaScript runtime;
the check script retains an npm fallback for environments without Bun.

This starter and its examples are unaudited. Passing local checks is necessary engineering evidence,
not an audit or permission to deploy.
