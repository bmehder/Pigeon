import gleam/int
import gleam/list
import gleam/string
import post.{type Post, Post}
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

pub fn post_list(posts: List(Post)) -> String {
  let cards =
    posts
    |> list.map(fn(post) {
      let Post(slug:, title:, description:, published:, ..) = post
      "<article>
        " <> post_date(published) <> "
        <h2><a href='/posts/" <> slug <> "/'>" <> site.escape_html(title) <> "</a></h2>
        <p>" <> site.escape_html(description) <> "</p>
        <a class='post-link' href='/posts/" <> slug <> "/'>Read field note <span aria-hidden='true'>→</span></a>
      </article>"
    })
    |> string.join("\n")

  "<div class='post-list'>" <> cards <> "</div>"
}

pub fn post_meta(published: String) -> String {
  "<div class='post-meta'>
    <a class='back-link' href='/posts/'>← All field notes</a>
    " <> post_date(published) <> "
  </div>"
}

fn post_date(published: String) -> String {
  "<p class='post-date'><time datetime='"
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
