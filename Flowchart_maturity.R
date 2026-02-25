library(DiagrammeR)
library(DiagrammeRsvg)
library(rsvg)

# Steg 1 – Sparar diagrammet som objekt
diagram <- grViz("
digraph SMSF {

  graph [layout = dot, rankdir = TB, fontname = 'Helvetica', bgcolor = '#FAFAFA', nodesep = 0.5, ranksep = 0.6]

  node [shape = diamond, style = filled, fillcolor = '#D6EAF8', fontname = 'Helvetica', fontsize = 11, width = 3.5, height = 1.0]
  F0 [label = 'Fråga 0\nGår könet att bedöma?\n(Trådlika gonader – absolut omöjligt\natt avgöra kön?)']
  F1 [label = 'Fråga 1\nFinns fri rom eller mjölke?\n(Rinner spontant eller vid mycket lätt tryck)']
  F2 [label = 'Fråga 2\nÄr gonaderna stora och fyller\nnästan hela kroppshålan?']
  F3 [label = 'Fråga 3\nÄr gonaden fast och välfylld\noch ej slapp?\n(Mjölke pressas fram vid lätt tryck\nmen rinner ej spontant)']
  F4 [label = 'Fråga 4\nÄr gonaden tydligt sladdrig/\npåslik med tömd struktur?']
  F5 [label = 'Fråga 5\nÄr gonaden rynkbar/strierad\noch matt vinröd?']
  F6 [label = 'Fråga 6\nÄr gonaden under aktiv\ntillväxt (fast, slät, bygger\npå höjden)?']
  F7 [label = 'Fråga 7\nSyns oocyter makroskopiskt (hona) /\ntydlig vitnande testikel (hane)?\nOCH har gonaden utpräglad\ngonadform (4–15 mm bred)?']
  F8 [label = 'Fråga 8\nÄr gonaderna mycket små,\ntrådformiga och utan\nsynliga blodkärl?']
  F9 [label = 'Fråga 9\nFinns tecken på kraftig\natresi utan kommande lek?']

  node [shape = rectangle, style = filled, fillcolor = '#D5F5E3', fontname = 'Helvetica Bold', fontsize = 11, width = 3.2, height = 0.8]
  S32  [label = 'Ca/32\nActively Spawning']
  S31  [label = 'Cb/31\nSpawning Capable']
  S41a [label = 'Da/41\nRegressing']
  S41b [label = 'Da/41\nRegressing']
  S42  [label = 'Db/42\nRegenerating']
  S22  [label = 'Bb/22\nDeveloping – Functionally Mature']
  S21  [label = 'Ba/21\nDeveloping – First-time']
  S1   [label = 'A/1\nImmature']
  S5   [label = 'E/5\nOmitted Spawning']
  S6   [label = 'F/6\nAbnormal']

  node [shape = rectangle, style = filled, fillcolor = '#FADBD8', fontname = 'Helvetica Bold', fontsize = 11, width = 3.2, height = 0.8]
  S99  [label = '99 / Kön = 0\nKön kan ej bestämmas']

  edge [fontname = 'Helvetica', fontsize = 10, color = '#555555']

  F0  -> S99  [label = 'Nej –\nkön ej möjligt att bedöma']
  F0  -> F1   [label = 'Ja –\nkön kan bedömas']
  F1  -> S32  [label = 'Ja']
  F1  -> F2   [label = 'Nej']
  F2  -> F3   [label = 'Ja']
  F2  -> F4   [label = 'Nej']
  F3  -> S31  [label = 'Ja']
  F3  -> S41a [label = 'Nej –\ndelvis tömd/slapp']
  F4  -> S41b [label = 'Ja']
  F4  -> F5   [label = 'Nej']
  F5  -> S42  [label = 'Ja']
  F5  -> F6   [label = 'Nej']
  F6  -> F7   [label = 'Ja']
  F6  -> F8   [label = 'Nej']
  F7  -> S22  [label = 'Ja']
  F7  -> S21  [label = 'Nej']
  F8  -> S1   [label = 'Ja']
  F8  -> F9   [label = 'Nej']
  F9  -> S5   [label = 'Ja –\nkraftig atresi']
  F9  -> S6   [label = 'Avvikande struktur/\nmissbildning']
}
")

print(diagram)

# Steg 2 – exportera till .pdf
svg_code <- export_svg(diagram)
writeLines(svg_code, "C:/Users/gacn0003/Downloads/R_Code/smsf_flowchart.svg")

rsvg::rsvg_pdf(
  charToRaw(svg_code),
  "C:/Users/gacn0003/Downloads/R_Code/smsf_flowchart.pdf"
)