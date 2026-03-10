# Demo

Phoenix host app for Cinder UI marketing/docs pages and browser tests.

## Run locally

```bash
mix setup
../bin/demo
```

Open [http://localhost:4000](http://localhost:4000):

- `/` marketing home page
- `/docs` live component catalog
- `/docs/:id` component detail pages

## Browser tests

```bash
npm ci
mix assets.build
npx playwright test
```

## Static export for GitHub Pages

```bash
mix site.export
```

This writes a publishable static bundle to `../dist/site` with assets in `../dist/site/assets`.
