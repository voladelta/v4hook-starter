# Security invariants

Use these invariants to shape code and tests, not as an audit claim.

## Callback boundary

- Only PoolManager reaches production callback entry points.
- Pool keys and authorized routers are validated before accounting changes.
- Hook data is decoded with an authenticated version/domain and exact length.
- Every positive return delta is matched by PoolManager settlement and a named liability owner.
- Exact-output gross-up, partial fills and stale witnesses fail atomically.

## Identity and custody

- Router context is not user identity. Bind payer and recipient through the settlement path.
- Pull claims use effects-first accounting and resist reentrancy.
- Forced native currency is separated from user liabilities and cannot be refunded to a later caller.
- Rounding policy and carried remainders conserve value over repeated operations.
- Admin, treasury, minter and deployer roles are immutable or explicitly governed and tested.

## Liquidity and state

- Pool-scoped state uses `PoolId`; canonical-pool designs reject every other pool.
- Depth, volume, time windows and price observations define manipulation resistance explicitly.
- Same-transaction and same-block caching behavior is tested when it changes economic capacity.
- Any post-deployment registration failure rolls back deployment and ownership state atomically.

## Proof floor

Test the real PoolManager path, direct callback rejection, all supported swap quadrants, permission
bits, claims/custody conservation, token/NFT authority, malformed input, stale state and rollback.
Fuzz arithmetic boundaries and use stateful invariants for conservation and action accounting.
