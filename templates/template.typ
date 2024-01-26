#import "acronyms.typ": print-index, init-acronyms
#import "eidesstattliche_erklaerung.typ": *

#let buildMainHeader(mainHeadingContent, authorName) = {
  [
    #set block(above: 1em, below: 1em)
    #grid(
      columns: 3,
      gutter: 1fr,
      align(bottom, smallcaps(mainHeadingContent)),
      align(bottom, image("../images/logos/HS-OS-Logo-Quer-rgb.jpg", width: auto, height: 20pt)),
      align(bottom, smallcaps(authorName)),
    )
    #line(length: 100%)    
  ]
}

// Returns the header for the current page
#let getHeader(authorName) = {
  locate(loc => {
    // Find if there is a level 1 heading on the current page
    let nextMainHeading = query(selector(heading).after(loc), loc).find(headIt => {
     headIt.location().page() == loc.page() and headIt.level == 1
    })
    if (nextMainHeading != none) {
      return buildMainHeader(nextMainHeading.body, authorName)
    }
    // Find the last previous level 1 heading -- at this point surely there's one :-
    let lastMainHeading = query(selector(heading).before(loc), loc).filter(headIt => {
      headIt.level == 1
    }).last()
    // Find if the last level > 1 heading in previous pages
    let previousSecondaryHeadingArray = query(selector(heading).before(loc), loc).filter(headIt => {
      headIt.level > 1
    })
    let lastSecondaryHeading = if (previousSecondaryHeadingArray.len() != 0) {previousSecondaryHeadingArray.last()} else {none}
    // Find if the last secondary heading exists and if it's after the last main heading
    return buildMainHeader(lastMainHeading.body, authorName)
  })
}

// 
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

#let project(
  title: "",
  abstract: [],
  acronyms: (),
  symbols: (),
  authors: (),
  betreuer: "",
  modul: "",
  abgabedatum: "",
  language: "",
  studiengang: "",
  body,
  appendix: []
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set text(font: "times new roman", lang: "de", size: 11pt)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")
  set par(justify: true)

  // Page Break before every lvl 1 heading, except for the first one
  show heading.where(level: 1): it => {
    let headings = query(selector(heading.where(level: 1)), it.location())
    if headings.len() > 1{
      if it.body != headings.first().body {
      pagebreak(weak: true)
    }
    }
    it
  }

  //highlight clickable items
  show link: set text(fill: blue.darken(60%))
  show ref: set text(fill: blue.darken(60%))

  init-acronyms(acronyms)

  ////////////////
  // Title page //
  ////////////////

  //Logo
  image("../images/logos/HS-OS-Logo-Standard-rgb.jpg")
  
  //Title
  align(center)[
    #v(20pt)
    #text(14pt, weight: 200, "INSTITUT FÜR DUALE STUDIENGÄNGE") \
    #v(20pt)
    #emph(text(16pt, weight: 600, "Praxistransferprojekt im Studiengang "+studiengang))
    #v(25pt)
    #text(2em, weight: 700, title)
  ]

  // Author information.
  text(
    12pt,
    font: "Calibri",
  pad(
    top: 5em,
    grid(
      columns: (auto, 1fr),
      rows: (60pt, 30pt),
      gutter: 1em,
      
      "Eingereicht von:",
      ..authors.map(author => [
        #author.name \
        geb.: #author.birthday in #author.birthplace \
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
  ))

  // Abstract page.
  set page(numbering: "I", number-align: center)
  v(1fr)
  align(center)[
    #heading(
      outlined: false,
      numbering: none,
      text(0.85em, smallcaps[Abstract]),
    )
  ]
  v(12pt)
  abstract
  v(2fr)
  counter(page).update(1)


  ///////////////////
  // Verzeichnisse //
  ///////////////////

  set page(margin: auto, header: none)
  set block(above: 3em, below: 2em)

  // Table of contents
  show outline.entry.where(level: 1): it => {
      strong(it)
  }
  outline(depth: 4 ,indent: true, title: [Inhaltsverzeichnis])

  //Abbildungsverzeichnis, falls eine Abbildung existiert 
  locate(loc => {
    let figures = query(selector(figure.where(kind: image)).after(loc), loc)
    if figures.len() > 0 {
    heading(outlined: true, numbering: none,[Abbildungsverzeichnis])
    outline(
          title: none,
    target: figure.where(kind: image),
    )
  }})

  //Tabellenverzeichnis, falls mindestens eine Tabelle existiert 
  locate(loc => {
    let figures = query(selector(figure.where(kind: table)).after(loc), loc)
    if figures.len() > 0 {
    heading(outlined: true, numbering: none,[Tabellenverzeichnis])
    outline(
          title: none,
    target: figure.where(kind: table),
    )
  }})

  //Abkürzungsverzeichnis, falls mindestens eine Abkürzung existiert
  if acronyms.len() > 0 {
      print-index(title: "Abkürzungsverzeichnis", sorted: "up", delimiter: "", numbering: none, outlined: true)
  }

  //Symbolverzeichnis, falls mindestens ein Symbol existiert
  if (symbols.len() > 0){    
    heading(outlined: true, numbering: none)[Symbolverzeichnis]
    set block(above: 3em, below: 14pt)
    let sym-list = symbols.keys()
    for sym in sym-list{
      table(
        columns: (20%,80%),
        stroke:none,
        inset: 0pt,
        [*#symbols.at(sym)*\ ], [#sym]
      )
    }
  }

  // Main body.
  set block(above: 1.5em, below: 2em) //heading space
  set par(justify: true)
  set page(numbering: "1", number-align: center, margin: (top: 120pt, bottom: 80pt),header: getHeader(authors.at(0).name))
  counter(page).update(1)

  //main body (main.typ)
  body

  //End

  // Continue roman numbering for the appendix.
  set page(numbering: "I", number-align: center, margin: auto, header: none)
  locate(loc => {
  let AbsolutePageNumberOfFirstBodyPage = query(selector(heading.where(numbering: "1.1")).before(loc), loc).first().location().page()
  counter(page).update(AbsolutePageNumberOfFirstBodyPage - 1)
  })

  // Bibliography
  bibliography(title: [Literaturverzeichnis], style: "ieee","../sources.bib")

  if appendix.fields().len() > 0 {
  renderAppendix(appendix)
  }
  
  pagebreak()
  eidesstattliche_erklaerung(title)
  }