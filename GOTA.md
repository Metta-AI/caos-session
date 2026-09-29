# Gods of the Arena (gota) from this client repo

The tool lives in [Metta-AI/caos-softmax](https://github.com/Metta-AI/caos-softmax) (`tools/gota`); this repo only holds the token declaration.

## One-time setup (needs the human)

1. On your machine: `uv run softmax login`, then `uv run softmax get-token`.
2. In the cloud environment variables set `SOFTMAX_TOKEN=<that token>` and `CAOS_SOFTMAX_TOKEN_ENTROPY=<any random 16+ char string>`.
3. Start a NEW session from this branch (secrets are read at session start).
4. `import_source(source="https://github.com/Metta-AI/caos-softmax.git", into="imports/caos-softmax")`, then `run_tool imports/caos-softmax/tools/gota action=status`.

Tokens last about 24h. The secret's `reader=` path is untested until a session imports the tool from a source tree; if `status` says no secret, check that path first.

See the caos-softmax README for the tool's actions. Softmax's guidance is to submit to a league only after hosted xp-requests show a clear A/B improvement and the human approves; the tool has no submit action on purpose.
