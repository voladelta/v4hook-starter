# Agent guide

For hook builds, deliver the requested product through every surface it needs: contracts, real
PoolManager proof, deployment, devnet interaction, and dapp integration. Remove unused seed
components so the finished repository describes one product. Keep focused requests within their
requested scope.

## Work within the task

Treat a request to build or fix as authority to do the work within the Authority section below.
Resolve routine choices from the request and source. Continue until the requested result and its
required checks are complete. Ask only when missing input changes the result or authorized scope;
continue independent work while waiting.

User instructions take precedence over skill guidance, subject to system and developer rules.
Do not infer an approval step from a skill default. If an instruction blocks work, name and link
to its file, quote the rule, and state the input or authority needed to proceed.

Use literal language and ASD-STE100 Simplified Technical English. State the main point early.
Use short paragraphs, simple words, and active verbs. Use lists for steps or comparisons. Report
what changed, what was checked, and any remaining gap. Avoid stock phrases and repeated summaries.

## Choose the workflow

- **Focused edit:** inspect the owning surface, make the smallest coherent change, and run its
  nearest proof.
- **Multi-surface build:** follow `docs/workflow.md`. Use one compact task contract when needed;
  an already-checkable request does not need another specification.
- **Repository change:** trace the affected behavior through its implementation and consumers.
  Make the smallest coherent change, preserve unrelated work, and use `docs/testing.md` to check
  the result. Inspect the final diff for unintended changes.
- **Material review:** after focused proof is green, follow the review and repair stage in
  `docs/workflow.md` when a change alters architecture, APIs, invariants, security, persistence,
  concurrency, or several product surfaces.

Use this repository's source, scripts, and documentation directly.

## Route the task

Open only the smallest owned surface that can answer the request. Read `README.md` for starter
orientation or its copy workflow, `foundry.toml` for Solidity build or test behavior, and
`remappings.txt` when tracing an import. Generated evidence lives in `out/`, `cache/`, `broadcast/`,
`.devnet/`, and `reports/`; treat it as output rather than source.

| Trigger | Read first | Disclose next |
| --- | --- | --- |
| Hook callbacks, permissions, or deltas | `src/StarterHook.sol` and its exact pinned imports | `docs/hook.md`, then `docs/security.md` |
| Authenticated native/token swaps | `src/router/AuthenticatedNativeTokenRouter.sol` and its integration test | `docs/hook.md` |
| ERC-20 or NFT companion | `src/tokens/` and the exact OpenZeppelin base | `docs/tokens.md` |
| PoolManager, fuzz, or invariant proof | `test/integration/` or the affected test | `docs/testing.md` |
| Loops, batches, cohorts, or storage growth | the public entry point and its maximum bound | `docs/gas.md` |
| Chainlink randomness | `src/vrf/` and the exact pinned Chainlink base | `docs/vrf.md` |
| Browser or Viem behavior | `ui/` and `deployments/` | `docs/dapp.md` |
| One hundred local traders | `scenarios/` and `scripts/devnet-*` | `docs/devnet.md` |
| Testnet preparation or deployment | `script/` and `scripts/testnet-*` | `docs/testnet.md` |
| Dependency source, provenance, or upgrade | the owned import and `remappings.txt` | `docs/vendor.md` |
| Foundry flags, failures, or configuration | installed `forge --version` and exact `--help` | `references/foundry/README.md` |

Search a pinned dependency only from a known owned import and exact symbol. `vendor/` is read-only;
`docs/vendor.md` owns its map and upgrade procedure. Testkit artifact files are opaque bytecode, not
source-reading targets.

## Preserve product invariants

- Use inherited PoolManager-only callback entry points and enable only callbacks the product uses.
- Bind payer, recipient, or beneficiary identity at an authenticated settlement boundary; callback
  `sender` alone is not user identity.
- Reconcile every return delta, token movement, claim, remainder, and liability through the real
  PoolManager path.
- Keep contract interfaces, deployment scripts, manifests, scenarios, and UI consumers synchronized.
- Gate any user-callable work that grows with inputs or storage through `docs/gas.md` before
  expanding downstream surfaces.

The routed document owns branch-specific requirements for swaps, tokens, VRF, tests, devnet, and
testnet. Apply every requirement on each branch the product includes.

## Verify

Use `docs/testing.md` to select checks for the changed surface. An interactive product build also
completes the devnet gate in `docs/devnet.md`. Testnet preparation and its broadcast boundary live
in `docs/testnet.md`.

## Authority

Build requests authorize local source edits, tests, generated local manifests, and disposable
localhost processes, including transactions from the disposable devnet accounts in `docs/devnet.md`.
Signing outside that localhost fixture, wallet access, paid services, public-network broadcast,
verification publication, dependency installation, and external repository writes require explicit user
authority. Keep secrets out of commands, output, files, and prompts; a user-run broadcast may name
an existing Foundry keystore account.

Reuse explicit authority already given for the same action and scope. Complete authorized local
preparation before asking for any remaining external authority. Preserve unrelated user changes.

## Completion

For documentation edits, complete means the instructions are consistent, referenced paths resolve,
and the diff stays within scope. Report static review separately from runtime evidence.

For product changes, complete means the requested artifact owns the required behavior, the real
consumer uses that artifact, and focused proof is causally dependent on it. Every applicable routed requirement and
gate is satisfied, unused seed references are removed or classified, interactive products have
devnet evidence, and remaining external actions are reported without being performed.
