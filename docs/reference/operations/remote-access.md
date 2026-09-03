---
description: Reach cameras on other networks, and the instance from other machines
icon: network-wired
---

# Remote access

Two access problems come up in an on-premise deployment, and they are separate:

- the **instance reaching cameras** that are not on its own network;
- **you reaching the instance** from another machine.

### Cameras on another network

An RTSP source has to be reachable from inside the container. On a flat LAN, nothing is needed — the container uses the host's network path to the camera. It gets harder when the cameras sit behind another router, on a site you are not standing in, or on a segment the instance host cannot route to.

The usual options:

- **Put the instance on the camera network.** Simplest when it is possible. No tunnel, no NAT, no third party.
- **Route to the camera network.** A site-to-site VPN or a static route on the instance host, if you already run that.
- **Port-forward each camera.** Works, but exposes cameras to the internet and needs a static address or dynamic DNS. Avoid it for cameras with weak or shared credentials.
- **Join both to an overlay network.** A tailnet or equivalent, which is what the installer helps with below.

### Tailscale

The installer can join the host to a [Tailscale](https://tailscale.com) tailnet, which gives the instance a route to cameras and other devices on any network you have connected — including subnet routes advertised by a router at the camera site.

Set an auth key in `.env` before installing:

```dotenv
TS_AUTHKEY=tskey-auth-xxxxx
TS_HOSTNAME=eyepop-agent
```

`TS_AUTHKEY` is what turns the step on: with it set, `install.sh` runs `scripts/install-tailscale.sh` before pulling images. The script installs Tailscale if the host does not have it, enables `tailscaled`, and brings the node up with:

- `--hostname` set to `TS_HOSTNAME`, or `eyepop-agent` when it is not set;
- `--accept-routes`, so subnet routes advertised elsewhere on the tailnet are usable — this is what reaches cameras behind a remote router;
- `--accept-dns=false`, leaving the host's own DNS configuration alone;
- `--ssh`, allowing tailnet SSH to the host under your Tailscale ACLs.

It then prints `tailscale status` and the node's tailnet IP.

Run it on its own to add Tailscale to a host that is already installed:

```shell
sudo TS_AUTHKEY=tskey-auth-xxxxx scripts/install-tailscale.sh
```

Use an ephemeral, pre-authorized key scoped to the tag you use for these hosts, and treat it as a secret: it is stored in `.env`, which the installer restricts to `0600`. Rotate it after installation. The runtime container reaches the network through the host, so a camera the host can reach over the tailnet is normally reachable from the runtime as well. Confirm the route from the host first, then from inside the container if a stream still does not connect.

Tailscale is optional. Nothing else in the package depends on it, and the installer skips the step when `TS_AUTHKEY` is absent.

### Reaching the instance from another machine

Compose publishes the API on `127.0.0.1` only, and the package has no configurable bind address. The routes it serves — Swagger, `/metrics`, and the inference API — have no login in the shipped configuration, so treat anything that reaches the port as trusted.

To use the instance from another machine, put an access layer in front of the loopback endpoint:

- **An authenticated reverse proxy** on the host, bound to a private interface, terminating TLS and requiring credentials of your own.
- **A tailnet address**, restricted by Tailscale ACLs to the hosts and users that should reach it.
- **An SSH tunnel** for occasional access: `ssh -N -L 8080:127.0.0.1:8080 user@instance-host`, then point a local client at `http://127.0.0.1:8080`.

Do not publish port 8080 to the public internet, with or without a proxy in front of it.

SDK clients in local mode connect to `http://127.0.0.1:8080`, so a tunnel that presents that same address and port needs no client change. See [First inference](../getting-started/first-inference.md).

### Next steps

- [Security and networking](security-and-networking.md) — secrets, outbound requirements, and hardware access
- [Troubleshooting](troubleshooting.md) — sources that do not connect
