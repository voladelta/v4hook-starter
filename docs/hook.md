# Hook design

Start from the product's fund and identity flow, then select callbacks. An enabled callback without
a production use is additional attack surface and an address-mining constraint.

## Design order

1. Define supported pool keys, currencies, fee mode and token ordering.
2. Define the intended router and the boundary that authenticates payer, recipient and beneficiary.
3. Map exact-input and exact-output accounting in both directions.
4. Define which contract owns funds, claims, remainders and recovery.
5. Select the minimum callbacks and return-delta flags needed by that model.
6. Keep `getHookPermissions`, mined address flags, deployment script and tests identical.

Use the inherited external callbacks from the pinned BaseHook. Implement internal `_before*` and
`_after*` methods; retain its PoolManager-only check. Callback `sender` is the immediate router or
locker, not automatically the end user.

## Pinned source anchors

- `vendor/v4-periphery/src/utils/BaseHook.sol`
- `vendor/v4-core/src/interfaces/IHooks.sol`
- `vendor/v4-core/src/libraries/Hooks.sol`
- `vendor/v4-core/src/types/BeforeSwapDelta.sol`
- `vendor/v4-core/src/types/BalanceDelta.sol`
- `vendor/v4-periphery/src/utils/HookMiner.sol`

Read only the symbols used by the chosen design. The pinned code is the implementation authority;
external documentation is for a specifically missing current network fact, not startup research.
