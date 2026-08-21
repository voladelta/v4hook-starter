# Testnet deployment

Preparation and broadcast are separate authority boundaries.

## Prepare

1. Choose the named testnet and verify PoolManager, PositionManager, Universal Router, Permit2 and
   Chainlink wrapper addresses from official registries.
2. Record chain ID, addresses and expected bytecode in `deployments/<network>.json`.
3. Run `./scripts/testnet-dry-run.sh <network>` against a pinned fork block.
4. Exercise deployment, pool initialization, liquidity, all swap quadrants, VRF request wiring and
   dapp manifest reads on the fork.

Preparation stops with a user-run command and explicit remaining authorities.

## Broadcast

Run `./scripts/testnet-deploy.sh <network> --account <foundry-keystore-name>` only after the user
authorizes broadcast to that network. Scripts may reference the keystore alias but never read,
print, export or request its secret. Confirm receipt status, deployed bytecode, hook permission bits,
constructor bindings and pool state before publishing the manifest to `ui/public/deployment.json`.
