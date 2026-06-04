# Lunt 1995

**Citation:** Lunt, I. D. (1995). Seed longevity of six native forbs in a closed *Themeda triandra* grassland. *Australian Journal of Botany* **43**, 439–449.

**PDF:** `Seed Longevity of Six Native Forbs in a Closed Themeda triandra Grassland.pdf`

**Reference string:** `Lunt 1995`

**Records in database:**

| Trait | n |
|---|---|
| germ1 | 2 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv7 — Seed longevity

**Status:** skip

**Source column:** `% viability at 12 months` (Table 2, buried seeds)

> Note: Table 2 reports percentage of sown seeds that remained viable after 12 months, for both surface-sown and buried (3 cm depth) seeds. The experiment ran for 12 months. Seeds were recovered at 2, 4, 6, 9 and 12 months. For buried seeds: *Arthropodium strictum* 5%, *Bulbine bulbosa* 46%, *Burchardia umbellata* 0%, *Chrysocephalum apiculatum* 61%, *Craspedia variabilis* 8%, *Leptorhynchos squamatus* 36%. For surface seeds: *A. strictum* 16%, *B. bulbosa* 1%, *B. umbellata* 6%, *C. apiculatum* 36%, *C. variabilis* 2%, *L. squamatus* 1.5%. The experiment period was 12 months, so the data establish whether seeds survive to 1 year but do not give a half-life estimate. The paper concludes no species possessed a 'long-term persistent' seed bank (>5 years) under these conditions, and characterises most species as forming transient or short-term persistent banks at best. Seed longevity in years (as a numerical value) cannot be calculated precisely from these data as the experiment only ran to 12 months — the value for surv7 would be approximately 1 year or less for all species except *C. apiculatum* which showed the best persistence. Units: years.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ1 — Seedbank type

**Status:** approved

**Source column:** inference from viability data (Table 2) and Discussion

**Value mapping**

| Raw value | norm_value |
|---|---|
| Transient / short-term persistent (surface and buried seeds mostly lost within 12 months) | Transient |
| Greatest potential for soil seedbank (small seeds, inhibited germination under canopy, sustained buried viability) | Soil-persistent |

> Note: The paper does not provide an explicit per-species seedbank type classification in a table. The Discussion infers seedbank type from the experimental results: *Chrysocephalum apiculatum* is identified as having the greatest potential to accumulate a soil seedbank (small seed size, inhibition of germination under closed canopy, 61% buried viability at 12 months). The other five species are described as likely forming 'transient or short-term persistent' seed banks at best. These inferences are authorial conclusions from experimental data, not a direct table column classifying each species. Given this, germ1 is not directly extractable as a per-species classification from a source column — it requires interpretive mapping from the Discussion text.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Chrysocephalum apiculatum | Soil-persistent |
| Arthropodium strictum | Transient |
| Bulbine bulbosa | Transient |
| Burchardia umbellata | Transient |
| Craspedia variabilis | Transient |
| Leptorhynchos squamatus | Transient |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv1 | Fire response (resprouting vs seeding) not classified per species; paper is about seed bank dynamics, not post-fire adult survival |
| surv4 | Regenerative organ not covered |
| surv5 | Plant longevity not covered |
| surv6 | Seedbank half-life not covered; experiment ran only 12 months, insufficient to calculate half-life |
| germ8 | Seed dormancy type not covered as a per-species classification; the paper discusses dormancy-related germination behaviour qualitatively but does not assign dormancy type vocabulary per species |
| grow1 | Age at development of regenerative organs not covered |
| rect2 | Establishment pattern not covered; the paper examines seed persistence in grassland, not fire-related recruitment patterns |
| repr2 | Post-fire flowering response not covered |
| repr3 | Age at first flowering not covered |
| repr3a | Time to first post-fire reproduction from resprouts not covered |
| repr4 | Maturation age not covered |
| disp1 | Dispersal mode not covered |
