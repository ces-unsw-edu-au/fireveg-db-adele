# Morrison 1995

**Citation:** Morrison, D. A., Cary, G. J., Pengelly, S. M., Ross, D. G., Mullins, B. J., Thomas, C. R. and Anderson, T. S. (1995). Effects of fire frequency on plant species composition of sandstone communities in the Sydney region: Inter-fire interval and time-since-fire. *Australian Journal of Ecology* **20**, 239–247.

**PDF:** `Effects of fire frequency on plant species composition of sandstone.pdf`

**Reference string:** `Morrison 1995`

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

## surv1 — Resprouting - full canopy scorch

**Status:** skip

**Source column:** `Regeneration strategy`

**Value mapping**

| Raw value | norm_value |
|---|---|
| Fs (fire sensitive) | None |
| Ft (fire tolerant) | ??? |

**Notes:** Table 2 lists 19 species with a "Regeneration strategy" column coded Fs (fire sensitive, >50% of plants usually killed by fire) or Ft (fire tolerant, <50% killed). This is a community-level binary classification, not a per-individual resprouting proportion under full canopy scorch. The Ft category does not distinguish between resprouting mechanisms or map cleanly to surv1 vocabulary (All/Most/Few/None). Ft means fewer than half are killed, which could be Most or All — this is ambiguous without per-species detail. Skip unless this binary can be accepted as a proxy.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | No per-species organ of resprouting recorded |
| surv5 | No per-species longevity data |
| surv6 | No seedbank half-life experiments |
| surv7 | No seed viability data |
| germ1 | No per-species seedbank type assigned |
| germ8 | No per-species dormancy mechanism data |
| grow1 | No age-to-organ data per species |
| rect2 | No per-species recruitment pattern data; study did not sample seedlings |
| repr2 | No per-species post-fire flowering data |
| repr3 | No age at first flowering from seed per species |
| repr3a | No time to first post-fire reproduction from resprouts per species |
| repr4 | No maturation age per species |
| disp1 | No per-species dispersal mode recorded |
