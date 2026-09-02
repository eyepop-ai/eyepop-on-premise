# Agent configuration

Agent mode is Beta. It loads stream definitions from `agents.d/streams` and optional delivery outputs from `agents.d/events-config.yaml`.

## Streams

Create a YAML file for each managed stream:

```shell
cp agents.d/streams/camera_1.example.yaml agents.d/streams/loading-dock.yaml
```

Edit the copied file with the source URL and Pop configuration. The installer ignores `*.example.yaml` and requires at least one active YAML file before it starts Agent mode.

Keep camera credentials out of Git. Restrict filesystem access to stream files that contain authenticated URLs.

## Event outputs

`agents.d/events-config.yaml` contains webhook, MQTT, and NATS output definitions. Enable only the outputs the deployment uses and provide authentication through deployment secrets rather than committed values.

Event delivery is separate from EyePop account usage delivery. Disabling webhook, MQTT, or NATS output does not disable billing events.

## Health and state

```shell
curl --fail http://127.0.0.1:8080/agent/health
curl --fail http://127.0.0.1:8080/agent/streams
docker compose logs -f eyepop-instance
```

Replace `8080` in both URLs when `EYEPOP_HTTP_PORT` selects another host port.

Agent history is stored at `/opt/eyepop/private/agent-history.db` in the `eyepop_instance_private` volume. Recreating the container preserves it; deleting the private volume removes it.
