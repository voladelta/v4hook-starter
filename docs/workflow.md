# Autonomous delivery loop

Use this loop for a complete hook, material adaptation, or request with several dependent surfaces.
Ordinary focused edits can use `inspect → implement → check` directly.

For a multi-step build, keep one ignored `.workflow/ledger.md` with only the parent-gate status,
verified evidence, open assumptions, accepted or rejected outputs, current frontier, blockers, and
next verifier. Update it after material observations so another session resumes from verified state.
Do not turn the ledger into a second specification or narrative diary.

## Contract

Inspect the repository first, then write one compact `SPEC.md` containing only:

- observable product behavior;
- economic, custody, identity and authority invariants;
- supported swap, token, NFT, randomness, dapp and deployment paths;
- target-chain gas assumptions and a maximum-transaction budget for scalable public paths;
- behavioral proof required for each material invariant;
- explicit external gaps and the stopping boundary.

For a port, map every material reference behavior before changing production code. For a fresh idea,
do not create a separate protected-invariants document or speculative design report.

This step is complete when every product decision that could change implementation or proof is
checkable and implementation mechanics remain with the code owner.

## Vertical slices

Implement one end-to-end path at a time:

```text
requirement → failing real-boundary proof → production change → focused green
```

Start with compiling interfaces and one real PoolManager interaction. Add the closest rollback or
hostile case before expanding. Keep contracts, deployment script, manifest schema, scenario adapter
and UI consumer synchronized when their interface changes.

When a public call or deployment scales with entries, participants, lots, claims or storage writes,
complete the early feasibility gate in `docs/gas.md` after its first correct slice. Downstream
product work waits until the maximum supported bound fits the declared budget or the operation is
bounded and resumable.

## Review and repair

When subagents are available:

1. Give a fresh reviewer the exact specification, candidate diff and test commands. Source is
   read-only; every finding needs an anchor, violated requirement, impact and reproducer or missing
   proof.
2. Accept or reject each finding with a reason. Give accepted findings to a fresh writer with a
   bounded file surface.
3. Require the focused proof to go red for the reported cause, then green after repair.
4. Review the repaired source again. Repeat only when evidence changes the hypothesis.
5. Give a fresh verifier read-only source and the exact commands. The verifier reports evidence; it
   does not repair.

Use one writer in a shared worktree. Parallel writers require isolated worktrees and frozen
interfaces. A child result is evidence, not parent completion.

## Gates

Run `./scripts/check.sh` only after focused tests pass, and require both exit zero and its final
`CHECK_OK` sentinel. A complete product with router, wallet or UI behavior also runs
`./scripts/devnet-check.sh` and requires `DEVNET_OK`. Source changes after review require fresh
review and verification.

Classify the outcome:

- **Complete:** requested behavior, required local checks and devnet evidence are green.
- **Escalated:** a user decision or new authority is the next action.
- **Blocked:** a technical or external limitation leaves no autonomous action.
