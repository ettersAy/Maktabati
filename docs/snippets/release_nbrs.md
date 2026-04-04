---
title: Strategy: Auto-Incrementing Release Numbers
description: To visually verify if your latest changes are live, embed a **Release Version** or **Commit Hash** in the footer.
---
# Auto-Incrementing Release Numbers

## Option A: Git Commit Hash (Most Accurate)
Displays the exact short hash of the commit currently deployed. If the hash on the site matches your latest local commit, you are up to date.

**1. Update `docs/.vitepress/config.ts` (or `.js`):**
VitePress allows injecting variables at build time. We will pass the git hash via `define` in Vite config.

**Create/Edit `docs/.vitepress/vite.config.ts` (or add to existing vite config):**
*Note: Since you are using standard VitePress, you might need to inject this via `package.json` script or a small build script.*

**Easier Method: Use a Build Script to Inject Version**
Create a script `scripts/inject-version.js`:
```javascript
// scripts/inject-version.js
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

try {
  const commitHash = execSync('git rev-parse --short HEAD').toString().trim();
  const date = new Date().toISOString().split('T')[0];
  const version = `v${date}-${commitHash}`;

  const configPath = path.resolve(__dirname, '../docs/.vitepress/config.mts'); // Adjust extension
  let content = fs.readFileSync(configPath, 'utf8');

  // Remove old version definition if exists
  content = content.replace(/version: ['"].*?['"],?/, '');
  
  // Add new version (simple regex replacement or append to themeConfig)
  // Assuming you have themeConfig in your config
  if (!content.includes(`version: '${version}'`)) {
    content = content.replace(
      /(themeConfig:\s*{)/, 
      `$1\n    version: '${version}',`
    );
  }

  fs.writeFileSync(configPath, content);
  console.log(`✅ Injected version: ${version}`);
} catch (error) {
  console.error('❌ Failed to inject version:', error.message);
  // Fallback version if git fails (e.g., in some CI contexts without .git)
  console.log('Using fallback version: v-local-build');
}
```

**2. Update `package.json`:**
Run this script before building.
```json
"scripts": {
  "docs:build": "node scripts/inject-version.js && vitepress build docs",
  "docs:dev": "vitepress dev docs"
}
```

**3. Display in Theme (`docs/.vitepress/theme/Layout.vue` or custom footer):**
If using default theme, `version` in `themeConfig` often appears automatically or can be added to the footer via slots.
*Alternatively, simple text in `config.ts` sidebar/footer:*
```typescript
// docs/.vitepress/config.ts
export default defineConfig({
  themeConfig: {
    footer: {
      message: `Released under MIT License. Build: <strong>${process.env.VERSION || 'latest'}</strong>`,
      copyright: 'Copyright © 2026 Ayoub Etters'
    }
  }
})
```
*Note: For the env var approach, pass it in GitHub Actions:*
```yaml
# In deploy.yml, build step
- name: Build with Version
  run: |
    export VERSION=$(git rev-parse --short HEAD)
    npm run docs:build
```

## Option B: Semantic Versioning (Manual but Clean)
Maintain a `VERSION` file in your repo.
1.  Create a file `VERSION` containing `1.0.0`.
2.  Update it manually on every merge to `main`.
3.  Read this file in your build process and display it.

**Recommendation:** Use **Option A (Commit Hash)** for development/CI visibility. It guarantees you know exactly *which* commit is live without manual updates. If you see `a1b2c3d` on the site and your local head is `a1b2c3d`, the deploy succeeded.