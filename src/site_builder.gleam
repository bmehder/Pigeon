import components
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import mork
import post.{type Post, Post}
import simplifile
import site

type Document {
  Document(title: String, description: String, markdown: String)
}

pub fn main() -> Nil {
  let posts = load_posts()
  let replacements = [
    #("{{ contact-form }}", components.contact_form()),
    #("{{ post-list }}", components.post_list(posts)),
  ]
  let routes = load_routes()

  list.each(routes, build_route(_, replacements))
  list.each(posts, build_post(_, replacements))
  copy_static_assets()

  io.println(
    "Generated "
    <> int.to_string(list.length(routes))
    <> " routes, "
    <> int.to_string(list.length(posts))
    <> " posts, and static assets in dist/",
  )
}

fn copy_static_assets() -> Nil {
  let assert Ok(Nil) =
    simplifile.copy_directory(at: "assets/static", to: "dist/assets")
  Nil
}

fn load_routes() -> List(String) {
  let assert Ok(files) = simplifile.get_files(in: "routes")

  files
  |> list.filter(string.ends_with(_, ".md"))
  |> list.sort(string.compare)
}

fn build_route(source: String, replacements: List(#(String, String))) -> Nil {
  let assert Ok(document) = simplifile.read(from: source)
  let Document(title:, description:, markdown:) = parse_document(document)
  let relative_path = string.drop_start(source, 7)
  let output = "dist/" <> string.drop_end(relative_path, 3) <> ".html"
  let output_directory = output_directory(output)

  let content =
    markdown |> expand_components(replacements) |> mork.parse |> mork.to_html
  let html = site.page(title, description, content)

  let assert Ok(Nil) = simplifile.create_directory_all(output_directory)
  let assert Ok(Nil) = simplifile.write(to: output, contents: html)
  Nil
}

fn output_directory(output: String) -> String {
  let parts = string.split(output, on: "/")
  parts
  |> list.take(list.length(parts) - 1)
  |> string.join("/")
}

fn load_posts() -> List(Post) {
  let assert Ok(filenames) = simplifile.read_directory(at: "content/posts")

  filenames
  |> list.filter(string.ends_with(_, ".md"))
  |> list.sort(string.compare)
  |> list.map(load_post)
}

fn load_post(filename: String) -> Post {
  let assert Ok(source) = simplifile.read(from: "content/posts/" <> filename)
  let slug = string.drop_end(filename, 3)
  let Document(title:, description:, markdown:) = parse_document(source)
  Post(slug:, title:, description:, markdown:)
}

fn build_post(post: Post, replacements: List(#(String, String))) -> Nil {
  let Post(slug:, title:, description:, markdown:) = post
  let output_directory = "dist/posts/" <> slug
  let post_html =
    markdown |> expand_components(replacements) |> mork.parse |> mork.to_html
  let content = "<article class='post-content'>" <> post_html <> "</article>"
  let html = site.page(title, description, content)

  let assert Ok(Nil) = simplifile.create_directory_all(output_directory)
  let assert Ok(Nil) =
    simplifile.write(to: output_directory <> "/index.html", contents: html)
  Nil
}

fn parse_document(source: String) -> Document {
  let #(frontmatter, markdown) = mork.split_frontmatter_from_input(source)
  let assert Ok(title) = frontmatter_value(frontmatter, "title")
  let assert Ok(description) = frontmatter_value(frontmatter, "description")
  Document(title:, description:, markdown:)
}

fn expand_components(
  markdown: String,
  replacements: List(#(String, String)),
) -> String {
  replacements
  |> list.fold(markdown, fn(markdown, replacement) {
    let #(placeholder, html) = replacement
    string.replace(markdown, placeholder, html)
  })
}

fn frontmatter_value(frontmatter: String, key: String) -> Result(String, Nil) {
  frontmatter
  |> string.split("\n")
  |> list.find_map(fn(line) {
    case string.split_once(line, on: ":") {
      Ok(#(found_key, value)) ->
        case string.trim(found_key) == key {
          True -> Ok(string.trim(value))
          False -> Error(Nil)
        }
      _ -> Error(Nil)
    }
  })
}
