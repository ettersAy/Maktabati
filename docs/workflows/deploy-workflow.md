---
title: Deploy Workflow 
description: Guide Deploy Workflow, Makefiles for a small static Website recommed by AI Qwen
---

# Deploy Workflow Best Practices (Short Doc)

## ✅ MUST HAVE

```yaml
# 1. Concurrency control (prevent race deployments)
concurrency:
  group: pages
  cancel-in-progress: true

# 2. Explicit permissions (least privilege)
permissions:
  contents: read
  pages: write
  id-token: write

# 3. Timeout limits (avoid hung jobs)
jobs:
  build:
    timeout-minutes: 15

# 4. Use latest stable action versions (v4+)
uses: actions/checkout@v4
uses: actions/upload-artifact@v4  # NOT v3

# 5. Cache dependencies
- uses: actions/setup-node@v4
  with:
    cache: npm
```

## ❌ AVOID
```yaml
# 1. Auto git revert/force-push on main (risky)
# ❌ git revert + git push --force-with-lease
# ✅ Let workflow fail; revert manually or via approved PR

# 2. Fixed sleep for server readiness
# ❌ sleep 10
# ✅ Use curl loop or wait-on to check actual availability

# 3. Hardcoded URLs in tests
# ❌ baseURL: 'http://localhost:4173'
# ✅ baseURL: process.env.E2E_BASE_URL || 'http://localhost:4173'

# 4. Running all browsers in CI (slow)
# ❌ projects: [chromium, firefox, webkit]
# ✅ projects: [chromium] # Run others in separate nightly job
```

## ➕ GOOD PLUS
```yaml
# 1. Artifact retention policy
- uses: actions/upload-artifact@v4
  with:
    retention-days: 7  # Auto-clean old reports

# 2. Selective browser install (faster CI)
run: npx playwright install --with-deps chromium

# 3. Failure notifications (Slack/Discord)
- name: Notify on failure
  if: failure()
  run: curl -X POST ... ${{ secrets.WEBHOOK }}

# 4. Environment protection rules
# Configure in GitHub Repo Settings > Environments > github-pages
# - Require approval for production deploys
# - Wait timer before deploy

# 5. Store deployment URL as output for downstream jobs
- name: Deploy
  id: deployment
  uses: actions/deploy-pages@v4
# Then use: ${{ steps.deployment.outputs.page_url }}
```

## 🔄 Rollback Strategy
| Method | When to Use | Risk |
|--------|-------------|------|
| **Manual Revert** | Most cases | Low |
| **Protected Branch + PR** | Team workflows | Low |
| **Blue/Green Deploy** | Critical apps | Medium (complex) |
| **Auto Git Revert** | ❌ Avoid on `main` | High |

**Recommended**: Let the workflow fail → Alert team → Manual revert via GitHub UI or `git revert` in a new PR. This preserves audit history and prevents race conditions.