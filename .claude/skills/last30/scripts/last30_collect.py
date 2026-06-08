#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
last30_collect.py — Coleta Reddit + HN + GitHub sem dependências externas.
Uso: python3 last30_collect.py "seu tópico aqui"
"""
import json, sys, time, subprocess, urllib.request, urllib.parse

# Windows: forçar stdout UTF-8 para evitar UnicodeDecodeError com cp1252
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

MONTH_AGO = int(time.time()) - 30 * 24 * 3600
UA = "last30-research/1.0 (opensource)"


def reddit(topic, limit=15):
    url = (
        f"https://www.reddit.com/search.json"
        f"?q={urllib.parse.quote(topic)}&sort=top&t=month&limit={limit}&include_over_18=off"
    )
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            d = json.load(r)
        return [
            {
                "source": "reddit",
                "title": p["data"]["title"],
                "url": f"https://reddit.com{p['data']['permalink']}",
                "score": p["data"]["score"],
                "comments": p["data"]["num_comments"],
                "subreddit": p["data"]["subreddit"],
                "snippet": p["data"].get("selftext", "")[:300],
                "date": time.strftime("%Y-%m-%d", time.gmtime(p["data"]["created_utc"])),
            }
            for p in d["data"]["children"]
        ]
    except Exception as e:
        return [{"source": "reddit", "error": str(e)}]


def reddit_top_comments(permalink_path, limit=5):
    """Busca top comentários de um post Reddit — totalmente grátis."""
    url = f"https://www.reddit.com{permalink_path}.json?limit={limit}&sort=top"
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            d = json.load(r)
        children = d[1]["data"]["children"]
        return [
            c["data"].get("body", "")[:400]
            for c in children
            if c["kind"] == "t1" and c["data"].get("body")
        ][:limit]
    except Exception:
        return []


def hn(topic, limit=15):
    url = (
        f"https://hn.algolia.com/api/v1/search"
        f"?query={urllib.parse.quote(topic)}&tags=story"
        f"&hitsPerPage={limit}&numericFilters=created_at_i>{MONTH_AGO}"
    )
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            d = json.load(r)
        return [
            {
                "source": "hackernews",
                "title": h.get("title", ""),
                "url": h.get("url") or f"https://news.ycombinator.com/item?id={h['objectID']}",
                "score": h.get("points", 0),
                "comments": h.get("num_comments", 0),
                "date": h.get("created_at", "")[:10],
            }
            for h in d["hits"]
        ]
    except Exception as e:
        return [{"source": "hackernews", "error": str(e)}]


def github(topic, limit=10):
    try:
        r = subprocess.run(
            [
                "gh", "search", "repos", topic,
                "--sort=updated", f"--limit={limit}",
                "--json", "name,description,stargazersCount,updatedAt,url",
            ],
            capture_output=True, text=True, timeout=15, encoding="utf-8",
        )
        stdout = (r.stdout or "").strip()
        repos = json.loads(stdout) if r.returncode == 0 and stdout else []
        return [
            {
                "source": "github",
                "title": repo["name"],
                "url": repo["url"],
                "score": repo["stargazersCount"],
                "description": repo.get("description") or "",
                "date": repo["updatedAt"][:10],
            }
            for repo in repos
        ]
    except Exception as e:
        return [{"source": "github", "error": str(e)}]


def main():
    topic = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "AI automation"

    reddit_results = reddit(topic)
    hn_results = hn(topic)
    github_results = github(topic)

    # Top 3 posts Reddit por engajamento — busca comentários grátis
    top_reddit = sorted(
        [r for r in reddit_results if "error" not in r],
        key=lambda x: x["score"] + x["comments"],
        reverse=True,
    )[:3]
    for post in top_reddit:
        path = post["url"].replace("https://reddit.com", "")
        post["top_comments"] = reddit_top_comments(path)

    output = {
        "topic": topic,
        "collected_at": time.strftime("%Y-%m-%d %H:%M BRT"),
        "since": time.strftime("%Y-%m-%d", time.gmtime(MONTH_AGO)),
        "reddit": reddit_results,
        "hackernews": hn_results,
        "github": github_results,
    }
    print(json.dumps(output, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
