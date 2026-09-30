import gleam/string

pub const base_url = "https://pigeonops.bmehder.chatgpt.site"

pub type Metadata {
  Metadata(
    title: String,
    description: String,
    path: String,
    image: String,
    page_type: String,
    indexable: Bool,
  )
}

pub fn page(metadata: Metadata, content: String) -> String {
  let Metadata(title:, description:, path:, image:, page_type:, indexable:) =
    metadata
  let title = escape_html(title)
  let description = escape_html(description)
  let canonical_url = escape_html(base_url <> path)
  let image_url = escape_html(absolute_url(image))
  let robots = case indexable {
    True -> ""
    False -> "\n    <meta name='robots' content='noindex'>"
  }

  "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>" <> title <> "</title>
    <meta name='description' content='" <> description <> "'>
    <link rel='canonical' href='" <> canonical_url <> "'>" <> robots <> "
    <meta property='og:title' content='" <> title <> "'>
    <meta property='og:description' content='" <> description <> "'>
    <meta property='og:type' content='" <> page_type <> "'>
    <meta property='og:url' content='" <> canonical_url <> "'>
    <meta property='og:image' content='" <> image_url <> "'>
    <meta name='twitter:card' content='summary_large_image'>
    <meta name='twitter:title' content='" <> title <> "'>
    <meta name='twitter:description' content='" <> description <> "'>
    <meta name='twitter:image' content='" <> image_url <> "'>
    <link rel='icon' href='/favicon.svg' type='image/svg+xml'>
    <link rel='icon' href='/favicon-32.png' type='image/png' sizes='32x32'>
    <link rel='apple-touch-icon' href='/apple-touch-icon.png' sizes='180x180'>
    <link rel='stylesheet' href='/assets/site.css'>
  </head>
  <body class='min-h-screen bg-stone-50 font-sans text-zinc-950 antialiased'>
    " <> header() <> "
    <main class='page-content'>
      <div>
      " <> content <> "
      </div>
    </main>
    " <> footer() <> "
  </body>
</html>
"
}

pub fn absolute_url(path: String) -> String {
  case
    string.starts_with(path, "http://") || string.starts_with(path, "https://")
  {
    True -> path
    False -> base_url <> path
  }
}

pub fn escape_html(value: String) -> String {
  value
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("'", "&#39;")
  |> string.replace("\"", "&quot;")
}

fn header() -> String {
  "<header class='border-b border-zinc-900/10 bg-stone-50/90 backdrop-blur'>
      <div class='relative mx-auto flex h-[76px] max-w-6xl items-center justify-between px-6 sm:px-8 lg:px-10'>
        <a class='flex items-center gap-3 font-semibold tracking-tight' href='/'>
          <img class='size-9 rounded-xl shadow-sm' src='/assets/pigeonops-mark.svg' alt='' width='36' height='36'>
          PigeonOps
        </a>
        <nav class='hidden items-center gap-7 text-sm text-zinc-600 sm:flex' aria-label='Main navigation'>
          <a class='transition hover:text-zinc-950' href='/platform/'>Platform</a>
          <a class='transition hover:text-zinc-950' href='/#results'>Results</a>
          <a class='transition hover:text-zinc-950' href='/field-notes/'>Field notes</a>
          <a class='transition hover:text-zinc-950' href='/incident-reports/'>Incidents</a>
          <a class='transition hover:text-zinc-950' href='/contact/'>Contact</a>
          " <> github_link() <> "
        </nav>
        <div class='flex items-center gap-3'>
          <span class='hidden rounded-full border border-zinc-900/10 bg-white px-3 py-1.5 text-xs font-medium text-zinc-600 shadow-sm lg:inline-flex'>All systems coo</span>
          <details class='mobile-menu sm:hidden'>
            <summary aria-label='Open navigation'>Menu</summary>
            <nav aria-label='Mobile navigation'>
              <a href='/platform/'>Platform</a>
              <a href='/#results'>Results</a>
              <a href='/field-notes/'>Field notes</a>
              <a href='/incident-reports/'>Incidents</a>
              <a href='/contact/'>Contact</a>
              " <> github_link() <> "
            </nav>
          </details>
        </div>
      </div>
    </header>"
}

fn github_link() -> String {
  "<a class='github-link' href='https://github.com/bmehder/Pigeon' target='_blank' rel='noreferrer' aria-label='PigeonOps on GitHub'>
    <svg viewBox='0 0 24 24' aria-hidden='true'><path fill='currentColor' d='M12 .7a11.5 11.5 0 0 0-3.64 22.41c.58.11.79-.25.79-.56v-2.23c-3.23.7-3.91-1.37-3.91-1.37-.53-1.34-1.29-1.7-1.29-1.7-1.05-.72.08-.71.08-.71 1.17.08 1.78 1.2 1.78 1.2 1.04 1.77 2.72 1.26 3.38.96.1-.75.4-1.26.74-1.55-2.58-.29-5.29-1.29-5.29-5.69 0-1.26.45-2.29 1.19-3.1-.12-.29-.52-1.47.11-3.06 0 0 .97-.31 3.16 1.18a10.9 10.9 0 0 1 5.76 0c2.19-1.49 3.16-1.18 3.16-1.18.63 1.59.23 2.77.11 3.06.74.81 1.19 1.84 1.19 3.1 0 4.42-2.72 5.39-5.31 5.68.42.36.79 1.07.79 2.16v3.21c0 .31.21.68.8.56A11.5 11.5 0 0 0 12 .7Z'/></svg>
  </a>"
}

fn footer() -> String {
  "<footer class='border-t border-zinc-900/10'>
      <div class='mx-auto flex min-h-[110px] max-w-6xl flex-col items-start justify-between gap-3 px-6 py-7 text-sm text-zinc-500 sm:flex-row sm:items-center sm:px-8 lg:px-10'>
        <p>© 2026 PigeonOps</p>
        <p>No cookies. Occasional crumbs.</p>
        <p>Built for birds with somewhere to be.</p>
      </div>
    </footer>"
}
