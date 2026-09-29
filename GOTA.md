# Gods of the Arena (gota) from this client repo

The tool lives in [Metta-AI/caos-softmax](https://github.com/Metta-AI/caos-softmax) (`tools/gota`); this repo holds the token declaration and the policy.

## One-time setup (needs the human)

1. On your machine: `uv run softmax login`, then `uv run softmax get-token`.
2. In the cloud environment variables set `SOFTMAX_TOKEN=<that token>` and `CAOS_SOFTMAX_TOKEN_ENTROPY=<any random 16+ char string>`.
3. Start a NEW session from this branch (secrets are read at session start).
4. `import_source(source="https://github.com/Metta-AI/caos-softmax.git", into="imports/caos-softmax/base")`, then `run_tool imports/caos-softmax/base/tools/gota action=status`.

Tokens last about 24h. The secret's `reader=` path is untested until a session imports the tool from a source tree; if `status` says no secret, check that path first.

## Play

```
run_tool imports/caos-softmax/base/tools/gota action=upload files=gota/policy file=v1.bas name=<policy-name>
# write an xp-request JSON (see `coworld xp-request create --help` via action=cli), then:
run_tool imports/caos-softmax/base/tools/gota action=play files=gota/policy request=xp-request.json
```

Softmax's guidance: submit to a league only after hosted xp-requests show a clear A/B improvement and the human approves. The tool has no submit action on purpose.

## Policy

`gota/policy/v1.bas` is my modification of the game's reference player (`examples/gods_of_the_arena/players/base.bas` in Metta-AI/polyworld, fetched through a summarizing web fetch, so the base may not be byte-exact; no license was seen). Changes: towers/barracks outrank creeps as targets, and lane farming ends at level 4 instead of 6, because only wins score and a timeout scores zero. It has never been compiled or run.
