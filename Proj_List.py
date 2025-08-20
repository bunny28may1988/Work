#!/usr/bin/env python3
import sys, json, base64, urllib.request, urllib.parse

API_VERSION = "7.1-preview.4"

def read_query():
    """Read JSON from stdin (Terraform external data query)."""
    try:
        data = json.load(sys.stdin)
    except Exception:
        return {}
    return data or {}

def parse_exclude(ex):
    """Accept a list OR a comma-separated string; return a set of names."""
    if ex is None:
        return set()
    if isinstance(ex, list):
        return set(s.strip() for s in ex if str(s).strip())
    if isinstance(ex, str):
        return set(s.strip() for s in ex.split(",") if s.strip())
    return set()

def build_auth_header(pat: str) -> str:
    token = base64.b64encode(f":{pat}".encode("utf-8")).decode("ascii")
    return f"Basic {token}"

def fetch_projects(org: str, pat: str):
    """Yield project names across all pages."""
    base = f"https://dev.azure.com/{org}/_apis/projects"
    headers = {
        "Authorization": build_auth_header(pat),
        "Content-Type": "application/json",
    }
    cont = None

    while True:
        params = {"api-version": API_VERSION}
        if cont:
            params["continuationToken"] = cont
        url = f"{base}?{urllib.parse.urlencode(params)}"

        req = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(req) as resp:
                body = resp.read().decode("utf-8")
                data = json.loads(body or "{}")
                # Prefer header token; fall back to body if present
                cont = resp.headers.get("x-ms-continuationtoken") or data.get("continuationToken") or None
        except Exception:
            # On any error, return what we gathered so far (Terraform expects JSON always)
            return

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
    exclude = parse_exclude(q.get("exclude"))

    # If inputs are missing, emit empty list (keeps Terraform happy)
    if not org or not pat:
        print(json.dumps({"projects": []}))
        return

    projects_out = []
    for name in fetch_projects(org, pat):
        if name not in exclude:
            projects_out.append(name)

    print(json.dumps({"projects": projects_out}, ensure_ascii=False))

if __name__ == "__main__":
    main()
