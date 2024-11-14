// Acrostiche package for Typst
// Author: Grizzly (Updated version)

#let acros = state("acronyms", none)

#let init-acronyms(acronyms) = {
  acros.update(acronyms)
}

#let reset-acronym(term) = {
  // Reset a specific acronym. It will be expanded on next use.
  state("acronym-state-" + term, false).update(false)
}

#let reset-all-acronyms() = {
  // Reset all acronyms. They will all be expanded on the next use.
  context {
    let current-acronyms = acros.get()
    if current-acronyms != none {
      for acr in current-acronyms.keys() {
        state("acronym-state-" + acr, false).update(false)
      }
    }
  }
}

#let display-def(plural: false, acr) = {
  context {
    let current-acronyms = acros.get()
    if current-acronyms == none {
      panic("Acronyms not initialized. Call init-acronyms(dict) first.")
    }

    if acr not in current-acronyms {
      panic(acr + " is not a key in the acronyms dictionary.")
    }

    let defs = current-acronyms.at(acr)
    
    if type(defs) == "string" {
      // If user forgot the trailing comma the type is string
      if plural { defs + "s" } else { defs }
    } else if type(defs) == "array" {
      if defs.len() == 0 {
        panic("No definitions found for acronym " + acr + ". Make sure it is defined in the dictionary passed to #init-acronyms(dict)")
      }
      
      if plural {
        if defs.len() == 1 {
          defs.at(0) + "s"
        } else {
          defs.at(1)
        }
      } else {
        defs.at(0)
      }
    } else {
      panic("Definitions should be arrays of one or two strings. Definition of " + acr + " is: " + type(defs))
    }
  }
}

#let acr(acr) = {
  // Display an acronym in the singular form. Expands it if used for the first time.
  let state-key = "acronym-state-" + acr
  let seen-state = state(state-key, false)
  
  context {
    let seen = seen-state.get()
    if seen {
      acr
    } else {
      [#display-def(plural: false, acr) (#acr)]
    }
  }
  
  seen-state.update(true)
}

#let acrpl(acr) = {
  // Display an acronym in the plural form. Expands it if used for the first time.
  let state-key = "acronym-state-" + acr
  let seen-state = state(state-key, false)
  
  context {
    let seen = seen-state.get()
    if seen {
      acr + "s"
    } else {
      [#display-def(plural: true, acr) (#acr\s)]
    }
  }
  
  seen-state.update(true)
}

#let print-index(
  level: 1,
  outlined: false,
  sorted: "",
  title: "Acronyms Index",
  delimiter: ":",
  numbering: none
) = {
  // Print an index of all the acronyms and their definitions.
  // Args:
  //   level: level of the heading. Default to 1.
  //   outlined: make the index section outlined. Default to false
  //   sorted: define if and how to sort the acronyms: "up" for alphabetical order,
  //          "down" for reverse alphabetical order, "" for no sort (print in the
  //          order they are defined). If anything else, sort as "up". Default to ""
  //   title: set the title of the heading. Default to "Acronyms Index".
  //          Passing an empty string will result in removing the heading.
  //   delimiter: String to place after the acronym in the list. Defaults to ":"
  //   numbering: decide numbering of the header

  assert(
    sorted in ("", "up", "down"),
    message: "Sorted must be a string either \"\", \"up\" or \"down\""
  )

  if title != "" {
    heading(level: level, outlined: outlined, numbering: numbering)[#title]
  }

  context {
    let current-acronyms = acros.get()
    if current-acronyms == none { return }

    // Build and sort acronym list
    let acr-list = current-acronyms.keys()
    if sorted != "" {
      acr-list = acr-list.sorted()
      if sorted == "down" {
        acr-list = acr-list.rev()
      }
    }

    set block(above: 0em, below: 14pt)

    // Print the acronyms
    for acr in acr-list {
      table(
        columns: (20%, 80%),
        stroke:none,
        inset: 0pt,
        [*#acr#delimiter*],
        [#current-acronyms.at(acr).at(0)\ ]
      )
    }
  }
}