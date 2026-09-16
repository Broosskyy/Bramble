# V23.24 Visual Polish

Primary goal: make the prototype read more like a cohesive anime/chibi MMO world without
replacing the existing modular asset catalog.

Visual layers:
1. terrain / routes
2. production environment assets
3. animated water
4. atmospheric particles
5. entities / combat FX
6. player / remote player / NPC plates
7. screen-space tint / vignette
8. foreground depth foliage

Performance:
Ambient elements are deterministic and use small fixed counts rather than unbounded emitters.
