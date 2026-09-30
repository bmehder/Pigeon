pub type Collection {
  Collection(
    source_directory: String,
    route: String,
    placeholder: String,
    item_label: String,
  )
}

pub type Entry {
  Entry(
    slug: String,
    title: String,
    description: String,
    published: String,
    featured_image: String,
    featured_alt: String,
    markdown: String,
  )
}

pub fn all() -> List(Collection) {
  [
    Collection(
      source_directory: "content/field-notes",
      route: "field-notes",
      placeholder: "{{ field-note-list }}",
      item_label: "field note",
    ),
    Collection(
      source_directory: "content/incident-reports",
      route: "incident-reports",
      placeholder: "{{ incident-report-list }}",
      item_label: "incident report",
    ),
  ]
}
