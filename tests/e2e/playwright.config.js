// tests/e2e/playwright.config.js
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: '.',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    // Use env var if provided (CI), otherwise fallback to local
    baseURL: process.env.E2E_BASE_URL || 'http://localhost:4173/maktabati/',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  // ⚠️ CRITICAL FIX: Only start webServer if NOT in CI
  // In CI, we test the live GitHub Pages URL, not a local preview
  webServer: process.env.CI ? undefined : {
    command: 'npm run docs:preview',
    url: 'http://localhost:4173/maktabati/',
    reuseExistingServer: true,
  },
});