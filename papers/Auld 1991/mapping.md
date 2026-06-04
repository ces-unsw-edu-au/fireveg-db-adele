# Auld 1991

**Citation:** Auld, T. D. and O'Connell, M. A. (1991). Predicting patterns of post-fire germination in 35 eastern Australian Fabaceae. *Australian Journal of Ecology* **16**, 53–70.

**PDF:** `Predicting patterns of post‐fire germination in 35 eastern Australian Fabaceae - Auld 1991.pdf`

**Reference string:** `Auld 1991`

**Records in database:**

| Trait | n |
|---|---|
| surv1 | 27 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting (full canopy scorch)

**Status:** approved

**Source column:** `Probable fire response`

**Value mapping**

| Raw value | norm_value |
|---|---|
| FS | None |
| R | All |
| FS;R? | Few |
| R? | Few |
| FS? | ??? |
| FS;R | Most |

> Note: Table 1 lists "Probable fire response" for all 35 species. FS = fire sensitive (obligate seeder), R = resprouter. Several species carry uncertainty markers (?) or dual classifications (FS;R, FS;R?). The R script already extracts only R species as `All`. Species with FS;R or FS;R? could be `Few` or `Most` but there is insufficient information in the paper to determine which. Species with FS? or R? are uncertain. The paper notes that most of the remaining (non-R) species are probably all killed by fire of most intensities (D. Keith, pers. comm.).

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ8 — Seed dormancy type

**Status:** approved

**Source column:** `Probable fire response` / species family

> Note: All 35 study species are Fabaceae. The paper explicitly states that dormancy in these species is physical (hard seed coat, impermeable to water), broken by heat during fires. This is described as the general mechanism throughout the paper (e.g. "breaking of the seed coat-caused dormancy", reference to Cavanagh 1980 on strophiole rupture). Physical dormancy applies to all 35 species uniformly. No value mapping table is needed for a categorical trait where all species share the same value.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Fabaceae / hard seed coat | PY |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ type not recorded per species; paper focuses on seed germination not vegetative recovery |
| surv5 | Plant longevity not covered |
| surv6 | Seedbank half-life not covered; paper reports germination percentages under experimental heating, not half-life |
| surv7 | Seed viability duration not covered as per-species trait; paper reports germination response to temperature treatments, not longevity in storage or field |
| germ1 | Seedbank type not classified per species; the paper notes all species have soil-stored seeds but does not classify canopy vs soil-persistent vs transient per species |
| grow1 | Age at development of regenerative organs not covered |
| rect2 | Establishment pattern not classified per species; paper predicts germination levels under two fire intensities but does not classify post-fire vs continuous recruitment patterns |
| repr2 | Post-fire flowering response not covered |
| repr3 | Age at first flowering not covered |
| repr3a | Time to first post-fire reproduction from resprouts not covered |
| repr4 | Maturation age not covered |
| disp1 | Dispersal mode not covered |
