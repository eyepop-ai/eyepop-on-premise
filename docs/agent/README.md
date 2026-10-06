# Agent mode (not published)

Agent mode is not part of the published documentation yet. These pages are
kept here so the work is not lost, and are excluded from `docs/gitbook`,
which is mirrored to [docs.eyepop.ai/deploying/on-premise](https://docs.eyepop.ai/deploying/on-premise).

- [Modes](modes.md) — Standalone and Agent compared
- [Agent configuration](configuration.md) — stream definitions and event outputs

The package still ships Agent mode: `install.sh --mode agent`,
`deployments/modes/agent.yaml`, `instance/agent.yaml`, and `agents.d`
are in place, and `scripts/validate.sh` still renders both modes. As packaged,
though, Agent mode does not start on current runtime images.
`instance/agent.yaml` sets a `sqlite://` `agent.store.uri`, and the runtime
refuses it: Agent history now needs an external Postgres database
(`postgres://`), because the SQLite store was removed (AWSU-270). A stream
copied from `camera_1.example.yaml` sets `media_cache_seconds`, which the
runtime refuses unless a media cache service is configured with
`media-cache.url` (AWSU-261). Both have to be fixed in the package before
these pages are published.

Move these pages into `docs/gitbook` when Agent mode is ready to announce.
Their links point into `../reference/`, which has to be rewritten on the way
back in. The published pages will also need Agent restored where it was
removed: the mode selection in installation, the Agent health checks, the
`--mode agent` examples on each hardware page, the Agent rows in the runtime
configuration tables, the stream-configuration entries in troubleshooting,
and Agent history in the storage table.
