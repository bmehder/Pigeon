pub fn page(title: String, content: String) -> String {
  "<!doctype html>
<html lang='en'>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>" <> title <> "</title>
    <link rel='stylesheet' href='/assets/site.css'>
  </head>
  <body class='min-h-screen bg-stone-50 font-sans text-zinc-950 antialiased'>
    " <> header() <> "
    <main class='page-content'>
      <div>
" <> content <> "      </div>
    </main>
    " <> footer() <> "
  </body>
</html>
"
}

fn header() -> String {
  "<header class='border-b border-zinc-900/10 bg-stone-50/90 backdrop-blur'>
      <div class='mx-auto flex h-[76px] max-w-6xl items-center justify-between px-6 sm:px-8 lg:px-10'>
        <a class='flex items-center gap-3 font-semibold tracking-tight' href='/'>
          <span class='grid size-9 place-items-center rounded-xl bg-orange-500 text-sm font-bold text-white shadow-sm'>P</span>
          PigeonOps
        </a>
        <nav class='hidden items-center gap-7 text-sm text-zinc-600 sm:flex' aria-label='Main navigation'>
          <a class='transition hover:text-zinc-950' href='/platform/'>Platform</a>
          <a class='transition hover:text-zinc-950' href='/#results'>Results</a>
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
