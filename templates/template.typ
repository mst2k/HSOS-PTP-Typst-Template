#import "acronyms.typ": print-index, init-acronyms
#import "eidesstattliche_erklaerung.typ": *
#import "@preview/wrap-it:0.1.0": wrap-content

/* -------------------------------------------------------------
                        Helper Functions
   ------------------------------------------------------------- */


// Header builder function
#let buildMainHeader(mainHeadingContent, authorName) = {
  [
    #set block(above: 1em, below: 1em)
    #grid(
      columns: 2,
      gutter: 1fr,
      align(bottom, smallcaps(mainHeadingContent)),
      align(bottom, smallcaps(authorName)),
    )
    #line(length: 100%)    
  ]
}

// Get current page header using context
#let getHeader(authorName) = {
  context {
    let headings = query(heading)
    let currentPage = here().page()
    
    // Find all level 1 headings on or before the current page
    let mainSections = headings.filter(h => 
      h.level == 1 and 
      h.body != [Literaturverzeichnis] and 
      h.body != [Anhang] and 
      h.body != [Eidesstattliche Erklärung] and
      h.location().page() <= currentPage
    )
    
    if mainSections.len() > 0 {
      let lastMainHeading = mainSections.last()
      buildMainHeader(lastMainHeading.body, authorName)
    }
  }
}

// Image wrapper function
#let wrap-image(fig, width, content) = {
  let fig = box(fig, inset: 0.2em)
  wrap-content(fig, content, column-gutter: 1em, columns: (width, 97%-width))
}

// Appendix renderer
#let renderAppendix(appendix) = {
  counter(heading).update(0)
  heading(outlined: true, numbering: none)[Anhang]
  set heading(
    supplement: "Anhang",
    numbering: (..nums) => {
      nums = nums.pos()
      if nums.len() > 1 {
        numbering("A", ..nums.slice(1))
      }
    }
  )
  appendix
}

/* -------------------------------------------------------------
                        default Page-Config
   ------------------------------------------------------------- */
#let PageConfig = (
  margins: (
    top: 3cm,
    bottom: 3cm,
    left: 3cm,
    right: 3cm
  ),
  header_margin: 3cm,
  footer_margin: 3cm
)

// Configuration type for text spacing
#let SpacingConfig = (
  line_spacing: 1.5em,
  paragraph_spacing: 1.5em,
  heading_spacing: (
    above: 1.5em,
    below: 0.75em
  )
)

#let level1Pagebreak = false


// Main project function
#let project(
  title: "",
  abstract: [],
  abstract_en: none,  // Optional English abstract
  acronyms: (),
  symbols: (),
  authors: (),
  betreuer: "",
  modul: "",
  abgabedatum: "",
  language: "en",
  studiengang: "",
  body,
  appendix: [],
  page_config: PageConfig,
  spacing_config: SpacingConfig,
  level1Pagebreak:level1Pagebreak
) = {
  // Document setup
  set document(author: authors.map(a => a.name), title: title)
  set text(lang: language, size: 11pt)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")
  
  // Apply spacing configuration
  set par(
    justify: true,
    leading: spacing_config.line_spacing,
    spacing: spacing_config.paragraph_spacing
  )
  
  
  // Configure heading spacing
  show heading: it => {
    set block(
      above: spacing_config.heading_spacing.above,
      below: spacing_config.heading_spacing.below
    )
    it
  }
  
  // Initial page configuration
  set page(margin: page_config.margins, paper: "a4")

  // Page break handling for level 1 headings
  if level1Pagebreak {
    show heading.where(level: 1): it => {
    context {
      let headings = query(heading.where(level: 1))
      if headings.len() > 1 and it.body != headings.first().body {
        pagebreak(weak: true)
      }
    }
    it
  }
  }
  

  // Link and reference styling
  show link: set text(fill: blue.darken(60%))
  show ref: set text(fill: blue.darken(60%))

  init-acronyms(acronyms)

  // Title page
  align(center, image("../Images/logos/HS-OS-Logo-Standard-rgb.jpg"))
  
  align(center)[
    #v(20pt)
    #text(14pt, weight: 200, "INSTITUT FÜR DUALE STUDIENGÄNGE")
    #v(20pt)
    #emph(text(16pt, weight: 600, "Praxistransferprojekt im Studiengang " + studiengang))
    #v(25pt)
    #text(2em, weight: 700, title)
  ]

  // Author information
  text(
    12pt,
    font: ("New Computer Modern Sans"),
    pad(
      top: 5em,
      grid(
        columns: (auto, 1fr),
        rows: (60pt, 30pt),
        gutter: 1em,
        
        "Eingereicht von:",
        ..authors.map(author => [
          #author.name
          geb.: #author.birthday in #author.birthplace
          #author.address
        ]),
        "Matrikelnummer:",
        text(weight: 800, authors.at(0).matrikelnummer),
        "Studiengruppe:",
        text(weight: 800, authors.at(0).studiengruppe),
        "Betreuer:",
        betreuer,
        "Modul:",
        modul,
        "Abgabedatum:",
        abgabedatum
      ),
    )
  )

  // Abstract page(s)
  set page(numbering: "I", number-align: center)
  set text(top-edge: 0.75em, bottom-edge: -0.75em)
  
  // German Abstract
  v(1fr)
  align(center)[
    #heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Zusammenfassung]),
    )
  ]
  v(12pt)
  abstract
  
  // English Abstract (if provided)
  if abstract_en != none {
    pagebreak(weak: true)
    v(1fr)
    align(center)[
      #heading(
        outlined: false,
        numbering: none,
        text(0.85em, smallcaps[Abstract]),
      )
    ]
    v(12pt)
    abstract_en
  }
  
  v(2fr)
  counter(page).update(1)

  // Table of contents and indexes
  set text(top-edge: SpacingConfig.line_spacing, bottom-edge: 0.0em)
  set page(header: none)
  set block(above: 3em, below: 2em)

  show outline.entry.where(level: 1): it => strong(it)
  outline(depth: 4, indent: true, title: [Inhaltsverzeichnis])
  pagebreak()

  // Dynamic indexes using context
  context {
    // Figure index
    let figures = query(figure.where(kind: image))
    if figures.len() > 0 {
      heading(outlined: true, numbering: none)[Abbildungsverzeichnis]
      outline(title: none, target: figure.where(kind: image))
    }

    // Table index
    let tables = query(figure.where(kind: table))
    if tables.len() > 0 {
      heading(outlined: true, numbering: none)[Tabellenverzeichnis]
      outline(title: none, target: figure.where(kind: table))
    }

    // Math index
    let equations = query(figure.where(kind: "math"))
    if equations.len() > 0 {
      heading(outlined: true, numbering: none)[Formelverzeichnis]
      outline(title: none, target: figure.where(kind: "math"))
      
    }
  }

  // Acronyms index
  if acronyms.len() > 0 {
    print-index(
      title: "Abkürzungsverzeichnis",
      sorted: "up",
      delimiter: "",
      numbering: none,
      outlined: true
    )
  }

  // Symbols index
  if symbols.len() > 0 {
    heading(outlined: true, numbering: none)[Symbolverzeichnis]
    set block(above: 1em, below: 10pt)
    for sym in symbols.keys() {
      table(
        columns: (20%, 80%),
        stroke: none,
        inset: 0pt,
        [*#symbols.at(sym)*], [#sym]
      )
    }
  }

 // Main body with configured margins
  set block(above: spacing_config.heading_spacing.above, below: spacing_config.heading_spacing.below)
  set par(justify: true)
  set page(
    numbering: "1",
    number-align: center,
    paper: "a4",
    margin: (
      top: page_config.header_margin,
      bottom: page_config.footer_margin,
      left: page_config.margins.left,
      right: page_config.margins.right
    ),
    header: getHeader(authors.at(0).name)
  )
  counter(page).update(1)

  body

  // Appendix and end matter
  set page(numbering: "I", number-align: center, margin: auto, header: none)
  
  context {
    let firstBodyHeading = query(heading.where(numbering: "1.1")).first()
    counter(page).update(firstBodyHeading.location().page() - 1)
  }

  bibliography(
    title: [Literaturverzeichnis],
    style: "chicago-notes",
    "../sources.bib"
  )

  pagebreak(weak: true)

  if appendix.fields().len() > 1 {
    renderAppendix(appendix)
    pagebreak(weak: true)
  }

  eidesstattliche_erklaerung(title)
}