import json
import os
import requests

APIM_URL = "https://apim-genai-lz-temp-02.azure-api.net/openai/deployments/chat/chat/completions?api-version=2024-10-21"
SUB_KEY = os.getenv("APIM_SUBSCRIPTION_KEY", "")

payload = {
    "model": "chat",
    "stream": True,
    "messages": [
        {"role": "system", "content": "You are a helpful assistant that responds in Markdown."},
        {"role": "user", "content": "Explain distance between Earth and Moon briefly."},
    ],
}

headers = {
    "Content-Type": "application/json",
    "api-key": SUB_KEY,
    "Accept": "text/event-stream",
}

with requests.post(APIM_URL, headers=headers, json=payload, stream=True, timeout=60) as r:
    r.raise_for_status()

    for line in r.iter_lines(decode_unicode=True):
        if not line:
            continue
        if line.startswith("data:"):
            data = line[len("data:"):].strip()
            if data == "[DONE]":
                break
            try:
                event = json.loads(data)
            except json.JSONDecodeError:
                continue

            delta = event.get("choices", [{}])[0].get("delta", {}).get("content")
            if delta:
                print(delta, end="", flush=True)

print()
