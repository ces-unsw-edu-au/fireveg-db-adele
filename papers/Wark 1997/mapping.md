# Wark 1997

**Citation:** Wark, M.C. (1997). Regeneration of some forest and gully communities in the Angahook–Lorne State Park (north-eastern Otway Ranges) 1–10 years after the wildfire of February 1983. *Proceedings of the Royal Society of Victoria*, 109(1): 7–36. ISSN 0035-9211.

**PDF:** `Regeneration of some forest and gully communities in the Angahook-Lorne State Park.pdf`

**Reference string:** `Wark 1997`

**Records in database:**

| Trait | n |
|---|---|
| repr2 | 3 |
| repr3 | 54 |
| repr3a | 74 |
| surv1 | 160 |
| surv4 | 31 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Regeneration strategy` (Table 5)

**Notes:** Table 5 gives a regeneration strategy code per species using the Purdie (1977a, 1977b) system: OSR = obligate seed regenerator (from seed or spores only); FRR = facultative regrowth regenerator (by regrowth, and from seed or propagules); ORR = obligate regrowth regenerator (by regrowth only). The fire was a high-intensity wildfire that crown-fired all overstory, making this comparable to full canopy scorch. ORR (obligate resprouters — only mechanism is vegetative) → surv1 = All. FRR (facultative — uses both regrowth and seed) → surv1 = Most: the presence of the seed strategy means not all individuals necessarily resprouted; without survival percentages we cannot confirm All.

**Value mapping**

| Raw value | norm_value |
|---|---|
| OSR | None |
| FRR | Most |
| ORR | All |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** `Regeneration strategy` (Table 5) — organ codes in the legend

**Notes:** Table 5 legend (p. 29) lists per-species organ codes alongside the regeneration strategy classification. Each FRR/ORR species carries one or more organ codes indicating how regrowth occurs. Multi-organ species (e.g. L1 and R1 both present) must produce two surv4 records. OSR species have no regrowth organ and are not coded for surv4. Codes and their meanings from the legend: L1 = regrowth from lignotubers year 1; T1 = tubers year 1; Tu = tuberoids year 1; C1 = corms year 1; R1 = rhizomes year 2; R2 = rhizomes year 3; RSt1 = rhizostolons year 1; Rsk1 = root suckers year 1; St1 = stem regrowth year 1.

**Value mapping**

| Raw value | norm_value |
|---|---|
| L1 | Lignotuber |
| T1 | Tuber |
| Tu | Tuber |
| C1 | Tuber |
| R1 | Short rhizome |
| R2 | Short rhizome |
| RSt1 | Stolon |
| Rsk1 | Long rhizome or root sucker |
| St1 | Basal |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr2 — Post-fire flowering response

**Status:** approved

**Source column:** Text (p. 15); `First flowering` (Table 5) — exceptions only

**Notes:** The text notes that two orchid species (*Caladenia menziesii* and *Prasophyllum odoratum*) which appear but rarely flower in normal years bloomed prolifically in the spring after the fire — a clear fire-stimulated flowering response. No systematic per-species classification of Exclusive/Facultative/Negligible is provided; the paper documents timing of first post-fire flowering only, not comparison to non-fire flowering rates. This is an exceptions-only extraction.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Appears rarely, prolifically post-fire | Facultative |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Caladenia menziesii | Facultative |
| Prasophyllum odoratum | Facultative |

---

## repr3 — Age at first flower production from seed

**Status:** approved

**Source column:** `First flowering` (Table 5, OSR species only)

**Notes:** Table 5 provides a first-flowering year code per species: F1 = first flowered year 1; F2 = first flowered year 2; F3 = first flowered year 3 (Table 5 legend, p. 29). For OSR (obligate seed regenerator) species, flowering post-fire is from seed, so these codes approximate age at first flowering from seed. F3 species flowered in the 3-year-old site; species with no code cannot be classified.

Only OSR species produce repr3 records. OSR is stated by the source — Table 5 is sectioned by regeneration strategy and the classification (following Purdie 1977a, 1977b) defines OSR as regenerating from seed or spores only — so there is no resprout cohort that could be the source of the flowering observation. FRR and ORR species go to repr3a instead; see that section for the reasoning.

`raw_value` records both columns — `First flowering, {code}; Regeneration strategy, {code}` — because the regeneration strategy is what determines whether a first-flowering code becomes repr3 or repr3a.

**Source units:** years

**Value mapping**

| Raw value | norm_value |
|---|---|
| F1 | 1 |
| F2 | 2 |
| F3 | 3 |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr3a — Time to first postfire reproduction from resprouts

**Status:** approved

**Source column:** `First flowering` (Table 5, FRR and ORR species only)

**Notes:** Same first-flowering year codes as repr3 (see above). For FRR and ORR species, post-fire flowering comes from resprouting stems, so these codes represent time from fire to first post-fire reproduction from resprouts. Same F1/F2/F3 mapping applies.

**ORR is stated by the source; FRR is an inference.** Table 5 is sectioned by regeneration strategy, and the ORR section is headed "Obligate regrowth regenerators (by regrowth only)" (p. 29). An ORR species has no post-fire seedling cohort, so a flowering individual is necessarily a resprout — repr3a is stated, not inferred.

FRR species regenerate both by regrowth and from seed, and the paper does not say which cohort the first-flowering observation came from. They are assigned to repr3a on the inference that only the resprout cohort can flower on the observed timescale: the FRR group includes all eucalypts, e.g. *Eucalyptus obliqua* coded `St1, L1 S1 F2` — regrowth from stems and lignotubers in year 1, germinated from seed in year 1, first flowered in year 2. A eucalypt seedling does not flower two years after germinating, so the F2 observation must be the resprouting cohort. Assigning FRR to repr3 would record "flowers from seed at 2 years" for a eucalypt, which is affirmatively wrong. Flagged for expert review in TRAIT_LOGIC.md.

**Evidence:** Table 5 legend (p. 29): "S1=germinated from seed year 1; … L1=regrowth from lignotubers year 1; St1=regrowth from stems year 1 … F1=first flowered year 1; F2=first flowered year 2; F3=first flowered year 3"; ORR section heading, p. 29: "Obligate regrowth regenerators (by regrowth only)".

`raw_value` records both columns — `First flowering, {code}; Regeneration strategy, {code}` — so that the FRR/ORR evidence for routing the value to repr3a rather than repr3 is visible on the record.

**Source units:** years

**Value mapping**

| Raw value | norm_value |
|---|---|
| F1 | 1 |
| F2 | 2 |
| F3 | 3 |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species lifespan data |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data; text mentions seed stored in soil for >30 years for some Acacia understorey but not as a systematic per-species table |
| germ1 | No per-species seedbank type; qualitative mention of persistent soil seedbank for some species only |
| germ8 | No per-species seed dormancy type |
| grow1 | No per-species age at regenerative organ development |
| rect2 | No per-species establishment pattern classification |
| repr4 | No maturation age distinct from first flowering |
| disp1 | No per-species dispersal mode data |
