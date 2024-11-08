#let eidesstattliche_erklaerung(title, ort, abgabedatum ,authors) = {[
    #set par(justify: true, first-line-indent: 0pt)
    #v(8em)
    #heading(outlined: false, numbering: none, [Eidesstattliche Erklärung])
    #if authors.len() == 1 {
        text("Ich erkläre an Eides statt, dass ich meine Hausarbeit")
    } else {
        text("Wir erklären an Eides statt, dass wir unsere Ausarbeitung")
    }

    #v(12pt)
    #align(center, text(13pt, weight: 700, title))
    #v(12pt)
    #if authors.len() == 1 {
        text(
            [selbstständig und ohne fremde Hilfe angefertigt habe und dass ich alle von anderen Autoren
    wörtlich übernommenen Stellen wie auch die sich an die Gedankengänge anderer Autoren
    eng anlehnenden Ausführungen meiner Arbeit besonders gekennzeichnet und die Quellen
    zitiert habe. ]
    )
       
    } else {
        text(
        [selbstständig und ohne fremde Hilfe angefertigt haben und dass wir alle von anderen Autoren
        wörtlich übernommenen Stellen wie auch die sich an die Gedankengänge anderer Autoren
        eng anlehnenden Ausführungen unserer Arbeit besonders gekennzeichnet und die Quellen
        zitiert haben.
        ]
        )
    }
    


    #v(40pt)
    #for a in authors {
        align(center, grid(
        columns: (1fr,1fr),
        rows: (0pt, 0pt),
        gutter: (8pt),
        align(bottom, ort + ", " + abgabedatum),
        if a.sign !="" {
            align(bottom, image("../images/signs/" + a.sign , height: 15pt))
        }else{
           align(bottom, a.name) 
        },
        
        overline(extent: 30pt,offset: -10pt,[Ort, Datum]),
        overline(extent: 30pt,offset: -10pt,[Unterschrift]),
        ))
        v(3em)
    }
]}