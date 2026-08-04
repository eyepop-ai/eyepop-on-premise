# Storage and upgrades

## Persistent data

The package creates two named volumes:

| Volume | Container path | Contents |
| --- | --- | --- |
| `eyepop_instance_private` | `/opt/eyepop/private` | registration state, usage spool, and Agent history |
| `eyepop_instance_models` | `/opt/eyepop/models` | downloaded model cache |

Container recreation and `docker compose down` preserve both volumes. `docker compose down -v` deletes them and should be used only when the instance state, queued usage, Agent history, and model cache can be discarded.

Back up the private volume according to the host's container-storage policy. Protect backups as secrets because private runtime state is account-specific.

## Update

Use the same mode and hardware overlays that started the deployment. This example updates Standalone on CPU:

```shell
docker compose --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  pull

docker compose --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  up -d
```

The hardware overlays track the `latest` tag. Record the deployed image digest before an update so the deployment can roll back to an exact known image if necessary:

```shell
docker image inspect registry.eyepop.ai/ai/runtime-cpu:latest \
  --format '{{index .RepoDigests 0}}'
```

Set `EYEPOP_RUNTIME_IMAGE` to that digest in `.env` for a controlled rollback, recreate the service, and remove the override after the issue is resolved.

## Change mode or hardware

Stop the current three-file Compose selection, then start the new selection. Keep `compose.yaml` in both commands so the project and named volumes remain the same. Confirm the target host prerequisites before changing a hardware overlay.
