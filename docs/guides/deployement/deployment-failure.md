---
title: Deployment Failure
description: Guide to writing effective Makefiles for Laravel and Vue projects
---

# Deployment Failure Troubleshooting & Rollback Strategy

## 🚨 Deployment Failure Playbook

When a deployment workflow fails, follow this systematic approach to diagnose and recover.

| Step | Action | Where to Check | Command / Tool |
| :--- | :--- | :--- | :--- |
| **1. Identify Failure Point** | Check which specific job/step failed. | GitHub Actions Tab → Click Failed Run → Scroll to red step. | N/A |
| **2. Analyze Logs** | Read the error message in the collapsed log section. | Look for `Error:`, `Exit code`, or `Timeout`. | Copy error text to AI/Google. |
| **3. Verify Artifact/Build** | Did the build step actually produce files? | Check "Upload artifact" step logs or download the artifact. | `ls -R docs/.vitepress/dist` (if debugging locally). |
| **4. Check Environment** | Is the target URL accessible? Does it return 200 OK? | Browser or `curl`. | `curl -I https://your-site.com` |
| **5. Decide: Fix Forward vs. Rollback** | **Fix Forward:** Bug is in new code.<br>**Rollback:** New deploy broke existing stable site. | Compare current commit vs. previous stable commit. | `git log --oneline -5` |

## 🔄 Rollback Strategies (Senior Dev Best Practices)

**❌ Avoid Automated `git revert` in CI:**
Automatically force-pushing to `main` from a CI job is dangerous (race conditions, history rewriting).

**✅ Recommended Strategy: Manual "Fix Forward" or Safe Revert**
1.  **If the site is DOWN:**
    *   Go to GitHub Repo → **Actions** → Find the **last successful green run**.
    *   Click the three dots `...` → **Re-run jobs** (if it was a fluke) OR
    *   Manually revert the commit via UI:
        ```bash
        # Local terminal
        git checkout main
        git revert HEAD --no-edit
        git push origin main
        ```
2.  **If the site is UP but tests failed (False Positive):**
    *   Investigate the test logs. If the site works (as in your case), the test config is likely wrong (like the `webServer` issue above).
    *   Push a fix to the test config, do **not** revert the app code.

**🛡️ Prevention:**
*   Use **Preview Deploys** (deploy to a staging branch/URL first).
*   Require **Manual Approval** in GitHub Environments before deploying to `main`.
