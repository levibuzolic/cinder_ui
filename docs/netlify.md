# Netlify Deploys

Netlify lists Elixir and Erlang in its build image, but the built-in versions are older than this project requires. The repository therefore builds the static site in GitHub Actions with the existing BEAM setup and deploys the generated `dist/site` directory to Netlify with the Netlify CLI.

## Required Setup

1. Create a Netlify site. Git integration is optional because `.github/workflows/netlify-site.yml` deploys with the CLI. If Git integration is enabled, keep the repository `netlify.toml` guard in place so Netlify does not publish the repository root.
2. Create a Netlify personal access token.
3. Add these repository secrets in GitHub:
   - `NETLIFY_AUTH_TOKEN`
   - `NETLIFY_SITE_ID`

Until both secrets are configured, the workflow exits with a notice and does not deploy.

## Deploy Behavior

- Pushes to `main` deploy production with `netlify deploy --prod`.
- Pull requests from this repository deploy a stable preview alias with `netlify deploy --alias deploy-preview-<number>`.
- Pull requests from forks are skipped because GitHub does not expose repository secrets to untrusted fork workflows.

The repository also includes a `netlify.toml` file that points Netlify at `dist/site` and intentionally fails native Netlify Git builds. This prevents accidental source-code deploys from Netlify's Git integration. The GitHub Actions workflow deploys the already-built `dist/site` directory directly with `netlify deploy --dir dist/site`.

Default preview URLs look like:

```text
https://deploy-preview-42--your-site-name.netlify.app
```

If the site uses Netlify DNS, configure an automatic deploy subdomain in Netlify to expose previews on a custom domain, for example:

```text
https://deploy-preview-42.preview.example.com
```
