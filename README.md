# Gleam static-site proof of concept

Install the CSS build dependency once:

```sh
npm install
```

Build the complete site from the project root:

```sh
npm run build
```

The build renders the Markdown files in `pages/`, wraps them in the shared
layout from `src/site.gleam`, and writes the home and platform pages beneath
`dist/`. Tailwind compiles `assets/css/site.css` to `dist/assets/site.css`.
The separate Gleam project in `widgets/` bundles the homepage's Lustre island
to `dist/assets/dispatch.js`. Files from `assets/static/` are copied into
`dist/assets/` by the Gleam build.
# Pigeon
