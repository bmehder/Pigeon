<p align="center">
  <img src="assets/static/pigeonops-mark.svg" width="72" height="72" alt="PigeonOps logo">
</p>

# PigeonOps

A small, mostly-static website built with Gleam, Markdown, Tailwind CSS, and one isolated Lustre widget.

**Live site:** [pigeonops.bmehder.chatgpt.site](https://pigeonops.bmehder.chatgpt.site)

PigeonOps is a deliberately absurd fictional product: precision logistics software for ambitious urban pigeons. The implementation demonstrates using Gleam as a straightforward static-site build tool without turning the entire website into a single-page application.

## Philosophy

The site favors ordinary web technologies and visible build steps:

- Page content is written primarily in Markdown.
- Markdown can contain raw HTML when a section needs more structure.
- Gleam provides the shared document layout, header, and footer.
- Tailwind generates one static stylesheet.
- Static files are copied directly into the generated site.
- Lustre owns one interactive DOM island and nothing outside it.
- The final output is ordinary HTML, CSS, SVG, WebP content images, a few PNG metadata assets, and one page-specific JavaScript bundle.

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
│   ├── default/
│   │   └── favicon.svg          # Neutral fallback when no custom icon exists
│   └── static/
│       ├── favicon.svg          # Optional site-specific favicon master
│       ├── images/              # Source images optimized during the build
│       ├── og.png
│       └── pigeonops-mark.svg
├── collections/
│   ├── field-notes/             # First Markdown collection
│   └── incident-reports/        # Second Markdown collection
├── routes/                     # Markdown tree mirrored into dist/
│   ├── index.md                # Homepage route
│   ├── 404.md                  # Static not-found page
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
│   ├── collections.gleam       # Collection definitions and entry data type
│   ├── site.gleam              # Shared HTML layout, header, and footer
│   └── pigeonops.gleam         # Markdown rendering and file generation
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

`npm run build` performs four explicit steps:

1. `gleam run` renders the Markdown pages with Mörk, wraps them in the shared layout, writes the sitemap and robots file, and copies `assets/static/` into `dist/assets/`.
2. The image script replaces `dist/assets/images/` with resized, compressed WebP versions of the source images and generates the favicon files.
3. The Lustre development tools bundle `widgets/src/dispatch.gleam` as `dist/assets/dispatch.js`.
4. Tailwind scans the route, layout, and widget sources and writes `dist/assets/site.css`.

The resulting output is:

```text
dist/
├── favicon.svg
├── favicon-32.png
├── apple-touch-icon.png
├── robots.txt
├── sitemap.xml
├── assets/
│   ├── dispatch.js
│   ├── favicon.svg              # Copied source; generated icons live at root
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

Every page starts with required `title` and `description` frontmatter. The builder uses those values for the document title and social metadata, so page metadata lives alongside its content rather than in the build script. Add `noindex: true` to any route or collection entry to emit a robots `noindex` directive and omit it from the sitemap.

The shared layout also emits canonical URLs, Open Graph fields, and X card fields. Collection entries use their featured image for social previews; ordinary routes use the site-wide `assets/static/og.png` image. The generated 404 page includes `noindex` metadata and is omitted from `sitemap.xml`.

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

`src/collections.gleam` defines each collection's source directory, public route, listing placeholder, and item label. The builder loads every configured collection through the same pipeline and generates its entries beneath the collection's route.

Every entry requires `title`, `description`, `published`, `featured_image`, and `featured_alt` frontmatter. Entries are sorted newest-first. The collection index receives its configured listing placeholder, while `{{ featured-image }}` places the entry's featured image within its Markdown body.

Adding another collection means adding one `Collection` value, its content directory, and an index route containing the configured placeholder. No collection-specific builder function is required. Set that collection's `indexable` field to `False` to add `noindex` to its index and every entry, and to exclude the entire collection from the sitemap. An individual entry can still opt out with `noindex: true` while its collection remains indexable.

## Content images

Content image sources live under `assets/static/images/` and are referenced with root-relative `.webp` URLs such as `/assets/images/homing-pigeon.webp`. During every build, `scripts/optimize-images.mjs` recursively finds supported raster images, applies EXIF rotation, limits them to 1000 pixels wide without upscaling, and writes quality-68 WebP files into `dist/assets/images/`. Source subdirectories are preserved.

The current pipeline creates one optimized file per source image. A future version can generate multiple widths and have the featured-image component emit `srcset` without changing collection content.

## Favicons

The build always emits a compact modern icon set at the root of `dist/`:

- `favicon.svg` for modern browsers
- `favicon-32.png` as a raster fallback
- `apple-touch-icon.png` at 180×180 for home-screen bookmarks

The PigeonOps mark lives in `assets/static/favicon.svg`, so the site currently uses its own icon. The build prefers that file and derives both PNG files from it. Removing it restores the neutral icon in `assets/default/favicon.svg`; replacing it customizes the complete icon set from one source.

## Search discovery and error handling

Each build generates `sitemap.xml` from all routes and collection entries, including publication dates for collection content. It also generates `robots.txt`, which allows crawling and points search engines at the sitemap. `routes/404.md` builds to `dist/404.html` for static hosts.

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

- client-side navigation
- site-wide application state
- site-wide hydration
- generalized plugin system
- production content management system
- installable PWA or service worker

Those features should appear only if real requirements make them useful.
