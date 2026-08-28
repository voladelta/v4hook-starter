# Hookr integration

This branch targets Hookr's source-review path for third-party Uniswap v4 hooks. `StarterHook` is a
`standalone-hook-product`: it remains the only root hook in a new `PoolKey` and does not compose with
Hookr native blocks.

The machine-readable submission artifact is `integrations/hookr/manifest.json`. It stays
`source-only` until an exact deployment, verified runtime, initialized pool, liquidity, routing, and
final-settlement evidence exists.

## V6.1 boundary

Hookr pull request 3 proposes the external-hook V2 schema and V6.1 capability metadata. It does not
publish a V6.1 Solidity ABI, transaction encoder, route signer, or deployment. Its named source
checkpoint `5168888ed69cc738492368203197ee72a009a964` is not available from the public repository.

Do not add a guessed executor interface. A later runtime slice needs all of these upstream artifacts:

- the exact V6.1 source and ABI;
- the `ExecutionRequest` tuple, event signature, and EIP-712 types;
- authenticated recipient semantics that do not use `tx.origin`;
- a promoted deployment manifest and exact router/fork target.

## Local proof

Run:

```sh
node scripts/validate-hookr-manifest.mjs
forge test --match-path test/integration/StarterHook.t.sol -vv
```

The manifest declares every permission and enabled callback. The Foundry suite compares those flags
with the deployed hook, rejects direct callbacks, checks PoolId isolation, and reconciles final test
wallet balances for all four swap quadrants through the real pinned PoolManager.

The dependency-free evaluator is a preflight for this source-only draft. It is not AJV-equivalent
and does not satisfy Hookr's official `ajv@8.20.0` and `ajv-formats@3.0.1` gate.

The manifest keeps each public route-evidence status at `untested` while this proof exists only on a
local branch. After an authorized push, repin the source or evidence URL to an immutable public
commit, run Hookr's upstream AJV validator, and promote only the rows backed by that URL.

The preflight is local only. Publishing the branch, opening the Hookr integration issue, deploying a
hook, or submitting it to Uniswap are separate external actions.
