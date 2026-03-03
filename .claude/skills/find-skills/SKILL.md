---
name: find-skills
description: "Search and install agent skills from the open ecosystem. WHEN: user asks 'find a skill for X', 'is there a skill that can...', 'how do I do X', or wants to extend agent capabilities."
---

# Find Skills

Search, evaluate, and install skills from the [skills.sh](https://skills.sh/) ecosystem.

## Workflow

### 1. Search

Run multiple queries with alternative terms to broaden results:

```bash
npx skills find [query]
```

### 2. Verify

For each candidate, fetch its skills.sh page and extract audit status:

```bash
# Use WebFetch on the skills.sh URL from search results
WebFetch https://skills.sh/<owner>/<repo>/<skill>
```

### 3. Present results

Present a single table with all candidates:

| Skill | Installs | Trust Hub | Socket | Snyk | Install |
|-------|----------|-----------|--------|------|---------|
| [skill-name](https://skills.sh/owner/repo/skill) | N/wk | ✅/❌/⚠️ | ✅/❌/⚠️ | ✅/❌/⚠️ | `npx skills add owner/repo@skill` |

### 4. Install

```bash
npx skills add <owner/repo@skill> -g -y  # global
npx skills add <owner/repo@skill> -y     # project only
```

## When No Skills Are Found

1. Acknowledge no matches
2. Offer to help directly
3. Suggest `npx skills init <name>` for custom skills
