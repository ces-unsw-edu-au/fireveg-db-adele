# Kirkpatrick 1984

**Citation:** Kirkpatrick, J. B. and Dickinson, K. J. M. (1984). The impact of fire on Tasmanian alpine vegetation and soils. *Australian Journal of Botany* **32**, 613–629.

**PDF:** `The Impact of Fire on Tasmanian Alpine Vegetation and Soils.pdf`

**Reference string:** `Kirkpatrick 1984`

**Records in database:**

| Trait | n |
|---|---|
| surv1 | 24 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting (full canopy scorch)

**Status:** approved

**Source column:** `RC`

**Notes:** Table 1 assigns each taxon to one of five regeneration classes (RC) based on cover comparisons between recently burned (10–40 years post-fire) and adjacent long-unburned plots. Classes are defined in the Results section (p.619–620):
- RC 1: Most often absent from recently burned areas; adults readily killed by fire, seeds seldom survive. → `None`
- RC 2: Found in recently burned areas at much lower cover than unburned; regenerated from seed. Adults killed, seed-only recovery. → `None`
- RC 3: Recover vegetatively but fail to attain pre-fire cover. Adults resprout but not full recovery. → `Half`
- RC 4: Greater cover in recently burned than unburned areas; established from seed post-fire. Adults killed, fire-stimulated seedling recruitment. → `None`
- RC 5: Equal or greater cover in recently burned areas; recover vegetatively from fire.  → `All`

RC 3 is mapped to `Half` rather than `Most` or `All` because "fail to attain pre-fire cover" is consistent with partial individual-level recovery — i.e. not all individuals fully recover. This is a cover-based inference rather than a direct survival count.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 1 | None |
| 2 | None |
| 3 | Half |
| 4 | None |
| 5 | All |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

---

## rect2 — Establishment pattern

**Status:** approved

**Source column:** `RC`

**Notes:** The RC classes also encode seedling recruitment patterns relative to fire:
- RC 4: Greater cover in recently burned than unburned areas; species established from seed post-fire. Fire clearly stimulates seedling recruitment → `Intolerant`
- RC 5: Equal or greater cover in both burned and unburned; vegetative recovery dominant with some seed establishment after fire. Present in both conditions → `Tolerant`
- RC 1, 2, 3: Not cleanly classifiable. RC 1 species are absent from burned areas (can't establish post-fire); RC 2 recruit from seed post-fire but also have high cover in long-unburned areas; RC 3 are resprouters with unclear seedling recruitment pattern. Excluded from rect2.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 4 | Intolerant |
| 5 | Tolerant |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ type not recorded per species; paper notes vegetative recovery occurs but does not identify organ type (lignotuber, rhizome etc.) per species |
| surv5 | Plant longevity not covered |
| surv6 | Seedbank half-life not covered |
| surv7 | Seed longevity not covered |
| germ1 | Seedbank type not classified per species; paper discusses dispersal ability and post-fire seed survival in general terms but does not assign canopy/soil-persistent/transient per species |
| germ8 | Seed dormancy type not covered |
| grow1 | Age at development of regenerative organs not covered |
| repr2 | Post-fire flowering response not covered |
| repr3 | Age at first flowering not covered |
| repr3a | Time to first post-fire reproduction from resprouts not covered |
| repr4 | Maturation age not covered |
| disp1 | Dispersal mode mentioned qualitatively for a few species (e.g. bird-dispersed pines) but not recorded systematically per species |
