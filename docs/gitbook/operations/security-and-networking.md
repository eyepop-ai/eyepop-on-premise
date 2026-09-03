---
description: Local API exposure, credentials, and outbound connections
icon: shield-halved
---

# Security and networking

### Local API exposure

The shared Compose file publishes port 8080 on `127.0.0.1`, so another machine cannot connect directly. The supplied package does not provide a configurable bind address.

Do not publish the runtime API, dashboard, or an unauthenticated relay directly to the public internet. The dashboard, Swagger, and `/metrics` are enabled without their own login in the supplied instance configuration, so anything that reaches the port can read them.

[Remote access](remote-access.md) covers the supported ways to reach the instance from another machine, and to reach cameras that are not on the instance's network.

### Secrets

`.env` contains the EyePop API key and account identity. Agent stream definitions can contain camera credentials. Restrict both to the deployment administrators and do not commit them, paste them into support tickets, or bake them into images.

The installer asks for registry credentials interactively and sends the password to `docker login` through standard input. For automation, inject `EYEPOP_REGISTRY_USERNAME` and `EYEPOP_REGISTRY_PASSWORD` as short-lived process secrets.

### Outbound connectivity

The host needs outbound HTTPS for:

- `registry.eyepop.ai` to pull runtime images;
- `compute.eyepop.ai` to register the instance, coordinate model access, and deliver usage.

Agent camera sources and configured event destinations must be reachable from the container network. The optional Tailscale step runs only when `TS_AUTHKEY` is present in `.env`; see [Remote access](remote-access.md).

### Hardware access

CPU needs no host devices. NVIDIA, Intel, and Qualcomm targets add only the integration declared in their hardware overlays. Qualcomm QNN is the exception: the validated QAIRT stack requires privileged mode and broad device access, so it must run on a dedicated trusted host.
