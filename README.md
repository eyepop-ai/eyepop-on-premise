# EyePop On-Premise

Run the EyePop on-premise agent stack on a GPU-enabled Linux host.

## Install

1. Create `.env`:

```sh
cp .env.example .env
```

Fill in the values provided by EyePop:

```sh
EYEPOP_URL=https://compute.eyepop.ai
EYEPOP_API_KEY=<your api key>
EYEPOP_ACCOUNT_UUID=<your account uuid>
```

2. Place your Google service account credentials file at `.eyepop/creds.json`.

Optional: set `TS_AUTHKEY` in `.env` only when this host should join Tailscale for camera access.

3. Create your camera config:

```sh
cp agents.d/camera_1.example.yaml agents.d/camera_1.yaml
```

Edit `agents.d/camera_1.yaml` so the RTSP URL points at your camera.

4. Run the installer:

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
