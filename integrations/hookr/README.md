# Local Hookr manifest

`manifest.json` is specific to this repository and its pinned source commit. Keep exactly one local
manifest in this directory. `scaffold.sh` omits the directory because a copied project needs its own
repository identity and immutable source commit.

The local check is a dependency-free guard for this source-only draft. It is not Hookr's AJV runner.
Run the exact upstream validator before making a schema-valid or submission claim.
