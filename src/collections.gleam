pub type Collection {
  Collection(
    source_directory: String,
    route: String,
    placeholder: String,
    item_label: String,
    indexable: Bool,
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
    indexable: Bool,
    markdown: String,
  )
}

pub fn all() -> List(Collection) {
  [
    Collection(
      source_directory: "collections/field-notes",
      route: "field-notes",
      placeholder: "{{ field-note-list }}",
      item_label: "field note",
      indexable: True,
    ),
    Collection(
      source_directory: "collections/incident-reports",
      route: "incident-reports",
      placeholder: "{{ incident-report-list }}",
      item_label: "incident report",
      indexable: True,
    ),
  ]
}
