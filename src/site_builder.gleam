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

  build_page(
    source: "pages/index.md",
    output_directory: "dist",
    output: "dist/index.html",
    posts:,
  )
  build_page(
    source: "pages/platform.md",
    output_directory: "dist/platform",
    output: "dist/platform/index.html",
    posts:,
  )
  build_page(
    source: "pages/contact.md",
    output_directory: "dist/contact",
    output: "dist/contact/index.html",
    posts:,
  )
  build_page(
    source: "pages/posts.md",
    output_directory: "dist/posts",
    output: "dist/posts/index.html",
    posts:,
  )
  list.each(posts, build_post)
  copy_static_assets()

  io.println(
    "Generated 4 pages, "
    <> int.to_string(list.length(posts))
    <> " posts, and static assets in dist/",
  )
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
  posts posts: List(Post),
) -> Nil {
  let assert Ok(document) = simplifile.read(from: source)
  let Document(title:, description:, markdown:) = parse_document(document)

  let content =
    markdown
    |> expand_components(posts)
    |> mork.parse
    |> mork.to_html
  let html = site.page(title, description, content)

  let assert Ok(Nil) = simplifile.create_directory_all(output_directory)
  let assert Ok(Nil) = simplifile.write(to: output, contents: html)
  Nil
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

fn build_post(post: Post) -> Nil {
  let Post(slug:, title:, description:, markdown:) = post
  let output_directory = "dist/posts/" <> slug
  let post_html =
    markdown |> expand_components([]) |> mork.parse |> mork.to_html
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

fn expand_components(markdown: String, posts: List(Post)) -> String {
  markdown
  |> string.replace("{{ contact-form }}", components.contact_form())
  |> string.replace("{{ post-list }}", components.post_list(posts))
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
