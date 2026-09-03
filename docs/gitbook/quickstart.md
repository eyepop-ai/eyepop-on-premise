---
description: Create an instance, see what it is running, and send it work
icon: bolt
---

# Quickstart

### Create an instance

```bash
eyepop instance init --pop eyepop.person:latest
```

One command does the whole thing: checks prerequisites, registers the instance with your account, installs a registry credential, detects the hardware profile, pulls the runtime image — several gigabytes — and starts the container. When it finishes, the machine is on-premise and ready.

Everything the instance needs lives under `~/.eyepop`. The runtime serves `http://127.0.0.1:8080`.

Confirm it is up:

```bash
curl --fail http://127.0.0.1:8080/health
curl --fail http://127.0.0.1:8080/ready
```

`/health` means the process is up; `/ready` means it can accept work. A new instance is healthy before it is ready, while it registers and downloads its first model.

### See what you have

`eyepop system` reports what this machine is — Docker and its daemon, credentials, the accelerator it found and the runtime image that implies, whether an instance is configured, and exactly what gets sent to EyePop when one is registered. It only reports, and always exits 0.

```bash
eyepop system
```

`eyepop get instances` lists every on-premise instance on the account, not just this machine's:

```bash
eyepop get instances
```

Both take `--json` for scripting.

To see what the runtime itself is doing:

```bash
eyepop instance logs --tail 50
```

`--follow` streams. For the rest — `stop`, `start`, `restart`, repairing an instance, and removing one — see [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise).

### Change the Pop it serves

The Pop is not fixed for the life of the instance:

```bash
eyepop instance set pop eyepop.vehicle:latest
```

The CLI resolves the Pop against your account before it touches anything, then recreates the container. The instance keeps its identity and its model cache, and the runtime image is not pulled again.

### Run inference

{% tabs %}
{% tab title="CLI" %}
```bash
eyepop run image.jpg
```

With no target named, the run uses the Pop the instance already serves. Nothing is sent to the cloud and no session is created.
{% endtab %}

{% tab title="curl" %}
The instance serves its Pop on a pipeline. Find it, then send media to it:

```bash
PIPELINE_ID=$(curl -sS http://127.0.0.1:8080/pipelines | jq -r '.[0].id')

# A local file, as raw bytes
curl -sS -X POST \
  "http://127.0.0.1:8080/pipelines/$PIPELINE_ID/source?mode=queue&processing=sync" \
  -H 'Content-Type: image/jpeg' \
  -H 'Accept: application/jsonl' \
  --data-binary @image.jpg

# A URL the instance fetches itself
curl -sS -X PATCH \
  "http://127.0.0.1:8080/pipelines/$PIPELINE_ID/source?mode=queue&processing=sync" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/jsonl' \
  -d '{"sourceType": "URL", "url": "https://example.com/image.jpg"}'
```

Predictions come back as JSONL, one per line — one line for an image, one per frame for a video.

The runtime requires no credential here: it is published on `127.0.0.1` only, and that binding is the boundary. Do not expose the port to other machines without an authenticated layer in front of it.
{% endtab %}

{% tab title="Python" %}
```python
from eyepop import EyePopSdk
from eyepop.worker.worker_types import InferenceComponent, Pop

pop = Pop(components=[
    InferenceComponent(ability="eyepop.person:latest")
])

with EyePopSdk.sync_worker(is_local_mode=True, pop=pop) as endpoint:
    result = endpoint.upload("image.jpg").predict()
    print(result)
```
{% endtab %}

{% tab title="Node" %}
```typescript
import { EyePop, PopComponentType } from '@eyepop.ai/eyepop'

const endpoint = await EyePop.workerEndpoint({
    isLocalMode: true,
    pop: {
        components: [
            { type: PopComponentType.INFERENCE, ability: 'eyepop.person:latest' },
        ],
    },
}).connect()

try {
    const results = await endpoint.process({ source: { path: 'image.jpg' } })
    for await (const result of results) {
        console.log(result)
    }
} finally {
    await endpoint.disconnect()
}
```
{% endtab %}
{% endtabs %}

**Local mode** is what points an SDK at `http://127.0.0.1:8080` instead of the cloud, and it sends no account credentials. `EYEPOP_LOCAL_MODE=true` in the environment selects it without the constructor argument. Node local mode always uses port `8080`; Python takes an `eyepop_url` for anything else.

Connecting creates a pipeline on the instance and disconnecting removes it, so keep the `with` block or the `finally` — and reuse one connected endpoint for many images rather than connecting per request.

The first request for an ability is slower while the model downloads. After that it is served from the instance's cache.

### Next steps

* [Python SDK](https://docs.eyepop.ai/sdks/python) — configuration, video, image groups, and composed Pops
* [Node SDK](https://docs.eyepop.ai/sdks/node) — the same, for JavaScript and TypeScript
* [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise) — operating, repairing, and removing an instance
