# Clarke Knox 2002

**Citation:** Clarke, P.J. & Knox, K.J.E. (2002) Post-fire response of shrubs in the tablelands of eastern Australia: do existing models explain habitat differences? *Australian Journal of Botany* **50**, 53–62.

**CSV:** `clarke_2002.csv`

**Reference string:** `Clarke Knox 2002`

**Records in database:**

| Trait | n |
|---|---|
| germ1 | 1 |
| surv1 | 187 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting (full canopy scorch)

**Status:** skip

**Source column:** `Fire response`

**Value mapping**

| Raw value | norm_value |
|---|---|
| Resprouts | All |
| Resprouts* | All |
| Resprout | All |
| Obligate seeder | None |
| Obligate seeder* | None |
| Resprouts/variable | ??? |
| Variable | ??? |
| Obligate seeder/variable | ??? |
| Obligate seeder (75%) | ??? |
| Structure | ??? |

> Note: `*` values are inferred from morphology or sister taxa, not directly observed.
> `Resprout` (row 197) appears to be a typo of `Resprouts`.
> `Structure` appears only for *Kunzea obovata* — unclear what this means in context.
> `Obligate seeder (75%)` appears for *Acacia macnuttiana* and *Podolobium arborescens* — 75% killed implies ~25% survive, suggesting `Few`.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Acacia filicifolia | Few |
| Leucopogon microphyllus var. pilibundus | Few |
| Rhytidosporum procumbens | Few |
| Correa reflexa (green perianth) | Most |
| Daviesia latifolia | Most |
| Micromyrtus sessilis | Most |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ type not recorded per species |
| surv5, surv6, surv7 | Not covered |
| germ1 | Canopy vs soil seedbank not distinguished per species in the appendix (only aggregate totals in Table 1) |
| germ8 | Not covered |
| grow1 | Not covered |
| rect2 | Seedlings column (Y/N/S) records only immediate post-fire recruitment presence — insufficient for full establishment pattern classification through the fire cycle |
| repr2, repr3, repr3a, repr4 | Not covered |
| disp1 | Not covered |
