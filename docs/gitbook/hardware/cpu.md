---
description: Run inference on amd64 or arm64 hosts with no accelerator
icon: microchip
---

# CPU

Use the CPU target on an amd64 or arm64 Linux host when no accelerator is required.

- Runtime image: `registry.eyepop.ai/ai/runtime-cpu:latest`
- Hardware identifier: `cpu`
- Additional host devices: none

```shell
sudo ./install.sh --mode standalone --hardware cpu
```

CPU is the simplest target for functional validation. Model throughput and supported real-time stream counts depend on the host CPU, model, media dimensions, and Pop definition; validate representative workloads before sizing a deployment.
