import gleam/io
import mork
import simplifile
import site

pub fn main() -> Nil {
  build_page(
    source: "pages/index.md",
    output_directory: "dist",
    output: "dist/index.html",
    title: "PigeonOps — Precision logistics",
  )
  build_page(
    source: "pages/platform.md",
    output_directory: "dist/platform",
    output: "dist/platform/index.html",
    title: "Platform — PigeonOps",
  )
  copy_static_assets()

  io.println("Generated 2 pages and static assets in dist/")
}

fn copy_static_assets() -> Nil {
  let assert Ok(Nil) =
    simplifile.copy_directory(at: "assets/static", to: "dist/assets")
  Nil
}

fn build_page(
  source source: String,
  output_directory output_directory: String,
  output output: String,
  title title: String,
) -> Nil {
  let assert Ok(markdown) = simplifile.read(from: source)
  let content = markdown |> mork.parse |> mork.to_html
  let html = site.page(title, content)

  let assert Ok(Nil) = simplifile.create_directory_all(output_directory)
  let assert Ok(Nil) = simplifile.write(to: output, contents: html)
  Nil
}
