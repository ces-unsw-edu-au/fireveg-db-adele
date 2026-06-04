# Russell-Smith Ryan Klessa Waight Harwood 1998

**Citation:** Russell-Smith, J., Ryan, P.G., Klessa, D., Waight, G. and Harwood, R. (1998). Fire regimes, fire-sensitive vegetation and fire management of the sandstone Arnhem Plateau, monsoonal northern Australia. *Journal of Applied Ecology*, 35, 829–846.

**PDF:** `Fire regimes, fire‐sensitive vegetation and fire management of the sandstone Arnhem Plateau, monsoonal northern Australia.pdf`

**Reference string:** `Russell-Smith Ryan Klessa Waight Harwood 1998`

**Records in database:**

| Trait | n |
|---|---|
| repr3 | 1 |
| surv1 | 11 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** Appendix (columns: Vegetative resprouters / Obligate seeders, for Rain forest Trees, Rain forest Shrubs, Woodland/heath Trees, Woodland/heath Shrubs)

**Notes:** The Appendix provides a per-species classification into "Vegetative resprouters" or "Obligate seeders" for all trees (>8 m) and shrubs recorded in the study. This is the most directly extractable trait. Vegetative resprouters map to `All` (or `Most` — the paper notes these species regenerate by coppice/basal resprout, or clonal/rhizomatous means). Obligate seeders map to `None`. The Appendix covers well over 100 species. The key to regeneration capacity in the Appendix header: co = coppice/basal resprout; cl = clonal/rhizomatous; os = obligate seeder.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Vegetative resprouter (co, cl) | All |
| Obligate seeder (os) | None |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** skip

**Source column:** Appendix (footnote codes per species: co = coppice/basal resprout; cl = clonal/rhizomatous also)

**Notes:** The Appendix codes each vegetative resprouter as co (coppice/basal resprout = lignotuber or Basal) or cl (clonal/rhizomatous). This maps directly to surv4 vocabulary. However, many species in the Appendix carry both codes (e.g., "cl" and "co" not mutually exclusive), and the exact organ is not always distinguishable (lignotuber vs Basal vs rhizome). Mapping is approximate. Only extractable for the resprouter species.

**Multi-value:** Species carrying both co and cl codes must produce two records (one per organ). Use the multi-value pivot pattern (see PIPELINE.md step 6).

**Value mapping**

| Raw value | norm_value |
|---|---|
| co (coppice/basal resprout only) | Basal |
| cl (clonal/rhizomatous also) | Long rhizome or root sucker |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr3 — Age at first flower production from seed

**Status:** approved

**Source column:** Appendix (key: 1 = seed within 1 year following fire; 2 = seed within 2 years; 3 = seed within 3 years; 4 = not within 3 years; 5 = not within 5 years; no observations coded as blank or qualified)

**Notes:** The Appendix provides a numeric key (1–5) indicating time to reproductive maturity (seed production) following fire for obligate seeder species. This approximates repr3 (age at first flower/seed from seed) for obligate seeders. Values are ordinal ranges (within 1 yr, within 2 yr, within 3 yr, not within 3 yr, not within 5 yr) rather than exact years. The paper text also notes (Fig. 4) that most obligate seeders are reproductive by year 3, but some tall Acacia and serotinous *Regelia punicea* take 5+ years. Only applicable to obligate seeder species in the Appendix. Superscript numbers on Appendix species names carry this coding.

**Source units:** ordinal class (years-to-seed post-fire); convert midpoints: 1 = 1 yr, 2 = 2 yr, 3 = 3 yr, 4 = 4 yr (proxy for "not within 3"), 5 = 5+ yr

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species maximum lifespan data |
| surv6 | No seedbank half-life data; soil seedbank studies mentioned as reported elsewhere (J. Russell-Smith, unpublished) |
| surv7 | No seed longevity data |
| germ1 | No per-species seedbank type classification |
| germ8 | No seed dormancy data |
| grow1 | No data on age to develop regenerative organs |
| rect2 | Recruitment pattern not classified per species; only resprouter vs obligate seeder distinction |
| repr2 | No post-fire flowering response data (enhanced/suppressed) for resprouting species |
| repr3a | No time-to-first-reproduction-from-resprout data |
| repr4 | Maturation age (repr4) overlaps with repr3 here; the Appendix data reflect time to seed post-fire for obligate seeders only, already captured under repr3 |
| disp1 | No dispersal mode data |
