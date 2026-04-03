---
title: Prompts AI
description: List of commune prompts
---

# Prompts AI

## Stack Assistance

```Markdown
- can you explain more the `Path Check` note I didn't understand what I have to check and what I should change. also I provided you with `playwright.config.js` so you can checked.

- about `Force Push Warning` what are the best practices to revert if the e2e test fails. or no need to revert are the github action revert automaticly if e2e fails?

- another point check Makefile is it best practice and commune to have all those cmd inside this file or it's better to extract them in a script shell and call this script before executing the main cmd ? what are the best practices and commune between senior devs
```


```Markdown

- I have a question: "once I test localy and commit and then push and deploy, can we modify `.github/workflows/deploy.yml` to add a section to run the e2e on prod and if something fail revert ? if yes & it's commune practice implement this.

- Write a complete documentation how to write a best `.github/workflows/deploy.yml` following best & commune practices. choose the section it goes to.

- check & improve the documentations `docs/projects/maktabati/incidents/how-to-document.md` & `docs/projects/maktabati/incidents/incident-template.md` => the goal is to keep the incident report as light as possible but in the same time if it's give to an ai agent it will be hellpful to him to quickly identify future error or avoid making the same mistake.

- Update Makefile to add more advanced cmd like " check if the server is running before running test cmd & if not propose to the user to run the server" or similar ideas.

- write a complete documentation how to write the best Makefile for laravel 13 & vueJs 3 project => I'm not sure under what section this doc should go mybe workflow or snippets, so it's up to you to decide.

- run e2e test, fix error, rerun the test until all error are gone.
- write an incident report under section `docs/projects/maktabati/incidents/`
- once all done start push proccess mean test commit push
---

```

```Markdown
My Stack:
- OS: Linux Mint (APT, Zsh)
- Browsers: Min 1.35.4, Chrome Dev
- Frameworks: Laravel 13 (Sail/PHPUnit/Playwright), Vue 3
- Tools: Sublime Text, VS Code, AI Copilot CLI

Response Rules:
1. Simple Questions: Give a very short answer + a small code example if possible. No explanations.
2. Complex Questions: Be direct and concise.
3. Format: Use Markdown for structure and Bash for code blocks.

Example Style:
User: How to list all aliases?
Assistant:
```bash
alias
cat ~/.zshrc
# Or save to file
alias > /tmp/list_alias.txt
```
---

## Documentation

```Markdown
Project Context:
| **Type**      | Static Documentation Website |
| **Framework** | VitePress (Vue 3)            |
| **Language**  | Markdown + Vue 3 Components  |

Task:
Write a concise documentation guide detailing the disk cleanup steps performed (e.g., Docker prune, cache removal), so I can save it and follow the same process for future maintenance.
```

## Quick Links

- [Architecture](./architecture.md)
- [API Reference](./api-reference.md)
- [Workflows](./workflows.md)
- [Changelog](./changelog.md)

## Getting Started

```bash
git clone git@github.com:ettersAy/[project].git
cd [project]
./vendor/bin/sail up
```

## Key Features

- Feature 1
- Feature 2
- Feature 3
