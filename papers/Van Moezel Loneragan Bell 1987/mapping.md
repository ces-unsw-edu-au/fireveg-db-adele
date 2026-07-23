# Van Moezel Loneragan Bell 1987

**Citation:** van der Moezel, P.G., Loneragan, W.A. and Bell, D.T. (1987). Northern Sandplain Kwongan: regeneration following fire, juvenile period and flowering phenology. *Journal of the Royal Society of Western Australia*, 69(4): 123–132.

**PDF:** `Northern Sandplain Kwongan regeneration following fire, juvenile period and flowering phenology.pdf`

**Reference string:** `Van Moezel Loneragan Bell 1987`

**Records in database:**

| Trait | n |
|---|---|
| repr3 | 1 |
| repr3a | 1 |
| surv1 | 8 | 

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Fire Response` (Appendix 1)

**Notes:** Appendix 1 provides a per-species fire response classification for 192 species observed at recently burnt sites. Obligate seeders were identified by a single erect stem post-fire; resprouters by multi-stemmed regrowth. Geophytes were classed as sprouters (regenerate from underground storage organs). The classification is binary at species level: Sprout, Seed, or Both (15 species; recorded as "Sprout & Seed" or "Seed & Sprout" in the Appendix). For obligate resprouter species ("Sprout" only) → surv1 = All. For "Sprout & Seed" / "Seed & Sprout" species: the presence of seed recruitment post-fire is at least consistent with some adults being killed; without per-species survival percentages we cannot confirm All, so surv1 = Most (conservative). Species with no Fire Response entry cannot be coded. Table 1 confirms 126 Sprouters, 51 Seeders, 15 Both of 192 categorised species.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Sprout | All |
| Seed | None |
| Sprout & Seed | Most |
| Seed & Sprout | Most |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr3 — Age at first flower production from seed

**Status:** approved

**Source column:** `Juvenile Period` (Appendix 1) — **Seed and Seed & Sprout species only**

**Notes:** The Juvenile Period column records years post-fire to first observed flowering at study sites. Sites of 1- and 3-years-since-fire were unavailable, so most values are upper bounds or ranges: `<2` = within 2 years; `<4>2` = seen flowering in a 4-year-old site but not a 2-year-old site (i.e. first flowers within 3–4 years — text, p. 125); `<5>2` = within 3–5 years; `<5` or `<6` = upper-bound years. Values are mapped to their upper bound. Some Juvenile Period values carry annotation superscripts (e.g. `<2¹`) — strip the superscript for repr3; the superscript is used separately for repr2. Only Seed and Seed & Sprout species are included for repr3. Species with a blank Juvenile Period column cannot be coded.

**Source units:** years; ranges stored as `lower-upper` (e.g. `2-4`) where both bounds are known; upper-bound-only values stored as `<N` (e.g. `<5`)

`raw_value` records both columns — `Juvenile Period, {value}; Fire Response, {value}` — because the Fire Response class is what determines whether a Juvenile Period becomes repr3 or repr3a.

**Combined classes.** Appendix 1 uses four Fire Response values: `Seed`, `Sprout`, `Seed & Sprout`, `Sprout & Seed`. Both orderings genuinely appear in the source (e.g. *Banksia attenuata* = `Sprout & Seed`, *Banksia sphaerocarpa* = `Seed & Sprout`) and the order is meaningful: the Appendix 1 header describes the column as the **most preferred** fire response mode, so the first-listed mode is the dominant one. Combined-class species are therefore routed on their first-listed mode — `Seed & Sprout` → repr3, `Sprout & Seed` → repr3a. 15 species carry a combined class (matching the "Both" column of the summary table); 9 of them have a Juvenile Period value.

**Evidence:** Appendix 1 header: "Annotated information where known includes edaphic preference, most preferred fire response mode, the juvenile period between fire and flower production". Discussion: "The common belief that plants regenerating from seed have a longer juvenile period than sprouting species was unfounded in these results" — the paper treats the juvenile period of sprouting species as a sprouter measure, confirming that for `Sprout` species the recorded flowering is from resprouts.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 1 | 1 |
| 2 | 2 |
| <2 | <2 |
| ≤2 | <2 |
| <4>2 | 2-4 |
| ≤4>2 | 2-4 |
| <5>2 | 2-5 |
| ≤5>2 | 2-5 |
| <4 | <4 |
| ≤4 | <4 |
| <5 | <5 |
| ≤5 | <5 |
| <6 | <6 |
| ≤6 | <6 |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr3a — Time to first postfire reproduction from resprouts

**Status:** approved

**Source column:** `Juvenile Period` (Appendix 1) — **Sprout and Sprout & Seed species only**

**Notes:** Same Juvenile Period column as repr3 (see notes above for value interpretation). For Sprout and Sprout & Seed species, this represents time from fire to first post-fire flowering from resprouts. Same banding and range-format approach applies. Species with a blank Juvenile Period column cannot be coded.

**Source units:** years; ranges stored as `lower-upper` (e.g. `2-4`) where both bounds are known; upper-bound-only values stored as `<N` (e.g. `<5`)

`raw_value` records both columns — `Juvenile Period, {value}; Fire Response, {value}` — so that the Sprout / Sprout & Seed evidence for routing the value to repr3a rather than repr3 is visible on the record.

**Value mapping** (same as repr3)

| Raw value | norm_value |
|---|---|
| 1 | 1 |
| 2 | 2 |
| <2 | <2 |
| ≤2 | <2 |
| <4>2 | 2-4 |
| ≤4>2 | 2-4 |
| <5>2 | 2-5 |
| ≤5>2 | 2-5 |
| <4 | <4 |
| ≤4 | <4 |
| <5 | <5 |
| ≤5 | <5 |
| <6 | <6 |
| ≤6 | <6 |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## repr2 — Post-fire flowering response

**Status:** approved

**Source column:** Annotation superscripts on Juvenile Period values in Appendix 1

**Notes:** Appendix 1 uses annotation codes to flag species with fire-enhanced flowering. Two annotation codes are relevant to repr2:
- Superscript ¹ = "Flowering mainly restricted to period 1 or 2 years following fire"
- Superscript ² = "Flowering restricted to period 2-4 years after fire"

Both indicate post-fire flowering enhancement. The text states "there was no evidence that any species ceased flowering once a site reached maturity" — annotated species continue to flower in older stands but at reduced intensity. This is consistent with Facultative. The text explicitly names *Verticordia grandis*, *Stirlingia latifolia*, *Anigozanthos humilis*, and *Pimelea sulphurea* as having fire-stimulated flowering success; all carry annotation ¹ or ² in the Appendix.

Annotation ³ ("Flowers earlier in season in 2–4 year old sites") reflects a phenological shift only (earlier blooming in recently burnt stands), not enhanced flowering magnitude — not used for repr2. Named ³ species: *Hypocalymma xanthopetalum*, *Hovea stricta*.

Species without annotation ¹ or ² are not coded for repr2 (absence does not imply Negligible).

This is an exceptions-only extraction. The species exceptions table below lists species confidently identified from the PDF; the full list should be verified and completed during CSV transcription of Appendix 1. In the CSV, capture the annotation code separately from the Juvenile Period base value.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Annotation ¹ on Juvenile Period value | Facultative |
| Annotation ² on Juvenile Period value | Facultative |

**Species-level exceptions** (verify and complete during CSV transcription)

| Species | norm_value |
|---|---|
| Anigozanthos humilis | Facultative |
| Calectasia cyanea | Facultative |
| Dasypogon bromeliifolius | Facultative |
| Kingia australis | Facultative |
| Xanthorrhoea reflexa | Facultative |
| Verticordia grandis | Facultative |
| Stirlingia latifolia | Facultative |
| Eremaea beaufortioides | Facultative |
| Isotropis cuneifolius | Facultative |
| Pimelea sulphurea | Facultative |
| Stylidium piliferum | Facultative |

---

## germ1 — Seedbank type

**Status:** approved

**Source column:** Results and Discussion text (p. 124)

**Notes:** The paper distinguishes two seed storage strategies for obligate seeders by name:
1. **Bradysporous habit** (seeds retained in woody fruits or cones until fire opens them) = canopy-stored seed → Canopy. Named examples: *Hakea obliqua*, *Eremaea fimbriata*, *Beaufortia elegans*.
2. **Hard seeds** stored in the soil; fire breaks the seed coat → Soil-persistent. Named examples: *Acacia pulchella*, *Kennedia prostrata* (Ewart 1908 cited; "seeds remain viable and dormant for long periods in the soil").

No systematic per-species germ1 column exists — only these five species are named in the text. Exceptions-only extraction; status approved for these named species only.

**Species-level exceptions**

| Species | norm_value |
|---|---|
| Hakea obliqua | Canopy |
| Eremaea fimbriata | Canopy |
| Beaufortia elegans | Canopy |
| Acacia pulchella | Soil-persistent |
| Kennedia prostrata | Soil-persistent |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Paper does not specify regenerative organ type per species; geophytes are classed as sprouters but exact organ (tuber, rhizome, etc.) is not recorded in the Appendix |
| surv5 | No per-species maximum lifespan data |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data; "hard seeds remain viable in the soil for many years" (p. 124) is qualitative, no species-specific values |
| grow1 | No per-species age to develop regenerative organs |
| rect2 | Not classified per species; only the resprouter vs obligate seeder distinction is recorded, which does not directly map to establishment pattern |
| repr4 | Juvenile period (repr3) and reproductive maturity age are the same concept in this paper; no separate maturation data |
| disp1 | No per-species dispersal mode data |
