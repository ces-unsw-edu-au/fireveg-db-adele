# Morrison Renwick 2000

**Citation:** Morrison, D. A. and Renwick, J. A. (2000). Effects of variation in fire intensity on regeneration of co-occurring species of small trees in the Sydney region. *Australian Journal of Botany* **48**, 71–79.

**PDF:** `Effects of variation in fire intensity on regeneration of co-occurring species of small trees in the Sydney region.pdf`

**Reference string:** `Morrison Renwick 2000`

**Records in database:**

| Trait | n |
|---|---|
| grow1 | 1 |
| surv1 | 9 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Stem survival (%) — High-intensity` (Table 2)

**Value mapping**

| Raw value | norm_value |
|---|---|
| 0.0 | None |
| >0 and ≤30 | Few |
| >30 and ≤70 | Half |
| >70 and ≤90 | Most |
| >90 | All |

**Notes:** The high-intensity wildfire caused 100% leaf-scorch (scorch height 10–15 m), making it the best proxy for full canopy scorch. Per-species stem survival percentages under 100% leaf-scorch are given in Table 2 for 9 species. Hakea sericea had 0% survival at both intensities (obligate seeder). The three Acacia species and Casuarina littoralis had 0% survival under the high-intensity fire despite partial survival under low-intensity fire. Only Casuarina torulosa, Leptospermum trinervium and Persoonia linearis had stems survive the high-intensity fire (~20–27%). Jacksonia scoparia had 0% high-intensity survival but ~38% low-intensity survival.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** `Stem basal buds` / `Root buds` / `Stem aerial buds` (Table 1)

**Value mapping**

| Raw value | norm_value |
|---|---|
| epicormic | Epicormic |
| stem base | Basal |
| lignotuber | Lignotuber |
| suckers | Long rhizome or root sucker |

**Notes:** Table 1 lists presence/absence of stem aerial buds (epicormic), stem basal buds, and root buds for each of the 9 species. This gives per-species regenerative organ data. Species with no buds listed (Acacia binervia, Acacia parramattensis, Hakea sericea) are fire-sensitive obligate seeders with no vegetative recovery organ. Jacksonia scoparia has only stem base buds and root buds (suckers). Some species have multiple organs.

**Multi-value:** Table 1 has a separate column per organ type — the R script must use the multi-value pivot pattern (see PIPELINE.md step 6), not a single case_when. Each organ present for a species produces its own record.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ1 — Seedbank type

**Status:** approved

**Source column:** qualitative description in text

**Notes:** Hakea sericea is described as having a serotinous canopy-stored seedbank (seeds protected by thin walls of woody fruits, released after fire; no seedlings established after prescribed fire). This is mentioned only for Hakea sericea; no systematic per-species seedbank classification table is provided. Acacia species are described as relying on seed germination for continuation but no seedbank type is assigned. Not enough per-species data for systematic extraction across all 9 species.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Hakea sericea | Canopy |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species longevity data |
| surv6 | No seedbank half-life experiments |
| surv7 | No seed viability data |
| germ8 | No per-species dormancy mechanism data |
| grow1 | No age-to-organ data; minimum stem size for fire tolerance is given in cm circumference, not years |
| rect2 | No per-species recruitment pattern classification; some seedling observations noted qualitatively only |
| repr2 | No per-species post-fire flowering data |
| repr3 | No age at first flowering from seed per species |
| repr3a | No time to first post-fire reproduction from resprouts per species |
| repr4 | No maturation age per species |
| disp1 | No per-species dispersal mode recorded |
