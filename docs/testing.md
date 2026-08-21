# Testing

Behavioral proof should cross the same boundary production uses.

## Layout

- `test/unit/`: pure math, token/NFT policy, authorization and isolated lifecycle state.
- `test/integration/`: pinned PoolManager, PositionManager, router and settlement behavior.
- `test/fuzz/`: arithmetic and state-transition properties with bounded valid domains.
- `test/invariant/`: stateful conservation, solvency and exact action accounting.
- `test/mocks/`: external services only; never mock PoolManager business behavior.

`test/utils/v4hook-testkit/` deploys the real pinned v4 bytecode locally. Treat its artifact sources
as opaque fixtures and read `PROVENANCE.md` before changing them.

## Required swap matrix

When the hook changes swaps, cover exact-input and exact-output for both directions. Assert executed
PoolManager deltas, hook return deltas, payer/recipient balances, liabilities, remainders and full
rollback. A nonzero fee assertion is not accounting proof.

Stateful handlers count attempts, successes, exact expected failures and unexpected failures for
each action class. Assert the relationships and require each material action class to execute.

Run a focused test during development, then `./scripts/check.sh`. A skipped required test or an empty
filter is a failure.
