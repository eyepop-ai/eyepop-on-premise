---
description: Run the EyePop runtime on your own hardware
icon: server
---

# On-Premise

An on-premise **instance** is the EyePop runtime installed on one machine, serving one Pop. Media and inference results stay on that machine. The runtime reaches out to EyePop only to register, pull models, and report usage.

### What you need

* A Linux host with Docker and Compose v2
* An API key from [the dashboard](https://dashboard.eyepop.ai), and a signed-in CLI (`eyepop auth login`)
* Outbound HTTPS to `registry.eyepop.ai` and `compute.eyepop.ai`

### Supported hardware

| Hardware | Profile |
| --- | --- |
| Any machine, no accelerator | `cpu` |
| NVIDIA Jetson on JetPack 6 | `cuda-jetpack6` |
| Qualcomm Dragonwing QCS9075, QAIRT SDK on the host | `qnn` |

`eyepop instance init` detects the profile. QCS9075 is the only Qualcomm part it resolves a QNN runtime for; on any other Qualcomm host `init` detects the accelerator and then fails, unless you supply a complete `qnn:` block in `--config`. Discrete NVIDIA GPUs and Intel OpenVINO run through the Docker Compose package in [eyepop-ai/eyepop-on-premise](https://github.com/eyepop-ai/eyepop-on-premise) instead — `init` does not provision them yet.

### Create an instance

```bash
eyepop instance init --pop eyepop.person:latest
```

One command does the whole thing: checks prerequisites, registers the instance with your account, installs a registry credential, detects the hardware profile, pulls the runtime image — several gigabytes — and starts the container. It returns once the container reports healthy, waiting up to `--wait` seconds, 300 by default. When it finishes, the machine is on-premise and ready.

Everything the instance needs lives under `~/.eyepop`. The runtime serves `http://127.0.0.1:8080`.

### Confirm it's up

```bash
eyepop get instances
```

This lists the on-premise instances registered to your account, so a new one showing up is the registration landing. Add `--json` for scripting.

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

The runtime requires no credential here: for a CLI-provisioned instance it is published on `127.0.0.1` by default, and that binding is the boundary — only `eyepop instance init --bind`, or the equivalent `bind:` key in its `--config` file, widens it. Do not expose the port to other machines without an authenticated layer in front of it.
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

[Local mode in the Python SDK](https://docs.eyepop.ai/sdks/python/configuration#local-mode)
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

[Local mode in the Node SDK](https://docs.eyepop.ai/sdks/node/configuration#local-mode)
{% endtab %}
{% endtabs %}

**Local mode** is what points an SDK at `http://127.0.0.1:8080` instead of the cloud, and it needs no account credentials. `EYEPOP_LOCAL_MODE=true` in the environment selects it without the constructor argument. Node still sends an `EYEPOP_API_KEY` if one is set in the environment — unset it to connect anonymously. Node local mode always uses port `8080`; Python takes an `eyepop_url` for anything else.

The SDK creates a pipeline on the instance — at connect in Node, on the first request in Python — and disconnecting removes it, so keep the `with` block or the `finally` — and reuse one connected endpoint for many images rather than connecting per request.

The first request for an ability is slower while the model downloads. After that it is served from the instance's cache.

### Next steps

* [Python SDK](https://docs.eyepop.ai/sdks/python) — configuration, video, image groups, and composed Pops
* [Node SDK](https://docs.eyepop.ai/sdks/node) — the same, for JavaScript and TypeScript
* [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise) — operating, repairing, and removing an instance
