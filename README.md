# EyePop On-Premise

Run the EyePop on-premise agent stack on a GPU-enabled Linux host.

_note: Supports linux hosts with nvidia accelerators only_

## Install

1. Create `.env`:

```sh
cp .env.example .env
```

Fill in your api key and account uuid (see onboarding document or get an api key from the dashboard: https://dashboard.eyepop.ai)

```sh
EYEPOP_API_KEY=<your api key>
EYEPOP_ACCOUNT_UUID=<your account uuid>
```

2. Place your Google service account credentials file at `.eyepop/creds.json` relative to this cloned repo.

3. Create your camera config:

```sh
cp agents.d/streams/camera_1.example.yaml agents.d/streams/camera_1.yaml
```

Edit `agents.d/streams/camera_1.yaml` so the RTSP URL points at your camera.

Optional event outputs live in `agents.d/events-config.yaml`. Enable webhook, MQTT, or NATS outputs there when downstream delivery is needed.

4. Run the installer on your linux VM

```sh
sudo ./install.sh
```

If the installer adds your user to the Docker group, log out and back in before running Docker commands without `sudo`.

5. Open the dashboard:

```text
http://127.0.0.1:8080/dashboard/
```

## Useful Commands

```sh
docker compose logs -f
docker compose down
docker compose down -v
```

## Tailscale support (optional)

_If not familiar with tailscale, it may be a quick and secure solution for connecting across network rtsp streams._

Setting `TS_AUTHKEY` in the `.env` will automatically install and setup tailscale on your host.
