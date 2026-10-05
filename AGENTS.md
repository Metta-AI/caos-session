# Working in this session

This repository is not the code you are here to change. It is the **client
repo**: a handful of text files that say which caos this session uses and
which tools it offers. The code you work on is **imported into the
conversation**, not checked out onto disk.

That is the one thing to internalise before your first tool call. Your file
tools do not read this container's filesystem — they read the conversation
tree, which starts out holding almost nothing.

List it with `ls path="/"`. A bare `ls` with no path errors
(`` `path` names no path ``). A fresh conversation holds `.caos/` and this
client repo's own handful of files (`AGENTS.md`, `flake.nix`, `.caos-expr`
and so on) — no code to work on. That is what it is supposed to look like,
not a sign that anything went wrong.

## Start by importing what you were asked to work on

When the user names a repository, import it:

```
import_source(source="https://github.com/<owner>/<repo>.git",
              revision="main",
              into="imports/<repo>/base")
```

The server fetches it directly from GitHub — nothing is cloned into this
container and nothing is uploaded from it, so a large repository costs about
the same as a small one. Omit `revision` for the default branch. Public
repositories need no credentials.

Then copy the snapshot to the boundary you will edit, and leave the import
untouched as the record of where you started:

```
mkdir -p feature && cp -a imports/<repo>/base feature/01-change
```

The `mkdir -p` is not optional — `cp` will not create the parent, and without
it the call fails with `cp: cannot create directory 'feature/01-change': No
such file or directory`. Use `cp -a`, never a plain `cp`: `-a` is what carries
the source tree's commit identity across, and a plain copy loses it.

Edit `feature/01-change`. Keep `imports/<repo>/base` exactly as imported —
it is what any later diff, merge or publication is measured against.

**If the user gives a bare name** rather than a URL, resolve it before
importing rather than guessing: a wrong fork imports cleanly and wastes the
whole session. Ask if you cannot tell.

## The imported repo has its own instructions

Anything you import may carry its own `AGENTS.md` or `CLAUDE.md`, and those
instructions govern the code they ship with. Read the imported tree's root
instructions before you start editing it. They are not loaded for you —
this file is the only one the harness injected, and it only covers the
session, not the code.

## Tools

The caos tools are the ones prefixed `caos`; the harness's own file and shell
tools are switched off, so there is no second set to choose between. The ones
worth knowing up front:

- `read` / `ls` / `grep` — read the conversation tree.
- `write` / `edit` / `bash` — mutate it. Every accepted change records a child
  commit automatically; there is no staging step and nothing to commit by hand.
- `import_source` — above.
- `caos-build` / `caos-test` — run the imported repo's own build and tests,
  when it defines them under `caos-tools/`.
- `merge` — merge a commit into a source tree.
- `publish_source` — push a source tree's commit to a branch on GitHub.
- `run_tool(path="caos-std/github")` — one GitHub API call (`method`, `path`,
  optional JSON `body`): open a PR, change its base, read its state. A run
  fails only when no response came back, and a write may still have arrived,
  so read the state with a GET before resending.

`bash` needs conversation-relative paths declared for the content it touches,
and `mv`/`cp -a` preserve a source tree's commit identity where a plain copy
would not.

## What is configured here

| file | what it decides |
|---|---|
| `flake.nix` + `flake.lock` | which caos — the client binary, the tools, the tree |
| `.caos-expr` | mounts caos' `std/` at `caos-std/` in the evaluated tree |

Secrets, such as a GitHub token, are not configured here. They live in the
user's secret store on the caos server, and the session presents the key named
by the environment's `--secret-readers`. With caos pinned at `1eb6241c` or
later, the first prompt's `secret readers:` line (and `caos_status`) shows
which key that is, or that there is none.

To move to a newer caos: `nix flake update caos`, then set the two `rev=`
values in `.caos-expr` to the new commit. They must agree with `flake.lock` —
`std/flake-input-loader` refuses the evaluation otherwise and names both
revisions, so this cannot go wrong quietly. Pin only a commit that already has
a published build: the client comes from that commit's release and the tools
resolve through the same rev, so a commit without one is refused rather than
paired with an older client. The environment then needs its setup script changed
before a session installs the new pin; until it is, every call is blocked with
`STALE INSTALL`.

Fork this repository to add your own tools, instructions or pins. Nothing here
is specific to one project.
