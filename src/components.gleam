import collection.{type Entry, Entry}
import gleam/int
import gleam/list
import gleam/string
import site

pub fn contact_form() -> String {
  "<form class='contact-form'>
    <div class='form-field'>
      <label for='name'>Your name</label>
      <input id='name' name='name' type='text' autocomplete='name' placeholder='Beatrice Wren'>
    </div>
    <div class='form-field'>
      <label for='email'>Work email</label>
      <input id='email' name='email' type='email' autocomplete='email' placeholder='beatrice@example.com'>
    </div>
    <div class='form-field'>
      <label for='flock-size'>Flock size</label>
      <select id='flock-size' name='flock-size'>
        <option value=''>Select a range</option>
        <option>1–10 pigeons</option>
        <option>11–100 pigeons</option>
        <option>101–1,000 pigeons</option>
        <option>More pigeons than we can legally count</option>
      </select>
    </div>
    <div class='form-field'>
      <label for='message'>What can we help with?</label>
      <textarea id='message' name='message' rows='5' placeholder='We need to improve cross-town delivery times…'></textarea>
    </div>
    <button class='primary-button' type='submit' disabled>Send to the loft</button>
    <p class='form-note'>The form looks the part, but it is not connected to a submission service yet.</p>
  </form>"
}

pub fn collection_list(
  route: String,
  item_label: String,
  entries: List(Entry),
) -> String {
  let cards =
    entries
    |> list.map(fn(entry) {
      let Entry(
        slug:,
        title:,
        description:,
        published:,
        featured_image:,
        featured_alt:,
        ..,
      ) = entry
      "<article class='group'>
        <a class='entry-image' href='/" <> route <> "/" <> slug <> "/' tabindex='-1'>
          <img src='" <> site.escape_html(featured_image) <> "' alt='" <> site.escape_html(
        featured_alt,
      ) <> "' loading='lazy'>
        </a>
        <div class='entry-card-copy'>
        " <> published_date(published) <> "
        <h2><a href='/" <> route <> "/" <> slug <> "/'>" <> site.escape_html(
        title,
      ) <> "</a></h2>
        <p>" <> site.escape_html(description) <> "</p>
        <a class='entry-link' href='/" <> route <> "/" <> slug <> "/'>Read " <> item_label <> " <span aria-hidden='true'>→</span></a>
        </div>
      </article>"
    })
    |> string.join("\n")

  "<div class='collection-list'>" <> cards <> "</div>"
}

pub fn entry_meta(
  route: String,
  item_label: String,
  published: String,
) -> String {
  "<div class='entry-meta'>
    <a class='back-link' href='/" <> route <> "/'>← All " <> item_label <> "s</a>
    " <> published_date(published) <> "
  </div>"
}

pub fn featured_image(entry: Entry) -> String {
  let Entry(featured_image:, featured_alt:, ..) = entry
  "<figure class='featured-image'>
    <img src='" <> site.escape_html(featured_image) <> "' alt='" <> site.escape_html(
    featured_alt,
  ) <> "'>
  </figure>"
}

fn published_date(published: String) -> String {
  "<p class='published-date'><time datetime='"
  <> site.escape_html(published)
  <> "'>"
  <> format_date(published)
  <> "</time></p>"
}

fn format_date(published: String) -> String {
  let assert [year, month, day] = string.split(published, on: "-")
  let assert Ok(day) = int.parse(day)
  let month = case month {
    "01" -> "January"
    "02" -> "February"
    "03" -> "March"
    "04" -> "April"
    "05" -> "May"
    "06" -> "June"
    "07" -> "July"
    "08" -> "August"
    "09" -> "September"
    "10" -> "October"
    "11" -> "November"
    "12" -> "December"
    _ -> month
  }
  int.to_string(day) <> " " <> month <> " " <> year
}
