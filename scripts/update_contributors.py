#!/usr/bin/env python3
"""Regenerate the contributor table in CONTRIBUTORS.md from git history.

Identity merging comes from the repo's .mailmap (git applies it to %aN/%aE and
to `git check-mailmap`). Only the text between the START/END markers in
CONTRIBUTORS.md is rewritten, so the intro and any hand-written sections stay.

Optional scripts/contributors-overrides.json supplies GitHub handles or display
names that can't be derived from the git data.

Usage: update_contributors.py [--repo PATH] [--file CONTRIBUTORS.md]
"""
import argparse, collections, json, re, subprocess, sys
from pathlib import Path

START, END = "<!-- CONTRIBUTORS:START -->", "<!-- CONTRIBUTORS:END -->"
BOT_EMAIL = re.compile(r"(\[bot\]|noreply@anthropic\.com|noreply@github\.com$|dependabot|github-actions)", re.I)
BOT_NAME = re.compile(r"(\[bot\]|^dependabot|^github-actions|^claude\b)", re.I)
NOREPLY = re.compile(r"^(?:\d+\+)?([A-Za-z0-9-]+)@users\.noreply\.github\.com$", re.I)
TRAILER = re.compile(r"^(.*?)\s*<([^>]+)>\s*$")


def git(repo, *args, stdin=None):
    r = subprocess.run(["git", "-C", repo, *args], input=stdin, capture_output=True, text=True, check=True)
    return r.stdout


def is_bot(name, email):
    return bool(BOT_EMAIL.search(email) or BOT_NAME.search(name))


def collect(repo):
    people = {}  # canonical email (lowercase) -> dict
    def person(name, email):
        p = people.setdefault(email.lower(), {"name": name, "email": email, "n": 0, "years": set()})
        return p

    # Authors: %aN / %aE already pass through .mailmap.
    for line in git(repo, "log", "--all", "--format=%aN|%aE|%ad", "--date=format:%Y").splitlines():
        name, email, year = line.rsplit("|", 2)
        if is_bot(name, email):
            continue
        p = person(name, email)
        p["n"] += 1
        p["years"].add(int(year))

    # Co-authors: trailers aren't mailmapped automatically, so canonicalize them.
    raw = git(repo, "log", "--all", "--format=%ad|%(trailers:key=Co-authored-by,valueonly,separator=%x1f)",
              "--date=format:%Y").splitlines()
    co = []
    for line in raw:
        year, _, rest = line.partition("|")
        for t in filter(None, rest.split("\x1f")):
            m = TRAILER.match(t.strip())
            if m:
                co.append((m.group(1), m.group(2), int(year)))
    if co:
        mapped = git(repo, "check-mailmap", "--stdin",
                     stdin="\n".join(f"{n} <{e}>" for n, e, _ in co) + "\n").splitlines()
        for (_, _, year), out in zip(co, mapped):
            m = TRAILER.match(out)
            if not m or is_bot(m.group(1), m.group(2)):
                continue
            p = person(m.group(1), m.group(2))
            p["n"] += 1
            p["years"].add(year)
    return people


def render(people, overrides):
    rows = []
    for p in sorted(people.values(), key=lambda p: (-p["n"], p["name"].lower())):
        m = NOREPLY.match(p["email"])
        ov = overrides.get(p["email"].lower(), {})
        handle = ov.get("github") or (m.group(1) if m else None)
        name = ov.get("name", p["name"])
        who = f"[{name}](https://github.com/{handle})" if handle else name
        lo, hi = min(p["years"]), max(p["years"])
        rows.append(f"| {who} | {'@' + handle if handle else '—'} | {p['n']} | {lo if lo == hi else f'{lo}–{hi}'} |")
    return "\n".join(["| Contributor | GitHub | Commits | Active |", "|---|---|---|---|", *rows])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=".")
    ap.add_argument("--file", default="CONTRIBUTORS.md")
    a = ap.parse_args()
    path = Path(a.repo) / a.file
    text = path.read_text()
    if START not in text or END not in text:
        sys.exit(f"{path}: missing {START} / {END} markers")
    ov_path = Path(__file__).with_name("contributors-overrides.json")
    overrides = json.loads(ov_path.read_text()) if ov_path.exists() else {}
    table = render(collect(a.repo), overrides)
    head, rest = text.split(START, 1)
    _, tail = rest.split(END, 1)
    new = f"{head}{START}\n{table}\n{END}{tail}"
    if new != text:
        path.write_text(new)
        print("Updated", path)
    else:
        print("No changes")


if __name__ == "__main__":
    main()
