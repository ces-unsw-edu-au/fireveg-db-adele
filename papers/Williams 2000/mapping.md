# Williams 2000

**Citation:** Williams, P.R. (2000). Fire-stimulated rainforest seedling recruitment and vegetative regeneration in a densely grassed wet sclerophyll forest of north-eastern Australia. *Australian Journal of Botany*, 48: 651–658.

**PDF:** `Fire-stimulated rainforest seedling recruitment and vegetative regeneration in a densely grassed wet sclerophyll forest of north-eastern Australia.pdf`

**Reference string:** `Williams 2000`

**Records in database:**

| Trait | n |
|---|---|
| rect2 | 4 |
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

**Source column:** `Percentage resprouting` (Table 2)

Table 2 gives percentage of individuals resprouting after the November 1996 fire (Sites 1 and 2) and after the December 1997 fire (Sites 3, 4 and 5), per species. The 1997 fire was a moderate intensity fire (scorch height 14.6 m, intensity 890 kW/m). Some species had 0% resprouting and recruited only from seed post-fire. Values are percentages of pre-fire individuals surviving, not a categorical classification.

**Value mapping**

| Raw value | norm_value |
|---|---|
| 0-5% (0%) | None |
| >5–30% | Few |
| >30–70% | Half |
| >70–90% | Most |
| >90% | All |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** text and Table 2 (vegetative regeneration mode)

The paper describes the regenerative mode for each species in Table 2 and the text. Sclerophyll species resprout epicormically; rainforest pioneers resprout from basal stem and roots (subterranean). Root suckering is documented for *Alstonia muelleriana*, *Banksia aquilonia* and *Duboisia myoporoides*. However, the paper does not provide a clean per-species organ column — it describes modes in narrative and Table 2 footnotes. The data is partially extractable but would require careful per-species reading of the text and footnotes.

**Multi-value:** If a species has more than one organ recorded (e.g. both epicormic and Basal), use the multi-value pivot pattern (see PIPELINE.md step 6) to produce one record per organ.

**Value mapping**

| Raw value | norm_value |
|---|---|
| epicormic (sclerophyll trees >2 m) | Epicormic |
| basal stem and root resprouting (rainforest pioneers) | Basal |
| root suckering | Long rhizome or root sucker |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Alstonia muelleriana | Long rhizome or root sucker |
| Banksia aquilonia | Long rhizome or root sucker |
| Duboisia myoporoides | Long rhizome or root sucker |
| Acacia flavescens | Basal |
| Allocasuarina torulosa | Basal |
| Alphitonia excelsa | Basal |
| Eucalyptus intermedia | Epicormic |
| Eucalyptus tereticornis | Epicormic |
| Eucalyptus torelliana | Epicormic |
| Callicarpa pendunculata | Basal |
| Commersonia bertramia | Basal |
| Glochidion sp. | Basal |
| Melastoma affine | Basal |
| Rhodomyrtus trineura | Basal |

---

## rect2 — Establishment pattern

**Status:** approved

**Source column:** text and Tables 2–3 (seedling recruitment timing)

The paper documents a pulse of seedling recruitment in the immediate post-fire period (first 1–2 years), with limited recruitment after longer intervals between fires. This is documented for both sclerophyll and rainforest pioneer species. However, this is a community-level finding not systematically coded per species. Table 3 provides mean seedling densities per block per species across survey dates, from which a post-fire recruitment pulse pattern can be inferred for species with non-zero post-fire seedling counts and near-zero unburnt counts. This is partially extractable per species but requires interpretation.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Seedlings only in recently burnt blocks, absent or rare in unburnt | Intolerant |
| Seedlings in both burnt and unburnt | Tolerant |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ8 — Seed dormancy type

**Status:** approved

**Source column:** Table 4 (heated vs unheated soil seedbank germination)

Table 4 provides seedbank germination data from heated (85°C, 45 min) and unheated soil for two blocks. Species showing significantly higher germination in heated soil have physical dormancy (heat-cracked seed coat). The ANOVA results identify species with sig-nificant heat treatment effects.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Significantly higher germination in heated soil (P<0.05) | PY |

**Note:** Species where heat *reduces* germination (Melastoma affine, Poaceae spp.) and species with inconsistent direction across blocks (Rhodomyrtus trineura) are excluded from records. This experiment only tests for PY; reduced or null heat response does not confirm any other dormancy class. See TRAIT_LOGIC.md for discussion.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Acacia cincinnata | PY |
| Alphitonia petrei | PY |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species lifespan data |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data |
| germ1 | Seedbank data available (Table 4) but paper does not classify species by seedbank type (canopy/soil-persistent/transient/none); the germinable seedbank is sampled but not typed per species |
| grow1 | No per-species age at regenerative organ development |
| repr2 | Post-fire flowering response not measured |
| repr3 | Age at first flower production from seed not measured |
| repr3a | Time to first post-fire reproduction from resprouts not measured |
| repr4 | Maturation age not measured |
| disp1 | No per-species dispersal mode data |
