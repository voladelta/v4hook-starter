# Viem dapp integration

The dapp consumes one generated deployment manifest rather than duplicating addresses in source.
`ui/public/deployment.json` is the local schema example; `deployments/sepolia.example.json` shows
the testnet inputs. Deployment copies the resulting public manifest into `ui/public/`.

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
