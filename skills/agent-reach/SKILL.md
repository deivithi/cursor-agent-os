# Agent Reach — Internet Access for AI Agents

> **Source:** [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) (11K+ stars, MIT)
> **Version:** 1.3.0
> **Venv:** `~/.agent-reach-venv/`

## What It Does

CLI tool that gives AI agents structured read/search access to 17+ internet platforms — zero API fees.
After installation, agents call upstream tools directly (bird, yt-dlp, mcporter, gh CLI, Jina Reader, feedparser).

## Active Channels (8/16)

| Channel | Tool | Status | Usage |
|---------|------|--------|-------|
| **Web** | Jina Reader | ✅ | `curl -s "https://r.jina.ai/URL"` |
| **YouTube** | yt-dlp | ✅ | `yt-dlp --dump-json --no-download "URL"` |
| **GitHub** | gh CLI | ✅ | `gh search repos "query"` / `gh api ...` |
| **RSS** | feedparser | ✅ | Via Python: `feedparser.parse("URL")` |
| **Reddit** | JSON API + Exa | ✅ | `curl -s "https://www.reddit.com/r/SUBREDDIT/.json"` |
| **Exa Search** | mcporter | ✅ | `mcporter call 'exa.web_search_exa(query: "...", numResults: 5)'` |
| **Bilibili** | yt-dlp + API | ✅ | `yt-dlp --dump-json "bilibili_url"` |
| **V2EX** | Public API | ✅ | Via Python channel |

## Pending Channels

| Channel | Requirement | Command to Activate |
|---------|------------|-------------------|
| **Twitter/X** | Cookie auth | `agent-reach configure twitter-cookies "auth_token=xxx; ct0=yyy"` |
| **LinkedIn** | MCP setup | `pip install linkedin-scraper-mcp` |

## Core Commands

```bash
# Activate venv first
source ~/.agent-reach-venv/Scripts/activate

# Health check
agent-reach doctor

# Configure credentials
agent-reach configure twitter-cookies "COOKIE_STRING"
agent-reach configure proxy http://user:pass@ip:port

# Web reading (no venv needed)
curl -s "https://r.jina.ai/https://example.com"

# YouTube metadata + subtitles
yt-dlp --dump-json --no-download "https://youtube.com/watch?v=ID"
yt-dlp --write-auto-sub --sub-lang en --skip-download "URL"

# Exa semantic search
mcporter call 'exa.web_search_exa(query: "search terms", numResults: 5)'
mcporter call 'exa.get_code_context_exa(query: "code question", tokensNum: 3000)'

# GitHub search
gh search repos "query" --limit 10 --json fullName,stargazersCount,description
gh search code "pattern" --limit 10

# Reddit
curl -s "https://www.reddit.com/r/SUBREDDIT/hot.json?limit=10" | python -m json.tool
```

## Constraints

- Never create files in the agent workspace. Use `/tmp/` for temp, `~/.agent-reach/` for persistent
- Cookie-based platforms (Twitter, XHS) carry account ban risk — use dedicated accounts
- Credentials stored in `~/.agent-reach/config.yaml` (permission 600)
- WeChat articles require Camoufox, not standard web readers

## Complementary Tools

- **browser-use / agent-browser**: General web navigation (forms, JS-heavy sites)
- **Agent-Reach**: Structured, optimized access to specific platforms (faster, cleaner output)
- **Tavily**: AI-optimized web search (paid API)
- **Exa**: Semantic web search (free via mcporter MCP)
