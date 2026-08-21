# Viem dapp integration

The dapp consumes one generated deployment manifest rather than duplicating addresses in source.
`ui/public/deployment.example.json` documents the browser schema;
`deployments/sepolia.example.json` shows testnet inputs. Deployment writes the ignored
`ui/public/deployment.json`, and devnet shutdown removes it so verification remains clean.

## Boundary

- Verify the wallet chain before reads, simulations or writes.
- Read contract addresses and pool parameters from the manifest.
- Simulate writes, present exact token/value/slippage effects, then request wallet approval.
- Use the product's intended router. Universal Router flows bind Permit2 approvals, deadlines,
  recipients and hook data explicitly.
- Wait for receipts and derive success from status plus product postconditions, not the transaction
  hash alone.
- Treat emitted events as indexing hints; read authoritative balances and claim state from contracts.

`ui/` is deliberately small: wallet connection, manifest loading and status display. The product
agent adds hook-specific reads and actions after contract interfaces stabilize. Keep private keys
out of the browser and repository.

The dapp boundary is complete when every supported write uses its production entry point, routed
swaps use the intended router, simulation and wallet chain checks precede approval, receipt status
and product postconditions determine success, and no address or pool parameter is duplicated outside
the manifest.
