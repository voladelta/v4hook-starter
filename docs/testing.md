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
rollback. Compute expected fees, gross-up, splits and carried remainders in an independent test
oracle; assertions that reuse production math or merely require a nonzero fee are not accounting
proof. Include values between documented examples so premature integer flooring cannot hide.

Stateful handlers count attempts, successes, exact expected failures and unexpected failures for
each action class. Include every supported exactness/direction mode and every material lifecycle
transition. Assert `attempts == successes + expected failures + unexpected failures`, require each
material class to succeed, and require unexpected failures to remain zero. Track forced funds with
an independent ghost value when the invariant distinguishes liabilities from surplus.
`test/utils/InvariantActionAccounting.sol` supplies this bookkeeping without choosing product
actions or invariants for the implementation. Its expected-revert classifier requires a nonzero
custom-error selector: empty or mismatched revert data is always unexpected. Never increment an
expected-failure counter without classifying the observed production revert.

Run a focused test during development, then `./scripts/check.sh`. A skipped required test or an empty
filter is a failure. Accept the full gate only when its process exits zero and prints `CHECK_OK`; a
tool report followed by process termination is not evidence that later stages ran.
