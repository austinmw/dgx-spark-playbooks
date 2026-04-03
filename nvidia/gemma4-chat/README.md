# Gemma 4 Chat Stack

Compose stack for:

- `Open WebUI` as the browser UI
- `vLLM` as the OpenAI-compatible backend
- `Gemma 4` as the model family

This is intended for a single DGX Spark and an MBP client connected through NVIDIA Sync.

## Files

- `compose.yaml`: Starts `Open WebUI` and `vLLM`
- `.env.example`: Variables you need to set
- `sync-start.sh`: Helper script for NVIDIA Sync custom ports

## Why this shape

- Keeps `Open WebUI` and `vLLM` in separate containers
- Avoids mixing this setup with the repo's older `Open WebUI + Ollama` flow
- Uses named volumes so `docker compose down -v` can fully wipe the stack
- Binds host ports to `127.0.0.1` on the Spark so the UI/API are meant to be reached through SSH/NVIDIA Sync rather than your LAN

## Setup

1. On the Spark, copy `.env.example` to `.env`.
2. Edit `.env` and set:
   - `HF_TOKEN`
   - `VLLM_API_KEY`
   - `WEBUI_SECRET_KEY`
3. Start the stack:

```bash
docker compose up -d
```

4. Watch model startup:

```bash
docker compose logs -f vllm
```

5. Open the UI through NVIDIA Sync or any SSH tunnel pointed at `OPEN_WEBUI_PORT` in `.env`.

## NVIDIA Sync

Create a Custom Port entry in NVIDIA Sync:

- Name: `Gemma 4 Chat`
- Port: `12010` by default, or whatever `OPEN_WEBUI_PORT` is set to in `.env`
- Auto open in browser: enabled
- Start Script: paste this:

```bash
#!/usr/bin/env bash
exec /path/to/dgx-spark-playbooks/nvidia/gemma4-chat/sync-start.sh
```

Replace `/path/to/dgx-spark-playbooks` with the actual checkout path on your Spark.

## Useful commands

Start:

```bash
docker compose up -d
```

Stop containers but keep volumes:

```bash
docker compose down
```

Full wipe, including downloaded model cache and Open WebUI data:

```bash
docker compose down -v
```

Check status:

```bash
docker compose ps
```

Follow logs:

```bash
docker compose logs -f
```

## Switching models

Edit `VLLM_MODEL` in `.env`, then recreate the backend:

```bash
docker compose up -d
```

Recommended starting point:

- `nvidia/Gemma-4-31B-IT-NVFP4`

Smaller / faster options:

- `google/gemma-4-E4B-it`
- `google/gemma-4-E2B-it`

## Notes

- `Open WebUI` is preconfigured to use the `vLLM` service over the internal Compose network at `http://vllm:8000/v1`.
- `ENABLE_OLLAMA_API` is disabled so the UI does not keep trying to talk to an Ollama backend.
- `vLLM` is configured with the `gemma4` reasoning parser and enables Gemma thinking mode by default for chat completions, so you do not need to put `<|think|>` into the Open WebUI system prompt just to turn reasoning on.
- The first model load can take a while. `MODEL_LIST_TIMEOUT=60` is there to make the initial model list fetch less fragile.
- `.env` is intentionally local-only and ignored by Git because it contains secrets.
