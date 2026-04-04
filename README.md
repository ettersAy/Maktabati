# Maktabati

A personal documentation library and learning notebook built with VitePress. This project is designed to store my notes, guides, workflows, and project documentation in a clean, easy-to-navigate site.

## Why this repo

- Personal knowledge base for notes, ideas, and technical references
- Built with a static site generator so it stays fast and easy to maintain
- Hosted with GitHub Pages for simple cloud access
- Organized for learning best practices without overcomplicating the setup

## Tech stack

- **VitePress** for static documentation
- **Vue 3** as the underlying framework
- **Tailwind CSS** for styling utilities
- **GitHub Actions** for deployment to GitHub Pages


## Quick start

```bash
git clone https://github.com/ettersAy/maktabati.git
cd maktabati
npm install
npm run docs:dev
```

Open the local URL shown in the terminal to preview the site.

## Useful commands

```bash
npm run docs:dev      # Start local VitePress dev server
npm run docs:build    # Build the static site
npm run docs:preview  # Preview the generated site locally

# Check who is using port 4173
lsof -i :4173
# OR if lsof is not installed
ss -tulpn | grep 4173

# Kill the process (replace <PID> with the number from the command above)
kill -9 <PID>
```

If you prefer Makefile shortcuts:

```bash
make install
make dev
make build
make preview
```

## Repository structure

- `docs/` — site content and Markdown pages
- `docs/.vitepress/` — VitePress configuration
- `package.json` — npm scripts and dependencies
- `scripts/` — helper scripts used by the project
- `.github/workflows/` — GitHub Actions deployment pipeline

## Deployment

This site is deployed automatically via GitHub Actions when changes are pushed to `main`.

## Notes

This is a personal project, so the structure is kept simple and useful. The goal is to learn good practices while keeping the documentation easy to update and access from anywhere.
