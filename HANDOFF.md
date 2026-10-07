# Handoff: reviewing caos conversations and fixing what they show

Delete this file before merging PR 5. It is a note for the next agent, not
documentation.

## The original ask

"Use caos-std/caos-conversation-list to find recent conversations. For each one,
read it with caos-conversation. Find things that were very slow or where the
agent stumbled. Improve docs if you can spot fixes. Give me a summary."

It grew into: make `caos-conversation` usable on long conversations, fix the
bugs that turned up, and make the inline tools' argument errors clearer.

## State

| What | Where | State |
|---|---|---|
| Docs pitfalls in `AGENTS.md` | https://github.com/Metta-AI/caos-session/pull/5, branch `claude/festive-keller-1pf0ug` (head `8abcb839` plus this file) | Open, pushed |
| `caos-conversation` paging, `call-id` fix, `caos-test` help fix, new test | https://github.com/Metta-AI/caos/pull/325, branch `claude/conversation-paging` (head `a8406d5a`) | Open, pushed. New test and `caos-tools`, `lint`, `unit-fmt` pass. Full suite not run |

Nothing is unpushed.

## What is left (the user asked for both, in this order)

1. **Convert underscored argument names to hyphens** in the registered tools of
   `std/llm-step`. The known one is `source_tree` (on `publish_source`, `log`,
   `show`, `diff`, and as a prefix argument elsewhere); the hyphenated ones are
   `file-path`, `old-string`, `new-string`, `replace-all`. Leave the harness
   fields alone: `caos_session`, `caos_prompt_id` and `caos_tool_use_id` are
   injected by the hook. This is a breaking change. Find every user with
   `grep` for `source_tree` over `std/llm-step/src`, `rust/crates/caos-cli/src/mcp`,
   `tests/` (for example `tests/chat-tools/worker.sh` passes `"source_tree":"main"`),
   `SPEC.md` and `design/`. Decide, and tell the user, whether to accept the old
   name for a while. I did not decide.
2. **Make an unknown argument to the inline tools produce
   `takes no "x" argument (declared: …)`**, the message `run_tool` already gives
   (`std/llm-step/src/tools.rs`, near line 850). Today `edit` with `old_string`
   says "edit needs a non-empty `old-string`" and the call is recorded as
   complete. In `session 03d3d69c` an agent sent `{"file-path": …, "old_string": …}`
   three times in a row.
3. Add tests for both, next to `tests/chat-tools` (it drives the inline tools
   with a scripted stub model; `tests/chat-tools/worker.sh` is the pattern).
4. Run them, then publish. Ask the user whether this goes on
   `claude/conversation-paging` (PR 325) or a separate branch and PR.

## How to work

- **Start the session in `/home/user/caos-session`.** Run `caos_status` first. In
  the session this note comes from, the restarted process came up with its working
  directory at `/home/user`, which is not a git repository, and every caos tool
  vanished. The checkout existed at `/home/user/caos-session/.git`. If you see
  "caos has no workspace", you cannot do the work above; do not guess.
- Read `AGENTS.md` in this repo. Then import the code:
  `import_source(source="https://github.com/metta-ai/caos.git",
  revision="claude/conversation-paging", into="imports/caos/paging")`, `copy` it to
  `feature/01-...`, edit there.
- Test with `run_tool(path="<your feature tree>/std/caos-test",
  arguments={"only": "<bare test names>"})`. **Use bare names**
  (`only="chat-tools caos-conversation"`), not `tests/chat-tools`: the prefixed
  form fails with "--only matched no tests".
- Use the changed tool before you trust a test of it. The user asked for this
  explicitly, and it found the `call` bug.
- `caos-std/github` has no token granted, so open or edit PRs with the `mcp__github__*`
  tools. `metta-ai/caos` is outside the session's default scope; call `add_repo`
  for it. You do not need a local clone just to open a PR.
- Publish with `publish_source(repository, branch, source_tree)`. `source_tree`
  is required even with one tree.

## Things I learned that are not obvious

- `call` is a reserved argument name (`RESERVED_ARGS` in
  `std/llm-step/src/tools.rs`). A tool that declares `@param call` has it silently
  dropped. Tool parameter names use hyphens (`msg-width`); `msg_width` was rejected.
- A client test runs a tool image with `"$CAOS_CLI" run out --base:@=DEEP-DEPS/<tool> --arg=value`
  and `cat out`. `tests/caos-conversation/` is a working example, with DEPS
  listing `../../std/caos-conversation`.
- Hook-recorded conversations (`caos mcp hook`, as in `tests/mcp-resume`) contain
  no tool calls, so a test built on them cannot exercise `only=failed` or
  `call-id` against real calls.
- `caos-conversation` now takes `from`/`to`, `only` (`user`, `assistant`, `failed`),
  `msg-width` and `call-id`. Use `only=failed` first on a long conversation, then
  page with `from`/`to`. Before PR 325 merges and the pin moves, the pinned build
  has only `hash` and `width`.
- Output over the harness limit is saved to a local file that no tool here can
  open, and subagents have no file tools either. Do not delegate reading.

## Open questions and unfinished review

- Three conversations were only skimmed with the new tool, not reviewed:
  `03d3d69c` (read-trace work), `5943469a` (claude/direct-tools tests) and
  `9d47c1af` (actors design / drive). Use `caos-conversation-list` to find them
  and `only=failed` to read them.
- The restarted-process bug (working directory `/home/user`) is analysed in
  conversation `cc/7e659a97-38d6-5fda-bc63-4a94bf5b234f` (tip `2ac1c7dd…`, the
  design is in its last turn). Diagnostics from that design are already in the
  pinned build. The cause of the wrong directory is still unknown. It happened
  again in the session this note comes from (`cc/a08a641c-eee0-536a-8bf7-182b900541dd`).
  Nothing has been filed upstream for it.
- The relay requirement for `caos-stack start` was never tried; the user would
  have to supply a relay URL.
