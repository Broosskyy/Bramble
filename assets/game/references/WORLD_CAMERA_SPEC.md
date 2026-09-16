# BRAMBLE – Kamerarichtung und echte Weltgeometrie

Die zwei Landschaftsbilder sind Perspektivkonzepte, **keine navigierbaren Karten**.
BRAMBLE nutzt als Ziel eine eigenständige 2,5D-Welt: zusammenhängende Wege und
Plätze, Gebäude mit sichtbaren Seiten, Hochebenen mit Felsfronten, untere
Flussläufe, Treppen, Rampen und klare Portalübergänge. Bevorzugte mobile Ansicht:
orthografisch und schräg von oben, etwa 38° Absenkung. Hainweiler zeigt die
warme Dorfzone; Nebelbruch die nächtliche Schattenzone. In beiden muss dieselbe
Kameraneigung und derselbe Figurenmaßstab gelten.

Implementationsmodell: Boden-Grid als Weltkoordinaten (x,y), explizite
Höhenstufen h=0/1/2 (nicht nur flaches Hintergrundbild), Objekte mit Fußpunkt,
Kollision, belegter Bodenfläche und optionaler Dach-Ausblendung. Rampen und
Treppen verbinden Höhenstufen im Navigationsgraph. Zeichenreihenfolge folgt
projiziertem Boden-Fußpunkt und Höhenlage; überdeckende Bäume/Dächer werden
bei Bedarf halbtransparent. Kamera folgt der Figur weich und hält den nahen
Laufweg im Blick. Hoch-/Querformat ändern den sichtbaren Ausschnitt, nicht
Weltgeometrie oder Laufwege. Freie Rotation erfordert zusätzliche Rückseiten
der Gebäude und korrekt gedrehte Kollision; mit diesen 2D-Bauteilen ist zuerst
eine feste Ansicht vorgesehen. Positionen, Kollision und Navmesh sind noch
nicht umgesetzt. Die Plattformstücke sind Modell-Referenzen; ihre Anschluss-
kanten müssen für echte nahtlose Höhenmaps maßgenau überarbeitet werden.
