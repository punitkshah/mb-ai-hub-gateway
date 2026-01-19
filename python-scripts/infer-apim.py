import os
import json
import requests


APIM_BASE_URL = "<APIM ENDPOINT_URL till azure-api.net>" 
DEPLOYMENT = "chat"
API_VERSION = "2024-10-21"

# Put your APIM subscription key or APIM-protected API key here:
# - set env var: APIM_SUBSCRIPTION_KEY="..."
APIM_SUBSCRIPTION_KEY = os.getenv("APIM_SUBSCRIPTION_KEY", "").strip()

# Common APIM headers: many APIM instances use "Ocp-Apim-Subscription-Key".
# If your APIM policy expects "api-key" or "Authorization", adjust below accordingly.
HEADERS = {
    "Content-Type": "application/json",
}
if APIM_SUBSCRIPTION_KEY:
    HEADERS["Ocp-Apim-Subscription-Key"] = APIM_SUBSCRIPTION_KEY


def chat_completion(prompt: str) -> dict:
    url = (
        f"{APIM_BASE_URL}/openai/deployments/{DEPLOYMENT}/chat/completions"
        f"?api-version={API_VERSION}"
    )

    payload = {
        "model": DEPLOYMENT,  # matches your example: "model":"chat"
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant that responds in Markdown. Help me with my math homework!",
            },
            {"role": "user", "content": prompt},
        ],
        # Optional knobs (uncomment if you want):
        # "temperature": 0.7,
        # "max_tokens": 500,
    }

    resp = requests.post(url, headers=HEADERS, json=payload, timeout=60)

    # Raise for non-2xx and show useful diagnostics
    if not resp.ok:
        raise RuntimeError(
            f"Request failed: {resp.status_code}\n"
            f"Response: {resp.text}\n"
            f"URL: {url}\n"
            f"Headers sent: {json.dumps({k: ('***' if 'key' in k.lower() else v) for k, v in HEADERS.items()}, indent=2)}"
        )

    return resp.json()


def main():
    if not APIM_SUBSCRIPTION_KEY:
        print("WARNING: APIM_SUBSCRIPTION_KEY env var is not set.")
        print("If your APIM requires a subscription key, set it and re-run:")
        print('  export APIM_SUBSCRIPTION_KEY="your-key-here"')
        print()

    result = chat_completion("How to calculate the distance between earth and moon?")

    # Azure OpenAI-style response: choices[0].message.content
    content = (
        result.get("choices", [{}])[0]
        .get("message", {})
        .get("content", "")
    )

    print("=== Model response ===")
    print(content or "[No content found]")
    # If you want to inspect the full JSON:
    # print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
