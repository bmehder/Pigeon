<p align="center">
  <img src="assets/static/pigeonops-mark.svg" width="72" height="72" alt="PigeonOps logo">
</p>

# PigeonOps

A small, mostly-static website built with Gleam, Markdown, Tailwind CSS, and one isolated Lustre widget.

**Live site:** [pigeonops.bmehder.chatgpt.site](https://pigeonops.bmehder.chatgpt.site)

PigeonOps is a deliberately absurd fictional product: precision logistics software for ambitious urban pigeons. The implementation is a proof of concept for a more serious architectural idea—using Gleam as a straightforward static-site build tool without turning the entire website into a single-page application.

## Philosophy

The site favors ordinary web technologies and visible build steps:

- Page content is written primarily in Markdown.
- Markdown can contain raw HTML when a section needs more structure.
- Gleam provides the shared document layout, header, and footer.
- Tailwind generates one static stylesheet.
- Static files are copied directly into the generated site.
- Lustre owns one interactive DOM island and nothing outside it.
- The final output is ordinary HTML, CSS, SVG, PNG, and one page-specific JavaScript bundle.

There is no site-wide hydration, client-side router, or generalized static-site framework.

## Quick start

You will need Gleam, Erlang/OTP, Node.js, and npm installed.

Install the Tailwind dependencies:

```sh
npm install
```

Build the complete site:

```sh
npm run build
```

Serve the generated files locally:

```sh
python3 -m http.server 8000 --directory dist
```

Then open [http://localhost:8000](http://localhost:8000).

The first widget build may download the Bun executable used internally by Lustre's official bundler. It is stored in an ignored local cache.

## Project structure

```text
.
├── .openai/
│   └── hosting.json            # Static hosting configuration
├── assets/
│   ├── css/
│   │   └── site.css            # Tailwind source and site styles
│   └── static/
│       ├── favicon.svg
│       ├── images/              # Content images copied into dist/assets
│       ├── og.png
│       └── pigeonops-mark.svg
├── content/
│   ├── field-notes/             # First Markdown collection
│   └── incident-reports/        # Second Markdown collection
├── routes/                     # Markdown tree mirrored into dist/
│   ├── index.md                # Homepage route
│   ├── contact/
│   │   └── index.md
│   ├── platform/
│   │   └── index.md
│   ├── field-notes/
│   │   └── index.md            # Field-note collection index
│   └── incident-reports/
│       └── index.md            # Incident-report collection index
├── src/
│   ├── components.gleam        # Reusable static HTML blocks
│   ├── collection.gleam        # Collection definitions and entry data type
│   ├── site.gleam              # Shared HTML layout, header, and footer
│   └── site_builder.gleam      # Markdown rendering and file generation
├── widgets/
│   ├── src/
│   │   └── dispatch.gleam      # Isolated Lustre application
│   └── gleam.toml              # JavaScript-target widget project
├── gleam.toml                  # Erlang-target static builder project
├── package.json                # Coordinates the complete build
└── dist/                       # Generated site; not committed
```

The root and `widgets/` directories are intentionally separate Gleam projects:

- The root project targets Erlang and performs filesystem-based site generation.
- The widget project targets JavaScript and bundles the Lustre island for the browser.

This keeps browser-only code out of the static generator while allowing both parts to be written in Gleam.

## Build pipeline

`npm run build` performs three explicit steps:

1. `gleam run` renders the Markdown pages with Mörk, wraps them in the shared layout, and copies `assets/static/` into `dist/assets/`.
2. The Lustre development tools bundle `widgets/src/dispatch.gleam` as `dist/assets/dispatch.js`.
3. Tailwind scans the page, layout, and widget sources and writes `dist/assets/site.css`.

The resulting output is:

```text
dist/
├── assets/
│   ├── dispatch.js
│   ├── favicon.svg
│   ├── og.png
│   ├── pigeonops-mark.svg
│   └── site.css
├── platform/
│   └── index.html
├── contact/
│   └── index.html
├── field-notes/                 # Generated field-note index and entries
├── incident-reports/            # Generated incident index and entries
└── index.html
```

## Markdown and raw HTML

Mörk handles the Markdown-to-HTML conversion. Normal prose, headings, lists, emphasis, separators, and blockquotes remain Markdown. Raw HTML is used for layout-heavy pieces such as the dashboard mockup, feature grid, and Lustre mount point.

Every page starts with required `title` and `description` frontmatter. The builder uses those values for the document title and social metadata, so page metadata lives alongside its content rather than in the build script.

Reusable static blocks use explicit placeholders such as `{{ contact-form }}`. The builder replaces those placeholders with HTML from `src/components.gleam` before parsing the Markdown. The mapping remains intentionally explicit; there is no general template language.

The project deliberately does not introduce an HTML DSL for the entire site. Shared document chrome lives in readable string templates in `src/site.gleam`.

## The Lustre island

The homepage contains one mount point and one page-specific module script:

```html
<div id='dispatch-widget'>Loading dispatch controls…</div>
<script type='module' src='/assets/dispatch.js'></script>
```

`widgets/src/dispatch.gleam` defines its own model, messages, update function, and view. Lustre replaces and manages only that element. The platform page does not load the widget bundle.

## Adding another route

Routes mirror their generated URL beneath `routes/`:

1. Add an `index.md` file at the desired path beneath `routes/`.
2. Include `title` and `description` frontmatter.
3. Add navigation to it where appropriate.

For example, `routes/about/index.md` automatically becomes `dist/about/index.html`. No Gleam configuration entry is required.

## Collections

`src/collection.gleam` defines each collection's source directory, public route, listing placeholder, and item label. The builder loads every configured collection through the same pipeline and generates its entries beneath the collection's route.

Every entry requires `title`, `description`, `published`, `featured_image`, and `featured_alt` frontmatter. Entries are sorted newest-first. The collection index receives its configured listing placeholder, while `{{ featured-image }}` places the entry's featured image within its Markdown body.

Adding another collection means adding one `Collection` value, its content directory, and an index route containing the configured placeholder. No collection-specific builder function is required.

## Content images

Content images live under `assets/static/images/` and are referenced with root-relative URLs such as `/assets/images/homing-pigeon.webp`. The current images were manually resized and converted to WebP before being committed; their sources and licenses are recorded in `IMAGE_CREDITS.md`.

An automatic image pipeline is intentionally deferred. A future version can generate multiple widths and formats and have the featured-image component emit `srcset` without changing collection content.

## Deployment

The site is deployed as a static build at [pigeonops.bmehder.chatgpt.site](https://pigeonops.bmehder.chatgpt.site). Hosting configuration lives in `.openai/hosting.json`, and the public directory is `dist/`.

Any static host could serve the same generated directory, including Vercel, Netlify, Cloudflare Pages, or GitHub Pages.

## Main dependencies

- [Gleam](https://gleam.run/) — site-generation and widget language
- [Mörk](https://mork.hexdocs.pm/) — CommonMark-compatible Markdown parser
- [Simplifile](https://simplifile.hexdocs.pm/) — filesystem operations
- [Tailwind CSS](https://tailwindcss.com/) — static CSS generation
- [Lustre](https://lustre.hexdocs.pm/) — the isolated interactive widget

## Deliberate non-goals

This project currently has no:

- automatic page discovery
- front matter or content collections
- client-side navigation
- site-wide application state
- site-wide hydration
- generalized plugin system
- production content management system

Those features should appear only if real requirements make them useful.
