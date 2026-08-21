# Agent instructions

Build the requested hook as a complete vertical product: contracts, real PoolManager proof,
deployment scripts, devnet scenario, and dapp boundary. Keep the common path small and delete seed
components the product does not use.

## Start here

Read `README.md`, `foundry.toml`, `remappings.txt`, and the smallest owned surface that answers the
request. Search the owning pinned dependency path for an exact symbol before widening inspection.
Treat `out/`, `cache/`, `broadcast/`, `.devnet/`, and `reports/` as generated evidence.

| Need | Start here | Then read |
| --- | --- | --- |
| Hook callbacks, permissions, deltas | `src/StarterHook.sol`, pinned BaseHook and `IHooks` | `docs/hook.md`, `docs/security.md` |
| ERC-20 or NFT companion | `src/tokens/`, pinned OpenZeppelin base | `docs/tokens.md` |
| Real PoolManager tests | `test/integration/`, `test/utils/v4hook-testkit/` | `docs/testing.md` |
| Chainlink randomness | `src/vrf/`, pinned Chainlink closure | `docs/vrf.md` |
| Browser or Viem client | `ui/`, `deployments/` | `docs/dapp.md` |
| One hundred local traders | `scripts/devnet-*`, `scenarios/` | `docs/devnet.md` |
| Testnet preparation or deployment | `script/`, `scripts/testnet-*` | `docs/testnet.md` |
| Pinned dependency source or provenance | the owned import, `remappings.txt` | `docs/vendor.md`, `vendor.lock.json` |
| Multi-step autonomous delivery | current Git state and focused failures | `docs/workflow.md` |

The pinned dependency map is:

- PoolManager interfaces, callbacks, types and libraries: `vendor/v4-core/src/`
- BaseHook, routers, PositionManager and HookMiner: `vendor/v4-periphery/src/`
- token and security bases: `vendor/openzeppelin-contracts/contracts/`
- direct-funded VRF base and interface: `vendor/chainlink-evm/`
- test/script utilities: `vendor/forge-std/src/`
- Permit2 and Solmate: transitive v4 dependencies; enter only from an exact import
- local v4 fixtures: `test/utils/v4hook-testkit/`

`vendor/` is read-only. Update one dependency, its provenance, imports and tests as one reviewed
change. Search vendor only through a known owned import; the testkit artifact files contain opaque
bytecode and are not source-reading targets. See `docs/vendor.md` before widening a dependency
search.

## Work to completion

For a complete implementation, follow `docs/workflow.md`. Turn the request into one compact,
checkable specification, implement one production slice at a time, and keep the nearest behavioral
proof green. When subagents are available, use fresh read-only review, bounded repair, and
independent verification; the primary agent retains the completion decision.

Every implementation must:

- use inherited PoolManager-only callback entry points and minimal hook permissions;
- bind user or beneficiary identity at an authenticated settlement boundary rather than callback
  `sender` assumptions;
- reconcile every return delta, token movement, claim and liability;
- test exact-input and exact-output in both directions when swaps are supported;
- test rollback and hostile paths through the real pinned PoolManager;
- keep companion token/NFT authority, supply and recovery policy explicit;
- keep VRF requests outside PoolManager callbacks and callbacks limited to terminal storage;
- replace `scenarios/trade.ts` with the real intended router path before claiming devnet completion;
- update `deployments/*.json` consumers whenever deployment addresses or ABIs change.

Run the narrowest focused proof first. Finish local work with:

```sh
./scripts/check.sh
```

Use Bun for the TypeScript workspace (`bun install --frozen-lockfile`, `bun run ...`). Run
`SKIP_APP=1 ./scripts/check.sh` only when the task explicitly excludes the dapp and scenario layer.

For a complete product path, also run the devnet lifecycle from `docs/devnet.md`. Testnet work stops
after the fork dry-run unless the user explicitly authorizes broadcast for the named network.

## Authority

Local source edits, tests, generated local manifests and disposable localhost processes are in
scope for build requests. Signing, wallet access, paid services, testnet/mainnet broadcast,
verification publication, dependency installation, and external repository writes require explicit
user authority. Never read or print secrets; user-run broadcast commands may reference an existing
Foundry keystore account by name.

## Completion

Complete means the requested behavior exists through its production path, relevant focused and full
checks pass, seed references are removed or classified, devnet evidence exists when the product
includes interaction, and remaining external actions are reported without being performed.
