# Myerscough Clarke Skelton 1995

**Citation:** Myerscough, P. J., Clarke, P. J. and Skelton, N. J. (1995). Plant coexistence in coastal heaths: Floristic patterns and species attributes. *Australian Journal of Ecology* **20**, 482–493.

**PDF:** `Plant coexistence in coastal heaths  Floristic patterns and.pdf`

**Reference string:** `Myerscough Clarke Skelton 1995`

**Records in database:**

| Trait | n |
|---|---|
| rect2 | 4 |
| surv1 | 116 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Fire regeneration syndrome` category number (Appendix II)

**Notes:** Species are classified into nine fire-response categories following Gill and Bradstock (1992). Categories 1–3 and 8 = mature plants die under 100% leaf scorch (obligate seeders, surv1 = None). Categories 4–7 and 9 = mature plants survive 100% canopy scorch (resprouters, surv1 = All). Category 8 = die, no further data; category 9 = survive, no further data.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 1 (die, canopy-stored seed) | None |
| 2 (die, soil-stored seed) | None |
| 3 (die, no propagules remain) | None |
| 4 (survive, root suckers or rhizomes) | All |
| 5 (survive, basal stem buds/lignotubers) | All |
| 6 (survive, epicormic shoots) | All |
| 7 (survive, unharmed terminal aerial buds) | All |
| 8 (die, no further data) | None |
| 9 (survive, no further data) | All |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** `Fire regeneration syndrome` category number (Appendix II)

**Notes:** Organ type is directly encoded in the category. Category 4 = root suckers or rhizomes; Category 5 = basal stem buds such as those in lignotubers (mapped to Basal as the broader category — may include true lignotubers for some species, flag for expert review); Category 6 = epicormic shoots; Category 7 = unharmed terminal aerial buds (Apical). Categories 1/2/3/8 = die, no vegetative recovery (None). Category 9 = survive but organ type unspecified (???).

**Multi-value:** If any species is noted in text as having multiple organs, use the multi-value pivot pattern (see PIPELINE.md step 6).

**Value mapping**

| Raw value | norm_value |
|---|---|
| 1 (die, canopy seed) | None |
| 2 (die, soil seed) | None |
| 3 (die, no propagules) | None |
| 4 (root suckers or rhizomes) | Long rhizome or root sucker |
| 5 (basal stem buds/lignotubers) | Basal |
| 6 (epicormic shoots) | Epicormic |
| 7 (unharmed terminal aerial buds) | Apical |
| 8 (die, no further data) | None |
| 9 (survive, no further data) | ??? |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ1 — Seedbank type

**Status:** approved

**Source column:** `Fire regeneration syndrome` category number (Appendix II)

**Notes:** Seedbank type is encoded for obligate seeder categories only. Category 1 = canopy-stored seed (Canopy). Category 2 = soil-stored seed — type not specified further; Non-canopy is the appropriate vocabulary value (uncertain but not canopy type). Category 3 = no propagules remain after fire (Transient — seeds do not persist). Categories 4–9 (resprouters) do not encode seedbank type and are not extractable for germ1 from this paper.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 1 (canopy-stored seed) | Canopy |
| 2 (soil-stored seed) | Soil-persistent |
| 3 (no propagules remain) | Transient |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species longevity data |
| surv6 | No seedbank half-life experiments |
| surv7 | No seed viability data |
| germ8 | No per-species dormancy mechanism data |
| grow1 | No age-to-organ data per species |
| rect2 | No per-species recruitment pattern data |
| repr2 | No per-species post-fire flowering data |
| repr3 | No age at first flowering from seed per species |
| repr3a | No time to first post-fire reproduction from resprouts per species |
| repr4 | No maturation age per species |
| disp1 | No per-species dispersal mode recorded |
