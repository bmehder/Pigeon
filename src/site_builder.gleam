import collection.{type Collection, type Entry, Collection, Entry}
import components
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import mork
import simplifile
import site

type Document {
  Document(title: String, description: String, markdown: String)
}

type LoadedCollection {
  LoadedCollection(config: Collection, entries: List(Entry))
}

pub fn main() -> Nil {
  prepare_output()
  let collections = collection.all() |> list.map(load_collection)
  let collection_replacements = collections |> list.map(collection_replacement)
  let replacements =
    list.append(
      [#("{{ contact-form }}", components.contact_form())],
      collection_replacements,
    )
  let routes = load_routes()

  list.each(routes, build_route(_, replacements))
  list.each(collections, build_collection(_, replacements))
  copy_static_assets()

  io.println(
    "Generated "
    <> int.to_string(list.length(routes))
    <> " routes, "
    <> int.to_string(entry_count(collections))
    <> " collection entries, and static assets in dist/",
  )
}

fn prepare_output() -> Nil {
  let assert Ok(Nil) = simplifile.create_directory_all("dist")
  let assert Ok(Nil) = simplifile.clear_directory(at: "dist")
  Nil
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

fn load_collection(config: Collection) -> LoadedCollection {
  let Collection(source_directory:, ..) = config
  let assert Ok(filenames) = simplifile.read_directory(at: source_directory)

  let entries =
    filenames
    |> list.filter(string.ends_with(_, ".md"))
    |> list.sort(string.compare)
    |> list.map(load_entry(config, _))
    |> list.sort(by: newest_first)

  LoadedCollection(config:, entries:)
}

fn load_entry(config: Collection, filename: String) -> Entry {
  let Collection(source_directory:, ..) = config
  let assert Ok(source) =
    simplifile.read(from: source_directory <> "/" <> filename)
  let slug = string.drop_end(filename, 3)
  let Document(title:, description:, markdown:) = parse_document(source)
  let #(frontmatter, _) = mork.split_frontmatter_from_input(source)
  let assert Ok(published) = frontmatter_value(frontmatter, "published")
  let assert Ok(featured_image) =
    frontmatter_value(frontmatter, "featured_image")
  let assert Ok(featured_alt) = frontmatter_value(frontmatter, "featured_alt")
  Entry(
    slug:,
    title:,
    description:,
    published:,
    featured_image:,
    featured_alt:,
    markdown:,
  )
}

fn build_collection(
  loaded: LoadedCollection,
  replacements: List(#(String, String)),
) -> Nil {
  let LoadedCollection(config:, entries:) = loaded
  list.each(entries, build_entry(config, _, replacements))
}

fn build_entry(
  config: Collection,
  entry: Entry,
  replacements: List(#(String, String)),
) -> Nil {
  let Collection(route:, item_label:, ..) = config
  let Entry(slug:, title:, description:, published:, markdown:, ..) = entry
  let output_directory = "dist/" <> route <> "/" <> slug
  let entry_replacements = [
    #("{{ featured-image }}", components.featured_image(entry)),
    ..replacements
  ]
  let entry_html =
    markdown
    |> expand_components(entry_replacements)
    |> mork.parse
    |> mork.to_html
  let content =
    "<article class='entry-content'>"
    <> components.entry_meta(route, item_label, published)
    <> entry_html
    <> "</article>"
  let html = site.page(title, description, content)

  let assert Ok(Nil) = simplifile.create_directory_all(output_directory)
  let assert Ok(Nil) =
    simplifile.write(to: output_directory <> "/index.html", contents: html)
  Nil
}

fn collection_replacement(loaded: LoadedCollection) -> #(String, String) {
  let LoadedCollection(
    config: Collection(route:, placeholder:, item_label:, ..),
    entries:,
  ) = loaded
  #(placeholder, components.collection_list(route, item_label, entries))
}

fn entry_count(collections: List(LoadedCollection)) -> Int {
  collections
  |> list.fold(0, fn(total, loaded) {
    let LoadedCollection(entries:, ..) = loaded
    total + list.length(entries)
  })
}

fn newest_first(a: Entry, b: Entry) {
  let Entry(published: a_date, ..) = a
  let Entry(published: b_date, ..) = b
  string.compare(b_date, a_date)
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
