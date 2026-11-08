// Renders a cover letter from the YAML file passed with `--input letter=<path>`,
// under the resume's letterhead and in its body style. The file has these
// fields; `body` paragraphs can contain "[text](url)" links.
//
//   company: Example Co      # names the PDF; not printed
//   date: "2026-11-05"
//   salutation: Dear Example Co hiring team,
//   body:
//     - >-
//       First paragraph.
//   closing: Sincerely,

#import "style.typ": blank, letterhead, linked, style

#let b = yaml("/data/resume.yaml").basics + yaml("/data/contact.yaml").basics
#let l = yaml(sys.inputs.letter)

#set document(title: b.name + " Cover Letter", author: b.name, date: none)
#show: style.with(b.name)

// "2026-11-05" -> "November 5, 2026".
#let long-date(s) = {
  let (year, month, day) = s.split("-").map(int)
  datetime(year: year, month: month, day: day).display("[month repr:long] [day padding:none], [year]")
}

#letterhead(b)
#blank
#blank
#long-date(l.date)
#blank
#l.salutation
#blank
#for p in l.body {
  linked(p)
  blank
}
#l.closing
#blank
#b.name
