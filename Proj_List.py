#!/usr/bin/env python3
import sys, json, base64, urllib.request, urllib.error, urllib.parse

API_VERSION = "7.1-preview.4"

def read_query():
    try:
        return json.load(sys.stdin) or {}
    except Exception:
        return {}

def auth_header(pat: str) -> str:
    token = base64.b64encode(f":{pat}".encode("utf-8")).decode("ascii")
    return f"Basic {token}"

def fetch_projects(org: str, pat: str):
    """Yield project names (handles pagination)."""
    base = f"https://dev.azure.com/{org}/_apis/projects"
    headers = {"Authorization": auth_header(pat), "Content-Type": "application/json"}
    cont = None

    while True:
        params = {"api-version": API_VERSION}
        if cont:
            params["continuationToken"] = cont
        url = f"{base}?{urllib.parse.urlencode(params)}"

        req = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode("utf-8") or "{}")
                # Try header first, then body (some previews include it in body)
                cont = resp.headers.get("x-ms-continuationtoken") or data.get("continuationToken")
        except Exception:
            return  # stop on error, caller prints what it has

        for item in data.get("value", []):
            name = item.get("name")
            if name:
                yield name

        if not cont:
            break

def main():
    q = read_query()
    org = (q.get("org") or "").strip()
    pat = (q.get("pat") or "").strip()
    # exclude can be list OR comma-separated string
    exclude = q.get("exclude", [])
    if isinstance(exclude, str):
        exclude = [s.strip() for s in exclude.split(",") if s.strip()]
    excl = set(exclude)

    if not org or not pat:
        print(json.dumps({"projects": []}))
        return

    out = [p for p in fetch_projects(org, pat) or [] if p not in excl]
    print(json.dumps({"projects": out}, ensure_ascii=False))

if __name__ == "__main__":
    main()
