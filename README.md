# EyePop On-Premise

## Install

1. Put the Google service account JSON from EyePop here:

```text
./creds.json
```

2. Create `.env`:

```sh
cp .env.example .env
```

3. Fill in these values in `.env`:

```sh
EYEPOP_URL=https://compute.eyepop.ai
EYEPOP_API_KEY=<provided by EyePop>
EYEPOP_ACCOUNT_UUID=<provided by EyePop>
GOOGLE_CREDS_JSON=./creds.json
```

4. Create your camera config:

```sh
cp agents.d/camera_1.example.yaml agents.d/camera_1.yaml
```

Edit `agents.d/camera_1.yaml` so the RTSP URL points at your camera.

5. Run the installer:

```sh
sudo ./install.sh
```

6. Open the dashboard:

```text
http://127.0.0.1:8080/dashboard/
```

## Useful Commands

```sh
docker compose logs -f
docker compose down
docker compose down -v
```
