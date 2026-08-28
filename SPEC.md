# Hookr V6.1 integration readiness

## Destination

The repository provides a source-only Hookr external-hook V2 manifest draft for `StarterHook` and
proves that the declared callback and routing behavior runs through the real pinned PoolManager.

## Anchors

- Hookr PR `Hookr-fun/hookr-contracts#3` head
  `2b0ee64ed85a2d47037efebb8de144cafa23054e`.
- `integrations/hooks/schema.v2.json` and the external-hook semantic validator at that revision.
- `src/StarterHook.sol`, `script/DeployHook.s.sol`, and `test/integration/StarterHook.t.sol`.

## Deliverables

- A pinned, locally checked `hookr.external-hook.v2` source manifest draft.
- Real-PoolManager proof for all four swap quadrants, final test-wallet settlement, permission bits,
  arbitrary hook data, and direct-callback rejection.
- Dependency provenance and user-facing documentation for the Hookr source-review boundary.

## Invariants

- `StarterHook` remains a standalone external root. It does not claim composition with Hookr native
  blocks, an executor adapter, a deployment, routing approval, or production V6.1 status.
- The existing PoolManager-only callback boundary, four enabled callbacks, zero return deltas, and
  per-`PoolId` accounting remain unchanged.
- No guessed V6.1 Solidity interface, `ExecutionRequest`, EIP-712 type, or registration call is added.
- The branch does not deploy, publish, submit a Hookr issue, or write to an external repository.

## Proof

- A dependency-free preflight checks this draft against the vendored schema rules, and Hookr's pinned
  semantic validator accepts it. This preflight is not a substitute for Hookr's upstream AJV gate.
- Focused Foundry integration tests exercise the repository hook through the real PoolManager.
- `./scripts/check.sh` ends with `CHECK_OK`.

## Gate

This exploration is complete when the source-review artifact and local proof are green and the
unpublished V6.1 ABI, deployment, upstream AJV gate, and external submission steps are reported as
explicit blockers.
