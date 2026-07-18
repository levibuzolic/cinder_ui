import { defineConfig, type PlaywrightTestConfig } from "@playwright/test"

const config = {
  testDir: "./tests/browser",
  globalSetup: "./tests/browser/global_setup.ts",
  snapshotPathTemplate: "{testDir}/{testFilePath}-snapshots/{arg}{ext}",
  timeout: 60_000,
  expect: {
    timeout: 2_000,
    toHaveScreenshot: {
      animations: "disabled",
      caret: "hide",
      maxDiffPixelRatio: 0.015,
      scale: "css",
    },
  },
  fullyParallel: false,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [["list"]],
  use: {
    baseURL: "http://127.0.0.1:4000",
    launchOptions: process.env.PLAYWRIGHT_CHROME_EXECUTABLE
      ? { executablePath: process.env.PLAYWRIGHT_CHROME_EXECUTABLE }
      : undefined,
    trace: "on-first-retry",
    screenshot: "only-on-failure",
    video: "off",
  },
  webServer: {
    command: "mix do app.config --no-validate-compile-env + phx.server",
    url: "http://127.0.0.1:4000",
    cwd: __dirname,
    reuseExistingServer: true,
    // CI starts the watcher-free test server from a cold MIX_ENV=test build.
    // Keep local feedback fast while allowing that one-time compile to finish.
    timeout: process.env.CI ? 180_000 : 60_000,
    // Asset compilation happens once in global setup. Running the server in
    // test prevents dev watchers and live reload from replacing the page while
    // visual assertions are capturing it.
    env: { ...process.env, MIX_ENV: "test", PHX_SERVER: "true", PORT: "4000" },
  },
} satisfies PlaywrightTestConfig

export default defineConfig(config)
