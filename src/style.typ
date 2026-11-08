// Styles shared by the resume and the cover letter, from the original Word
// resume. Measurements in comments are the Word style values they mirror.

// Word sizes a "single" line from the font's OS/2 usWinAscent and
// usWinDescent; Typst's "ascender" edge reads the typo metrics instead, which
// for Tahoma is 20% shorter. These are the win values over units per em.
#let win-metrics = (
  "Tahoma": (2049, 423),
  "Georgia": (1878, 449),
)
#let face(name) = {
  let (ascent, descent) = win-metrics.at(name)
  (font: name, top-edge: ascent / 2048 * 1em, bottom-edge: -descent / 2048 * 1em)
}

// The page, text, and typography rules, applied with `#show: style.with(name)`.
// `name` goes in the header from page 2 on.
#let style(name, doc) = {
  // US Letter; 1" sides, 0.8" top and bottom; header 0.4" from the top edge.
  set page(
    paper: "us-letter",
    margin: (x: 1in, y: 0.8in),
    header-ascent: 0.4in - 12pt,
    header: context if here().page() > 1 {
      set text(..face("Georgia"), size: 12pt)
      [#name #h(1fr) Page #counter(page).display()]
    },
  )

  // Word also adds a paragraph's space before to the previous one's space after
  // rather than taking the larger, so all vertical space is placed with v().
  set text(..face("Tahoma"), size: 10pt)
  set par(leading: 0pt, spacing: 0pt)
  set block(spacing: 0pt)

  // YAML strings are not parsed as markup, so restore its typography: "--" and
  // "---" become en and em dashes, and straight quotes become curly ones. A
  // leading apostrophe before a decade ('90s) is always a closing quote.
  show regex("---?"): it => if it.text.len() == 3 { sym.dash.em } else { sym.dash.en }
  show "\"": smartquote(double: true)
  show "'": smartquote(double: false)
  show regex("'\d0s"): it => "’" + it.text.slice(1)

  doc
}

// An empty paragraph in the current font, which Word uses as a spacer.
#let blank = block(hide[X])

// "[text](url)" in a YAML string becomes an underlined link; the rest stays
// plain text, so no other Markdown or Typst markup is interpreted.
#let linked(s) = {
  let out = []
  let i = 0
  for m in s.matches(regex("\[([^\]]+)\]\(([^)]+)\)")) {
    out += s.slice(i, m.start) + link(m.captures.at(1), underline(m.captures.at(0)))
    i = m.end
  }
  out + s.slice(i)
}

// A URL as an underlined link showing only the host and path.
#let web(url) = link(url, underline(url.replace(regex("^https?://(www\.)?"), "")))

// The name and contact lines that open both documents, from `basics` with the
// contact fields merged in. Each contact line prints only when its fields are
// present. The public repository's data/contact.yaml is empty, which leaves
// only the web line.
#let letterhead(b) = {
  align(center, text(..face("Georgia"), size: 26pt, weight: "bold", b.name))
  v(4pt)
  let contact = (
    if "location" in b { (b.location.city, b.location.region, b.location.postalCode).join(", ") },
    ("phone", "email").filter(k => k in b).map(k => b.at(k)).join("  •  "),
    (b.url, ..b.profiles.map(p => p.url)).map(web).join("  •  "),
  ).filter(line => line != none)
  align(center, text(..face("Georgia"), contact.join(linebreak())))
}
