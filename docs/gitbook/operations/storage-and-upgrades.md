---
description: Persistent volumes and how to move to a new image
icon: boxes-stacked
---

# Storage and upgrades

### Persistent data

The package creates two named volumes:

| Volume | Container path | Contents |
| --- | --- | --- |
| `eyepop_instance_private` | `/opt/eyepop/private` | registration state, usage spool, and Agent history |
| `eyepop_instance_models` | `/opt/eyepop/models` | downloaded model cache |

Container recreation and `docker compose down` preserve both volumes. `docker compose down -v` deletes them and should be used only when the instance state, queued usage, Agent history, and model cache can be discarded.

Back up the private volume according to the host's container-storage policy. Protect backups as secrets because private runtime state is account-specific.

The installer prints the pulled runtime image digest. Record that value with the deployment configuration on first installation so a later rollback can restore the exact image even after the `latest` tag moves.

### Update

Use the same mode and hardware overlays that started the deployment. This example updates Standalone on CPU:

```shell
CONTAINER_ID="$(docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  ps -q eyepop-instance)"
[ -n "$CONTAINER_ID" ] || { echo 'eyepop-instance is not running' >&2; exit 1; }
RUNNING_IMAGE_ID="$(docker inspect "$CONTAINER_ID" --format '{{.Image}}')"
ROLLBACK_IMAGE="$(docker image inspect "$RUNNING_IMAGE_ID" \
  --format '{{index .RepoDigests 0}}')"
[ -n "$ROLLBACK_IMAGE" ] && [ "$ROLLBACK_IMAGE" != '<no value>' ] \
  || { echo 'running image has no repository digest' >&2; exit 1; }
printf 'Rollback image: %s\n' "$ROLLBACK_IMAGE"

docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  pull

docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  up -d
```

The hardware overlays track the `latest` tag. The first commands resolve the exact image ID used by the running service to its repository digest before `pull` moves the local tag. Set `EYEPOP_RUNTIME_IMAGE` in `.env` to the digest printed as `Rollback image` for a controlled rollback, recreate the service with the same project and overlays, and remove the override after the issue is resolved.

### Remove the deployment

Stop and delete the containers, keeping the volumes:

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  down
```

Add `-v` to that command to delete the named volumes as well. That discards registration state, any usage still queued for delivery, Agent history, and the model cache. Confirm the usage spool has drained before doing it — see [Billing and connectivity](billing-and-connectivity.md).

Then remove what lives outside Compose:

```shell
sudo docker logout registry.eyepop.ai
sudo rm -f .env
```

Deleting the instance from the EyePop account is a separate step, in [My Servers](https://dashboard.eyepop.ai/servers).

### Change mode or hardware

Stop the current three-file Compose selection with an explicit project name:

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  down
```

Start the new selection with the same project name and shared Compose file:

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/agent.yaml \
  -f deployments/hardware/nvidia-cuda.yaml \
  up -d
```

Replace both overlay paths with the current and target selections. Keeping the project name and `compose.yaml` in both commands preserves the named volumes. Confirm the target host prerequisites before changing a hardware overlay.
