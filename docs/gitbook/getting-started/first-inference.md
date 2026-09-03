---
description: Confirm the instance is serving and run inference against it
icon: play
---

# First inference

The runtime serves its API on the host loopback interface. Everything on this page runs on the machine the instance is installed on, or through an access layer you put in front of it.

### Confirm the instance is serving

```shell
curl --fail http://127.0.0.1:8080/health
curl --fail http://127.0.0.1:8080/ready
```

`/health` reports that the process is up. `/ready` additionally reports that the pipeline service can accept work — a new instance is healthy before it is ready, because it registers with the account and downloads its first models on the way there.

Replace `8080` everywhere on this page when `EYEPOP_HTTP_PORT` selects another host port.

### Local endpoints

| Endpoint | Purpose |
| --- | --- |
| `/health` | Liveness |
| `/ready` | Readiness, including the pipeline service |
| `/version` | Instance version and build |
| `/metrics` | Prometheus metrics |
| `/docs` | Swagger UI for the instance API |
| `/dashboard` | Browser dashboard for the instance |

These have no login in the supplied configuration, which is why the package binds the port to `127.0.0.1`. Anything that reaches the port can read them. See [Security and networking](../operations/security-and-networking.md) before putting an access layer in front.

### Run inference from an SDK

The EyePop SDKs reach an on-premise instance in **local mode**, which points them at `http://127.0.0.1:8080` instead of the cloud and skips cloud authentication. Pass the Pop you want the instance to run — the instance downloads the models it needs on first use.

{% tabs %}
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

Pass `eyepop_url` to reach an instance on another port or host:

```python
endpoint = EyePopSdk.sync_worker(
    is_local_mode=True,
    eyepop_url="http://127.0.0.1:9090",
    pop=pop,
)
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

Node local mode always uses `http://127.0.0.1:8080`. Leave `EYEPOP_HTTP_PORT` at its default when Node clients connect to the instance.
{% endtab %}
{% endtabs %}

`EYEPOP_LOCAL_MODE=true` in the client environment selects local mode without the constructor argument. Local mode sends no account credentials — the instance is already registered to the account, and the client is trusted because it can reach the loopback port.

Connecting creates a pipeline on the instance, and disconnecting removes it. Use the context manager or a `finally` block, as both examples above do, so a client that exits does not leave a pipeline behind. Reuse one connected endpoint for many requests rather than connecting per request.

The first request for a given ability is slower while the model downloads into the `eyepop_instance_models` volume. Later requests for the same ability use the cache.

### Run inference from the CLI

The EyePop CLI installs and manages instances of its own with `eyepop instance init`. It treats a machine as on-premise only when it finds the instance root it wrote itself, so it does not see a deployment installed by this package: `eyepop run` on this host still goes to the cloud. Drive a Compose-installed instance from the SDKs, the instance API, or the dashboard.

{% hint style="warning" %}
Do not run both on one host. The CLI uses the same Docker Compose project name as this package, `eyepop-on-premise`, so `eyepop instance init` would take over the containers and volumes this package created.
{% endhint %}

See [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise) for the CLI-managed alternative.

### Next steps

- [Runtime configuration](../configuration/runtime.md) — ports, image selection, and the settings the package writes
- [Remote access](../operations/remote-access.md) — reach the instance from another machine
- [Troubleshooting](../operations/troubleshooting.md) — when health, readiness, or the first inference does not come up
