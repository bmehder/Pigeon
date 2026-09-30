import gleam/string

pub fn page(title: String, description: String, content: String) -> String {
  let title = escape_html(title)
  let description = escape_html(description)

  "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>" <> title <> "</title>
    <meta name='description' content='" <> description <> "'>
    <meta property='og:title' content='" <> title <> "'>
    <meta property='og:description' content='" <> description <> "'>
    <meta property='og:type' content='website'>
    <meta property='og:image' content='https://pigeonops.bmehder.chatgpt.site/assets/og.png'>
    <meta name='twitter:card' content='summary_large_image'>
    <meta name='twitter:title' content='" <> title <> "'>
    <meta name='twitter:description' content='" <> description <> "'>
    <meta name='twitter:image' content='https://pigeonops.bmehder.chatgpt.site/assets/og.png'>
    <link rel='icon' href='/assets/favicon.svg' type='image/svg+xml'>
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
      <div class='mx-auto flex h-[76px] max-w-6xl items-center justify-between px-6 sm:px-8 lg:px-10'>
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
        </nav>
        <span class='rounded-full border border-zinc-900/10 bg-white px-3 py-1.5 text-xs font-medium text-zinc-600 shadow-sm'>All systems coo</span>
      </div>
    </header>"
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
