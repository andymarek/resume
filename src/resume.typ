// Renders data/resume.yaml (JSON Resume schema) in the layout of the original
// Word resume. Measurements in comments are the Word style values they mirror.

#import "style.typ": blank, face, letterhead, linked, style

#let r = yaml("/data/resume.yaml")
#let b = r.basics + yaml("/data/contact.yaml").basics

#set document(title: b.name + " Resume", author: b.name, date: none)
#show: style.with(b.name)

// "Job Stats w/ Space": 6pt before, 4pt after, 0.3" indent; the organization is
// centered on the text column and the location is right-aligned at the margin.
#let entry-line(dates, org, loc) = {
  v(6pt, weak: true)
  set text(..face("Georgia"))
  grid(
    columns: (1fr, auto, 1fr),
    pad(left: 0.3in, dates), org, align(right, loc),
  )
  v(4pt)
}

// "Position": Georgia Bold 9pt, 3pt before, 4pt after, 0.3" indent.
#let position(title) = {
  v(3pt)
  pad(left: 0.3in, text(..face("Georgia"), size: 9pt, weight: "bold", title))
  v(4pt)
}

// Symbol bullet at 0.35", text at 0.5", under an entry's 0.3" heading lines.
// Not nested under one, both shift left by that 0.3". The bullet keeps
// Tahoma's line edges, which are in em, so it doesn't change the line height.
// A string item goes through `linked`; content is set as is.
#let bullets(items, nested: true) = for item in items {
  grid(
    columns: (if nested { 0.35in } else { 0.05in }, 0.15in, 1fr),
    [], text(font: "Symbol", "•"), if type(item) == str { linked(item) } else { item },
  )
}

#let section(title) = text(..face("Georgia"), size: 11pt, weight: "bold", tracking: -0.5pt, title)

// A section title above an entry's heading lines. The heading lines get their
// own block, so the weak space that opens `entry-line` is dropped at the start
// of that block, as it is when no title precedes it.
#let titled(title, heading) = section(title) + block(heading)

// "2026-03" -> "3/2026"; a bare year passes through unchanged.
#let date(s) = {
  let parts = s.split("-")
  if parts.len() == 1 { s } else { str(int(parts.at(1))) + "/" + parts.at(0) }
}
#let span(e) = date(e.startDate) + " – " + if "endDate" in e { date(e.endDate) } else { "present" }

// Name, contact, summary
#letterhead(b)
#blank
#b.summary
#blank

// An entry's heading lines stay on the same page as its first bullet. A section
// title goes in the first entry's heading, so it never ends a page alone.
#let entry(heading, highlights, nested: true) = {
  let n = calc.min(1, highlights.len())
  block(breakable: false, heading + bullets(highlights.slice(0, n), nested: nested))
  bullets(highlights.slice(n), nested: nested)
}

#for (i, job) in r.work.enumerate() {
  let heading = entry-line(span(job), job.name, job.location) + position(job.position)
  entry(if i == 0 { titled("Work Experience", heading) } else { heading }, job.at("highlights", default: ()))
  blank
}

// The degree, major, and minor in the "Position" style; the honor in `score` is
// italic and right-aligned at the margin under the location.
#for (i, school) in r.education.enumerate() {
  let degree = school.studyType + ", " + school.area
  if "minor" in school { degree += "; Minor in " + school.minor }
  let honor = text(weight: "regular", emph(school.at("score", default: "")))
  let heading = (
    entry-line(span(school), school.institution, school.location)
      + position(grid(
        columns: (1fr, auto),
        degree, honor,
      ))
  )
  block(breakable: false, if i == 0 { titled("Education", heading) } else { heading })
}
#blank

// Each skill is its bold category followed by its keywords, strongest first.
#entry(
  section[Technical Skills],
  r.skills.map(s => strong(s.name + ":") + " " + s.keywords.join(", ")),
  nested: false,
)
