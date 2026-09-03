# Agent mode (not published)

Agent mode is not part of the published documentation yet. These pages are
kept here so the work is not lost, and are excluded from `docs/gitbook`,
which is mirrored to [docs.eyepop.ai/on-premise](https://docs.eyepop.ai/on-premise).

- [Modes](modes.md) — Standalone and Agent compared
- [Agent configuration](configuration.md) — stream definitions and event outputs

The package still supports Agent mode: `install.sh --mode agent`,
`deployments/modes/agent.yaml`, `instance/agent.yaml`, and `agents.d`
are unchanged, and `scripts/validate.sh` still renders both modes. Only the
customer-facing pages are held back.

Move these pages into `docs/gitbook` when Agent mode is ready to announce.
Their links point into `../reference/`, which has to be rewritten on the way
back in. The published pages will also need Agent restored where it was
removed: the mode selection in installation, the Agent health checks, the
`--mode agent` examples on each hardware page, the Agent rows in the runtime
configuration tables, the stream-configuration entries in troubleshooting,
and Agent history in the storage table.
