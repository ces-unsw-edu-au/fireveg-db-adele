# Purdie 1977

**Citation:** Purdie, R. W. (1977). Early stages of regeneration after burning in dry sclerophyll vegetation. I. Regeneration of the understorey by vegetative means. *Australian Journal of Botany* **25**, 21–34. AND Purdie, R. W. (1977). Early stages of regeneration after burning in dry sclerophyll vegetation. II. Regeneration by seed germination. *Australian Journal of Botany* **25**, 35–46.

**PDF:** `Early stages of regeneration after burning in dry sclerophyll vegetation I.pdf` and `Early Stages of Regeneration after Burning in Dry Sclerophyll Vegetation. II Regeneration by Seed Germination.pdf`

**Reference string:** `Purdie 1977`

**Records in database:**

| Trait | n |
|---|---|
| surv1 | 67 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Regrowth class` (Appendix 1, Part I)

**Value mapping**

| Raw value | norm_value |
|---|---|
| FSD (fire-sensitive decreaser) | None |
| NGD (fire-resistant non-geophytic decreaser) | Most |
| GD (fire-resistant geophytic decreaser) | All |
| NGI (fire-resistant non-geophytic increaser) | Most |
| GI (fire-resistant geophytic increaser) | All |
| T (therophyte) | None |


**Notes:** Appendix 1 of Part I assigns a regrowth class to each species across three sites. FSD = 100% mortality (None). T (therophyte) = annuals absent from pre-burn vegetation, regenerate from soil seed only (None as plants). Fire-resistant classes (NGD, GD, NGI, GI) all produce vegetative regrowth; the decreaser/increaser distinction reflects population trajectory, not individual survival rate. Non-geophytes (NGD, NGI) mapped to Most — rootstock-based shrubs with moderate to high but not always complete survival at high fire intensities (830–4200 kW/m). Geophytes (GD, GI) mapped to All — underground bulbs and rhizomes are very well protected. Requires expert validation before approving.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** `Regrowth class` (Appendix 1, Part I) combined with text descriptions

**Value mapping**

| Raw value | norm_value |
|---|---|
| NGD — rootstocks or root tussocks | Basal |
| GD — bulbs | Tuber |
| NGI — rootstocks and suckers from lateral roots | Long rhizome or root sucker |
| GI — rhizomes | Long rhizome or root sucker |

**Notes:** Part I text defines the regrowth classes by organ type. NGD = rootstocks/root tussocks (Basal). GD = geophytic decreasers sprouting from bulbs (Tuber — vocabulary explicitly includes bulbs: "non-woody nodular subsoil organs (bulbs, corms, tubers, taproots)"). NGI = rootstocks and suckers from lateral roots (Long rhizome or root sucker). GI = rhizomes (Long rhizome or root sucker). FSD = obligate seeders, no vegetative recovery (None). Eucalyptus trees resprout epicormically/lignotubers but are not assigned a class in Appendix 1. Per-species organ can be read directly from the regrowth class in Appendix 1.

**Multi-value:** Each species is assigned a single regrowth class, so most species will have one organ. However if any species is noted in text as having multiple organs, use the multi-value pivot pattern (see PIPELINE.md step 6).

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## rect2 — Establishment pattern

**Status:** approved

**Source column:** `Regrowth class` + seedling presence in burnt vs. unburnt plots (Appendix 1b, Part I; Tables 2–4, Part II)

**Value mapping**

| Raw value | norm_value |
|---|---|
| FSD — seedlings present in burnt plots, absent/rare in unburnt | Intolerant |
| NGD — seedlings present in both burnt and unburnt | Tolerant |
| NGI — seedlings present in both burnt and unburnt | Tolerant |


**Notes:** Part II Table 3 provides per-species seedling counts in burnt (B) and unburnt (UB) plots for common shrub species. FSD species (Acacia genistifolia, Dillwynia retorta) show very high germination in burnt plots and very low in unburnt, indicating post-fire enhanced or post-fire only establishment. Fire-resistant decreasers and increasers show seedlings in both burnt and unburnt plots. However, the study covers only 2 years and the classification into recruitment pattern requires inference beyond the data directly reported. The data are sufficient to distinguish post-fire enhanced from continuous for several species with per-species counts, but the mapping to rect2 vocabulary categories requires expert judgement.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ8 — Seed dormancy type

**Status:** approved

**Source column:** text discussion (Part II)

**Notes:** Part II discusses that leguminous species (Acacia genistifolia, Dillwynia retorta, Daviesia mimosoides, Pultenaea procumbens) show increased germination in burnt plots attributed to heat softening of hard seed testas — this indicates physical dormancy. Several non-leguminous species (Brachyloma daphnoides, Haloragis tetragyna, Stylidium graminifolium) also showed increased germination from soil samples after burning, possibly due to direct heat stimulation, but the mechanism is not confirmed as physical dormancy. This information is discussed at the group/functional level and for named species in the text, but no systematic per-species dormancy table is provided. Extractable qualitatively for a subset of species but not from a table.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Acacia genistifolia | PY |
| Dillwynia retorta | PY |
| Daviesia mimosoides | PY |
| Pultenaea procumbens | PY |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species maximum longevity data; Pimelea linifolia noted as naturally short-lived but no years given |
| surv6 | No seedbank half-life experiments |
| surv7 | No seed viability duration data per species |
| germ1 | No per-species seedbank type classification; eucalypt seed noted as not stored in soil (transient/canopy) but not systematically assigned across species |
| grow1 | No per-species age at which regenerative organ develops |
| repr2 | No per-species post-fire flowering response classified |
| repr3 | No age at first flowering from seed per species |
| repr3a | Time to first post-fire flowering noted qualitatively (some species flower in 1st growing season after burning) but not in years per species |
| repr4 | No maturation age per species |
| disp1 | No per-species dispersal mode recorded |
