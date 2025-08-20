#!/usr/bin/env python3
import json, sys, base64, urllib.request, urllib.error

def read_query():
    try:
        return json.load(sys.stdin)
    except Exception as e:
        print(json.dumps({"projects": [], "error": f"bad input: {e}"}))
        sys.exit(0)

def get(url, pat):
    req = urllib.request.Request(url)
    # PAT via Basic auth: username blank, PAT as password
    token = base64.b64encode(f":{pat}".encode()).decode()
    req.add_header("Authorization", f"Basic {token}")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))

def main():
    q = read_query()
    org     = q.get("org", "")
    pat     = q.get("pat", "")
    exclude = q.get("exclude", "[]")

    try:
        exclude_list = json.loads(exclude) if isinstance(exclude, str) else exclude
    except Exception:
        exclude_list = []

    if not org or not pat:
        print(json.dumps({"projects": []}))
        return

    api = "7.1-preview.4"
    base = f"https://dev.azure.com/{org}/_apis/projects?api-version={api}"

    projects = []
    url = base
    while True:
        try:
            data = get(url, pat)
        except urllib.error.HTTPError as e:
            # keep Terraform happy with valid JSON even on failure
            print(json.dumps({"projects": []}))
            return

        for proj in data.get("value", []):
            name = proj.get("name")
            if name and name not in exclude_list:
                projects.append(name)

        token = data.get("continuationToken")
        if not token:
            break
        url = f"{base}&continuationToken={token}"

    print(json.dumps({"projects": projects}))

if __name__ == "__main__":
    main()
