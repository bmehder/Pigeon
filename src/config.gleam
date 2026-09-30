pub type Page {
  Page(source: String, output_directory: String, output: String)
}

pub fn pages() -> List(Page) {
  [
    Page(
      source: "pages/index.md",
      output_directory: "dist",
      output: "dist/index.html",
    ),
    Page(
      source: "pages/platform.md",
      output_directory: "dist/platform",
      output: "dist/platform/index.html",
    ),
    Page(
      source: "pages/contact.md",
      output_directory: "dist/contact",
      output: "dist/contact/index.html",
    ),
  ]
}

pub fn posts_index() -> Page {
  Page(
    source: "pages/posts.md",
    output_directory: "dist/posts",
    output: "dist/posts/index.html",
  )
}
