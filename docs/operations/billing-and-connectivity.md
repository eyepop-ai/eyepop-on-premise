# Billing and connectivity

On-premise inference is metered through durable usage events. Media and inference results stay on the local host by default; configured Agent outputs can send selected results to webhook, MQTT, or NATS destinations. The runtime sends usage metadata to EyePop.

## End-to-end flow

1. The runtime measures active session replicas and emits `session_replica_uptime_seconds` usage events.
2. Before transmission, it writes the exact event batch to a local SQLite spool under `/opt/eyepop/private`.
3. It sends the batch to the Compute API at `/v1/instances/{instance_uuid}/usage` using the registered instance identity.
4. Compute resolves the trusted account and instance identity, then relays the batch to the private Billing API.
5. Billing returns `202 Accepted` only after the event batch has been durably inserted into its usage ledger.
6. The runtime removes the local batch only after successful acceptance.

Network failures and non-success responses leave the batch in the local spool for retry. Replayed events use stable identities, so duplicates are handled idempotently by the billing ledger.

## Operational implications

- Keep the `eyepop_instance_private` volume across restarts and upgrades. Deleting it can remove usage awaiting delivery.
- Allow outbound HTTPS to `compute.eyepop.ai` even when all media sources and inference clients are local.
- A temporary Compute or Billing outage should increase queued usage rather than stop inference immediately; restore connectivity so the queue can drain.
- Webhook, MQTT, and NATS outputs in Agent mode are application event delivery. They do not replace or control EyePop usage delivery.

## Troubleshooting delivery

Inspect runtime logs for registration or usage-delivery errors:

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  logs --since 30m eyepop-instance
```

Replace the mode and hardware overlays with the deployed selection.

Confirm DNS and TLS reachability from the host:

```shell
curl --head --silent --show-error --output /dev/null \
  --write-out 'HTTP %{http_code}\n' \
  https://compute.eyepop.ai
```

Do not delete the private volume as a troubleshooting step. Preserve it while collecting logs so queued events can be retried after connectivity is restored.
