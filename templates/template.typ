#import "acronyms.typ": print-index, init-acronyms
#import "eidesstattliche_erklaerung.typ": *
#import "@preview/wrap-it:0.1.0": wrap-content

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
  paragraph_spacing: 2.5em,
  heading_spacing: (
    above: 2em,
    below: 1.25em
  )
)

#let level1Pagebreak = false


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

// Main project function
#let project(
  title: "",
  abstract: [],
  abstract_en: none,
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
  
  // Globale Texteinstellungen
  set text(lang: language, size: 11pt)
  
  // Globale Spacing-Einstellungen
  set block(spacing: spacing_config.line_spacing)
  set par(
    justify: false,
    leading: spacing_config.line_spacing,
    first-line-indent: 0em,
    spacing: spacing_config.paragraph_spacing
  )
  
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")
  
  // Heading styling
  show heading: it => {
    set block(
      above: spacing_config.heading_spacing.above,
      below: spacing_config.heading_spacing.below
    )
    it
  }
  
  // Initial page configuration
  set page(margin: page_config.margins, paper: "a4")

      show heading.where(level: 1): it => {
      context {
        let headings = query(heading.where(level: 1))
        if headings.len() > 1 and it.body != headings.first().body and level1Pagebreak {
          pagebreak(weak: true)
        }
      }
      it
    }
  

  // Title page setup
  align(center, image("../Images/logos/HS-OS-Logo-Standard-rgb.jpg"))
  
  align(center)[
    #v(-10pt)
    #text(14pt, weight: 200, "INSTITUT FÜR DUALE STUDIENGÄNGE")
    #v(20pt)
    #emph(text(16pt, weight: 600, "Praxistransferprojekt im Studiengang " + studiengang))
    #v(10pt)
    #text(2em, weight: 700, title)
  ]

  // Author information
  text(
    12pt,
    font: ("New Computer Modern"),
    pad(
      top: 5em,
      grid(
        columns: (auto, 1fr),
        rows: (60pt, 30pt),
        gutter: 0.8em,
        
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

  // Abstract pages
  set page(numbering: none, number-align: center)
  set par(justify: true)
  
  // Konsistentes Spacing für Abstracts
  set block(spacing: spacing_config.line_spacing)
  
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
  
  // English Abstract
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
  
  // State für die letzte römische Seitenzahl
  let last_page_state = state("last_roman_page", 0)
  
  // Verzeichnisse mit römischen Zahlen
  set page(numbering: none, number-align: center, header: none)
  
  show outline.entry: set block(spacing: spacing_config.line_spacing)
  show outline.entry.where(level: 1): it => strong(it)
  
  outline(depth: 4, indent: true, title: [Inhaltsverzeichnis])
  pagebreak()
  set page(numbering: "I", number-align: center, header: none)
  counter(page).update(1)  // Start der römischen Nummerierung

  // Weitere Verzeichnisse (Abbildungen, Tabellen, etc.)
  context{
    let figures = query(figure.where(kind: image))
    if figures.len() > 0 {
      heading(outlined: true, numbering: none)[Abbildungsverzeichnis]
      outline(title: none, target: figure.where(kind: image))
    }

    let tables = query(figure.where(kind: table))
    if tables.len() > 0 {
      heading(outlined: true, numbering: none)[Tabellenverzeichnis]
      outline(title: none, target: figure.where(kind: table))
    }

    let equations = query(figure.where(kind: "math"))
    if equations.len() > 0 {
      heading(outlined: true, numbering: none)[Formelverzeichnis]
      outline(title: none, target: figure.where(kind: "math"))
    }
  }

  if acronyms.len() > 0 {
    print-index(
      title: "Abkürzungsverzeichnis",
      sorted: "up",
      delimiter: "",
      numbering: none,
      outlined: true
    )
  }

  if symbols.len() > 0 {
    heading(outlined: true, numbering: none)[Symbolverzeichnis]
    set block(above: spacing_config.line_spacing, below: 10pt)
    for sym in symbols.keys() {
      table(
        columns: (20%, 80%),
        stroke: none,
        inset: 0pt,
        [*#symbols.at(sym)*], [#sym]
      )
    }
  }

  // Speichere die letzte römische Seitenzahl im State
  context{
     // Speichere die letzte römische Seitenzahl im State
    let current_page = counter(page).get().first()
    last_page_state.update(current_page)
  }

  // Haupttext mit arabischen Zahlen
  counter(page).update(0)  // Starte bei 1 für den Haupttext
  set page(
    numbering: "1",
    number-align: center,
    margin: (
      top: page_config.header_margin,
      bottom: page_config.footer_margin,
      left: page_config.margins.left,
      right: page_config.margins.right
    ),
    header: getHeader(authors.at(0).name)
  )

  body

  context {
    // Zurück zu römischen Zahlen für Literaturverzeichnis etc.
    set page(numbering: "I", number-align: center, margin: auto, header: none)
    
    // Hole die letzte römische Seitenzahl aus dem State
    let last_roman = last_page_state.get()
    counter(page).update(last_roman + 1)  // Jetzt können wir +1 addieren

    bibliography(
      title: [Literaturverzeichnis],
      style: "chicago-notes",
      "../sources.bib"
    )

    pagebreak(weak: true)

    if appendix != [] {
      renderAppendix(appendix)
      pagebreak(weak: true)
    }

    eidesstattliche_erklaerung(title)
  }
}