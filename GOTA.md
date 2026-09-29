# Gods of the Arena (gota) with caos

`tools/gota` runs Softmax's `coworld` / `softmax` CLIs in a caos worker (python 3.12 + uv, network). Use `tool_help tools/gota` for parameters.

## One-time setup (needs the human)

A worker has no browser, so it authenticates with a token:

1. On your machine: `uv run softmax login`, then `uv run softmax get-token`.
2. In the cloud environment variables set `SOFTMAX_TOKEN=<that token>` and `CAOS_SOFTMAX_TOKEN_ENTROPY=<any random 16+ char string>`.
3. Start a NEW session from this branch (secrets are read at session start). Check with `run_tool tools/gota action=status`.

Tokens last up to ~24h; repeat step 1-2 when `status` says unauthenticated.

## Play

```
run_tool tools/gota action=upload files=gota/policy file=v1.bas name=<policy-name>
# write an xp-request JSON (see `coworld xp-request create --help` via action=cli), then:
run_tool tools/gota action=play files=gota/policy request=xp-request.json
run_tool tools/gota action=results id=xreq_... nonce=<anything new>
```

Softmax's working agreement: submit to a league only after hosted XP requests show a clear A/B improvement and the human approves. This tool has no submit action on purpose.

## Policy

`gota/policy/v1.bas` is adapted from the game's reference player: towers/barracks outrank creeps as targets and lane farming ends at level 4, because only wins score and a timeout scores zero.
