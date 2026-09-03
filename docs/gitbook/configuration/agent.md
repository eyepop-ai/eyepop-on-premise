---
description: Stream definitions and event delivery for Agent mode
icon: diagram-project
---

# Agent configuration

Agent mode is Beta. It loads stream definitions from `agents.d/streams` and optional delivery outputs from `agents.d/events-config.yaml`. The `agents.d` directory is bind-mounted read-only at `/opt/eyepop/agent.d`.

```
agents.d/
├── events-config.yaml          delivery outputs
├── event_sinks/                additional output files, merged in name order
└── streams/
    ├── camera_1.example.yaml   shipped example, never loaded
    └── loading-dock.yaml       one file per stream
```

The runtime reads this configuration when it starts. Edit the files, then recreate the container to apply a change. Configuration files are parsed strictly: an unknown key is an error, not a warning, and the runtime reports the file and line.

### Streams

Each stream is one YAML file under `agents.d/streams`. Files ending in `.example.yaml` are ignored, and files directly under `agents.d` are rejected — stream files must live in `streams/`.

```shell
cp agents.d/streams/camera_1.example.yaml agents.d/streams/loading-dock.yaml
```

{% hint style="info" %}
**The file name is the stream id.** `id` defaults to the file's base name, and when you set `id` explicitly the file must be named `<id>.yaml`. Two files that resolve to the same id are an error.
{% endhint %}

| Key | Required | Default | Purpose |
| --- | --- | --- | --- |
| `version` | Yes | `1` | Schema version; only `1` is supported |
| `id` | No | file base name | Stream identity, used in events and API responses |
| `name` | No | — | Human-readable label |
| `enabled` | No | `true` | Set `false` to keep the file without running the stream |
| `source` | Yes | — | Where media comes from |
| `jobs` | Yes | — | At least one job to run on the stream |

#### Source

| Key | Required | Purpose |
| --- | --- | --- |
| `source_type` | Yes | `URL` for network streams, `V4L2` for a local camera device |
| `url` | For `URL` | RTSP, RTMP, or HTTP media URL |
| `device` | For `V4L2` | Host device path, for example `/dev/video0` |

`type: rtsp` and `uri:` are accepted as older spellings of `source_type: URL` and `url:`.

These source options apply to the whole stream, and each can be overridden per job:

| Key | Purpose |
| --- | --- |
| `media_cache_seconds` | Seconds of media retained for clips, thumbnails, and latest-frame requests |
| `fps` | Frame rate to pull from the source |
| `roi` | Region of interest as `x`, `y`, `width`, `height` |
| `motion_detect` | Only run inference when motion is detected |
| `motion_sensitivity` | Motion detector sensitivity |
| `motion_threshold` | Motion detector threshold |
| `motion_gap` | Frames of quiet before motion is considered ended |
| `motion_grid_x`, `motion_grid_y` | Motion detection grid size |

Media caching is what makes `/agent/media/thumbnail`, `/agent/media/clip`, and `/agent/media/latest-frame` available; without `media_cache_seconds` those routes are not served.

#### Jobs

| Key | Required | Default | Purpose |
| --- | --- | --- | --- |
| `id` | Yes for more than one job | `default` | Job identity within the stream |
| `enabled` | No | `true` | Set `false` to keep the job without running it |
| `kind` | No | `vehicle_tracking` | Job kind; `vehicle_tracking` is the only kind currently supported |
| `pop` | One of the two | — | Inline Pop definition |
| `pop_file` | One of the two | — | Path to a Pop JSON or YAML file, relative to the stream file |
| `events` | No | — | Which events this job emits |
| `source` | No | — | Per-job overrides of the stream source options above |
| `runtime_options` | No | — | `set_source_throttle_per_sec` limits how often the source is reset |

Setting both `pop` and `pop_file` is an error.

`events` controls which events the job emits:

| Key | Default | Effect |
| --- | --- | --- |
| `predictions` | off | Emit `prediction.made` for every prediction. High volume — enable deliberately |
| `motions`, `tracks`, `insights` | — | Accepted by the schema and reserved. Track and insight events are emitted by the runtime today regardless of these keys |

```yaml
version: 1
name: Loading dock
source:
  type: rtsp
  uri: rtsp://user:password@camera-host:554/stream
  media_cache_seconds: 30
jobs:
  - id: vehicle_tracking
    events:
      insights: true
    pop:
      components:
        - type: inference
          ability: eyepop.vehicle:latest
          categoryName: vehicles
          confidenceThreshold: 0.7
```

Keep camera credentials out of Git. `.gitignore` excludes every stream file except the examples, and `scripts/validate.sh` fails if a non-example stream file is ever tracked. Restrict filesystem access to stream files that contain authenticated URLs.

### Event outputs

`agents.d/events-config.yaml` defines where events are delivered. Additional files under `agents.d/event_sinks/` are merged into it in name order, which keeps one output per file when that suits a deployment.

| Key | Required | Default | Purpose |
| --- | --- | --- | --- |
| `name` | Yes | — | Output name, used in logs |
| `type` | Yes | — | `webhook`, `mqtt`, `nats`, or `stdout` |
| `enabled` | No | `true` | Set `false` to keep a configured output switched off |
| `events` | No | all | Event names to deliver; `"*"` matches everything |
| `format` | No | `envelope_only` | `envelope_only`, `full`, or `content_only` |
| `queue` | No | — | Depth of the output's send queue |

Event names are `stream.status_changed`, `track.started`, `track.ended`, `insight.completed`, `prediction.made`, and `journey.matched`. A job only emits what its `events` block enables.

Each type reads its own block:

| Type | Keys |
| --- | --- |
| `webhook` | `url` (required), `timeout`, `headers` |
| `mqtt` | `broker_url` (required), `client_id`, `username`, `password`, `topic_prefix`, `qos`, `retained`, `connect_timeout`, `publish_timeout` |
| `nats` | `url` (required), `subject_prefix`, `connect_timeout` |
| `stdout` | none — events go to the container log |

Durations are Go duration strings such as `3s` or `500ms`. Enable only the outputs the deployment uses, and provide authentication through deployment secrets rather than committed values.

`stdout` is the quickest way to confirm that a stream is producing the events you expect:

```yaml
version: 1
outputs:
  - name: local-debug
    type: stdout
    events:
      - "*"
```

Event delivery is separate from EyePop account usage delivery. Disabling webhook, MQTT, or NATS output does not disable billing events.

### Agent endpoints

| Endpoint | Available when |
| --- | --- |
| `/agent/health` | Always in Agent mode |
| `/agent/streams` | Streams are configured |
| `/agent/tracks` | Streams are configured |
| `/agent/detections` | Streams are configured |
| `/agent/media/thumbnail` | The stream sets `media_cache_seconds` |
| `/agent/media/clip` | The stream sets `media_cache_seconds` |
| `/agent/media/latest-frame` | The stream sets `media_cache_seconds` |

```shell
curl --fail http://127.0.0.1:8080/agent/health
curl --fail http://127.0.0.1:8080/agent/streams
docker compose logs -f eyepop-instance
```

Replace `8080` when `EYEPOP_HTTP_PORT` selects another host port.

The runtime also serves `/agent/config`, which reads and replaces the configuration package over HTTP. This package mounts `agents.d` read-only, so change configuration by editing the files and recreating the container.

### Health and state

Agent history is stored at `/opt/eyepop/private/agent-history.db` in the `eyepop_instance_private` volume. Recreating the container preserves it; deleting the private volume removes it.

### Next steps

- [First inference](../getting-started/first-inference.md) — check the instance is serving before adding streams
- [Remote access](../operations/remote-access.md) — reach cameras that are not on the instance's network
- [Troubleshooting](../operations/troubleshooting.md) — configuration errors and streams that do not start
