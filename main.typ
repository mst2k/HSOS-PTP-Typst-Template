#import "templates/template.typ": *
#import "templates/acronyms.typ": *


//Hier werden die Abkürzungen definiert. Die Abkürzungen werden automatisch in ein Verzeichniss geschrieben und können im Text 
//mit #acr("Abkürzung") bzw #acrpl("Abkürzung")referenziert werden.
#let acronyms = (
  //"Abkürzung": ("Vollständige Bezeichnung", "Plural")
  "PTP": ("Praxistransferprojekt", "Praxistransferprojekte"),
)

//Die Symbole die genutzt werden, werden hier definiert. Später wird aus dieser Liste auch automatisch ein Verzeichniss erstellt.
//Falls keine Symbole verwendet werden, kann diese Variable leer gelassen werden. Dadurch wird dann auch kein Verzeichniss erstellt.
//Die Symbole können im Text mit #symbols.Symbolname referenziert werden.
#let symbols = (
  //"Beschreibung": "Symbol"
  "Gesamtkostenfunktion": ($K(x)$),
)

//Der Anhang wird automatisch generiert, wenn die Variable appendix gesetzt ist.
//Die einzelnen Anhänge werden mit == Überschrift definiert.
#let appendix = [
    == Erster  Anhang Appendix <anhang1>
    test test 
    #image("images/logos/HS-OS-Logo-Standard-rgb.jpg", width: 80%)
    #pagebreak()

    == Zweiter Anhang  <anhang2>
      Derzeit wird noch kein PDF Embedding unterstützt. Um PDFs einzubinden, müssen diese als Bild eingebunden werden (z.B. PDF2SVG).
    ]

//Das Abstract wird automatisch generiert, wenn die Variable abstract gesetzt ist.
#let abstract = [
  //Hier das Abstract schreiben
  #lorem(200)
]

#show: project.with(
  title: "Beispieltitel",
  authors: (
    (name: "Max Mustermann", 
    birthday: "01.01.2000", 
    birthplace: "Lingen (Ems)", 
    address: "Musterstraße 12b, 49811 Lingen(Ems)",
    matrikelnummer: "103923",
    studiengruppe: "22-DWF-1"),
  ),
  betreuer: "Prof. Name Nachname",
  modul: "Modulbezeichnung",
  abgabedatum: datetime.today().display("[day].[month].[year]"),
  language: "de",
  studiengang: "Wirtschaftsinformatik",
  abstract: abstract,
  acronyms: acronyms,
  symbols: symbols,
  appendix: appendix,
)
#init-acronyms(acronyms)

////////////////////////////////////////////////
//Hauptteil - Hier wird der Inhalt geschrieben//
////////////////////////////////////////////////

= Einführung <einführung>
#lorem(200)

TEST
== Anlass und Problemhintergrund
#lorem(200)

TESTdfsdfsfd
== Zielsetzung
#lorem(100)
= Theoretische Grundlagen
#lorem(200)
= Andwendung auf die Praxis
#lorem(200)
= Kritische Reflexion
#lorem(200)
= Fazit/Schlussbetrachtung
#lorem(200)

////////////////////////////////////////////////////////////////////////
//Diverse Snippets zur Hilfe, alles nachstehende kann gelöscht werden!//
////////////////////////////////////////////////////////////////////////

= HILFEN (ENTFERNEN)
Verschiedene Snippets zur Hilfe!

== Quellen
Referenziert wird mit \@ - Quelle: @Vertrau.mir.Bruder[120 ff.]
Wie bereits in @einführung beschrieben

== Bilder
#figure(
  image("images/logos/HS-OS-Logo-Standard-rgb.jpg", width: 80%),
  caption: [Logo der Hochschule.],
) <HS-logo>

@HS-logo zeigt das Logo der Hochschule

== Acronyms
Abkürzungen werden nur bei der ersten Verwendung voll ausgeschrieben: #acr("PTP"). Bei der zweiten Verwendung nur die Kurzform: #acr("PTP"). Der Plural ist auch möglich: #acrpl("PTP")

== Code Snippet
  ```go
  package main

  import "fmt"

  func main() {
      fmt.Println("Some Code!");
  }
  ```

== Mathe
Mathematische Ausdrücke werden zwischen Dollarzeichen (\$) geschrieben.
$ 1/2 < /2(x+1) $ <coolefunktion>
Und können @coolefunktion referenziert werden!

Wir nutzen #symbols.Gesamtkostenfunktion um eine Symbol darzustellen.

== Tabellen

#figure(
  table(
    columns: (1fr, 1fr),
    inset: 10pt,
    align: horizon,
    [*Deutsch*],
    [*Englisch*],
    [Boot],
    [boat],
    [Haus],
    [house]),
    caption: [Übersetzungen],
)



