# Releasing

This project publishes Hex packages and HexDocs through GitHub Releases and GitHub Actions.

The release workflow lives in [`.github/workflows/publish-hex.yml`](./.github/workflows/publish-hex.yml) and runs when a GitHub Release is published.

Stable releases publish both the Hex package and HexDocs. Beta/prerelease releases publish the Hex package only.

## One-time setup

1. Generate a Hex API key that can publish packages:

   ```bash
   mix local.hex --force
   mix hex.user key generate --key-name publish-ci --permission api:write
   ```

2. Add the key to GitHub as the `HEX_API_KEY` secret.

   Recommended location:

   - repository: `Settings -> Environments -> hex-publish`
   - environment secret name: `HEX_API_KEY`

   Repository-level secrets also work, but the workflow is configured to use the `hex-publish` environment.

## Release flow

1. Update the version in [`mix.exs`](./mix.exs).

   Example:

   ```elixir
   @version "0.1.0"
   ```

2. Update the changelog and any release notes.

3. Verify the package locally:

   ```bash
   mix quality
   MIX_ENV=test mix coveralls.cobertura --raise
   mix docs.with_screenshots
   mix cinder_ui.docs.build
   cd demo && mix format --check-formatted && mix test
   cd demo && mix assets.build && npx playwright test
   ```

4. Commit and push the release changes to `main`:

   ```bash
   git add mix.exs CHANGELOG.md README.md CONTRIBUTING.md RELEASING.md .github/workflows/publish-hex.yml
   git commit -m "Release v0.1.0"
   git push origin main
   ```

5. Publish a GitHub Release:

   - open `GitHub -> Releases -> Draft a new release`
   - enter a new tag, for example `v0.1.0`
   - set the target to `main`
   - add release notes
   - click `Publish release`

   GitHub will create the tag for you when the release is published.

### Beta releases

To publish a beta/prerelease build:

1. Set `mix.exs` to a SemVer prerelease such as:

   ```elixir
   @version "0.1.0-beta.1"
   ```

2. Create a GitHub Release with the matching tag, for example `v0.1.0-beta.1`.
3. Mark the GitHub Release as a prerelease.

This will publish the Hex package as a prerelease version. HexDocs publication is skipped for prereleases so the stable docs remain the public default.

6. GitHub Actions will run `Publish Hex` automatically and:

   - verify `HEX_API_KEY` is available
   - verify the release tag matches the version in `mix.exs`
   - verify GitHub prerelease metadata matches the SemVer version shape
   - run formatting, compile, and test checks
   - export `doc/screenshots` from the demo app before packaging
   - publish the Hex package from the production environment
   - publish HexDocs from a dedicated docs environment for stable releases only

## Notes

- The tag must match the version exactly. `v0.1.0` requires `@version "0.1.0"` in `mix.exs`.
- Prerelease versions must also be marked as GitHub prereleases. For example, `v0.1.0-beta.1` requires `@version "0.1.0-beta.1"` and a GitHub prerelease.
- Hex will reject publishing a version that already exists.
- Site publishing is handled separately by [`.github/workflows/publish-site.yml`](./.github/workflows/publish-site.yml) on pushes to `main` or manual workflow dispatch. GitHub Releases do not deploy the site.
- If you prefer, you can still create and push the tag manually before publishing the GitHub Release, but it is not required.
