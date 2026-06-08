# Agent Reach — Internet Access Router

Read the skill file at `.claude/skills/agent-reach/SKILL.md` for full reference.

## Task

The user wants to access internet platforms via Agent Reach. Their request: $ARGUMENTS

## Routing

1. **If health check / doctor**: Run `source ~/.agent-reach-venv/Scripts/activate && agent-reach doctor`
2. **If web reading**: Use `curl -s "https://r.jina.ai/URL"`
3. **If YouTube**: Use `source ~/.agent-reach-venv/Scripts/activate && yt-dlp --dump-json --no-download "URL"`
4. **If GitHub search**: Use `gh search repos "query"` or `gh search code "pattern"`
5. **If Reddit**: Use `curl -s "https://www.reddit.com/r/SUBREDDIT/.json?limit=10"`
6. **If Exa search**: Use `mcporter call 'exa.web_search_exa(query: "...", numResults: 5)'`
7. **If RSS**: Use Python with feedparser in the agent-reach venv
8. **If Twitter/X**: Check if cookies configured, then use bird CLI
9. **If configure**: Run `source ~/.agent-reach-venv/Scripts/activate && agent-reach configure ...`

## Guidelines

- Always activate the venv first: `source ~/.agent-reach-venv/Scripts/activate`
- For web reading, Jina Reader does NOT need the venv — just curl
- Present results cleanly formatted in Portuguese (BRT timezone)
- If a channel is not active, suggest the activation command from the skill file
