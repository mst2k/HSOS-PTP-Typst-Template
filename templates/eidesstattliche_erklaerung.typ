#let eidesstattliche_erklaerung(title) = {[
    #set par(justify: true, first-line-indent: 0pt)
    #v(8em)
    #heading(outlined: false, numbering: none, [Eidesstattliche Erklärung])
    Ich erkläre an Eides statt, dass ich meine Hausarbeit
    #v(12pt)
    #align(center, text(13pt, weight: 700, title))
    #v(12pt)
    selbstständig und ohne fremde Hilfe angefertigt habe und dass ich alle von anderen Autoren
    wörtlich übernommenen Stellen wie auch die sich an die Gedankengänge anderer Autoren
    eng anlehnenden Ausführungen meiner Arbeit besonders gekennzeichnet und die Quellen
    zitiert habe.


    #v(40pt)
    #align(center, grid(
        columns: (1fr,1fr),
        rows: (0pt, 0pt),
        gutter: (8pt),
        align(bottom, datetime.today().display("Lingen, [day].[month].[year]")),
        align(bottom, image("../images/unterschrift.png", height: 15pt)),
        overline(extent: 20pt,offset: -10pt,[Ort, Datum]),
        overline(extent: 20pt,offset: -10pt,[Unterschrift]),
    ))
]}