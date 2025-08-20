#!/usr/bin/env python3
import sys, json, base64, urllib.request, urllib.error

def read_query():
    raw = sys.stdin.read()
    if not raw:
        return {}
    return json.loads(raw)

def ado_get(url, pat):
    # PAT auth: Basic base64(":PAT")
    token = base64.b64encode(f":{pat}".encode("utf-8")).decode("utf-8")
    req = urllib.request.Request(url, headers={"Authorization": f"Basic {token}"})
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))

def main():
    q = read_query()
    org      = q.get("org", "")
    pat      = q.get("pat", "")
    excludes = [p for p in q.get("excludes", "").split(",") if p]

    if not org or not pat:
        # external provider needs a map of string -> string
        print(json.dumps({"projects_json": "[]"}))
        return

    api  = "7.1-preview.4"
    base = f"https://dev.azure.com/{org}/_apis/projects?api-version={api}"

    projects = []
    token = None
    while True:
        url = base if not token else f"{base}&continuationToken={token}"
        data = ado_get(url, pat)

        # extract names
        for it in data.get("value", []):
            name = it.get("name")
            if not name:
                continue
            if name in excludes:
                continue
            projects.append(name)

        token = data.get("continuationToken")
        if not token:
            break

    # IMPORTANT: Return strings only → serialize array as a JSON string
    print(json.dumps({"projects_json": json.dumps(projects)}))

if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Keep provider happy even on error
        print(json.dumps({"projects_json": "[]"}))
