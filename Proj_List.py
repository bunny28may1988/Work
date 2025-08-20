#!/usr/bin/env python3
import sys, json, base64, urllib.request, urllib.error

API_VER = "7.1-preview.4"

def read_query():
    raw = sys.stdin.read()
    try:
        return json.loads(raw or "{}")
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"bad input: {e}"}))
        sys.exit(0)

def get(url, pat):
    req = urllib.request.Request(url)
    # PAT with empty username in basic auth
    token = ":" + pat
    b64 = base64.b64encode(token.encode("utf-8")).decode("utf-8")
    req.add_header("Authorization", f"Basic {b64}")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))

def main():
    q = read_query()
    org = q.get("org", "").strip()
    pat = q.get("pat", "")
    exclude_csv = q.get("exclude", "")

    if not org or not pat:
        print(json.dumps({"projects": []}))
        return

    exclude = [x for x in (exclude_csv.split(",") if exclude_csv else []) if x]

    base = f"https://dev.azure.com/{org}/_apis/projects?api-version={API_VER}"
    projects = []
    token = None

    try:
        while True:
            url = base if not token else f"{base}&continuationToken={token}"
            data = get(url, pat)

            # Collect names
            for item in data.get("value", []):
                name = item.get("name", "")
                if name and name not in exclude:
                    projects.append(name)

            token = data.get("continuationToken")
            if not token:
                break

        print(json.dumps({"projects": projects}))
    except urllib.error.HTTPError as e:
        # On API error, return empty list (keeps TF happy)
        print(json.dumps({"projects": [], "http_error": e.code}))
    except Exception as e:
        print(json.dumps({"projects": [], "error": str(e)}))

if __name__ == "__main__":
    main()
