# Purdie Slatyer 1976

**Citation:** Purdie, R. W. and Slatyer, R. O. (1976). Vegetation succession after fire in sclerophyll woodland communities in south-eastern Australia. *Australian Journal of Ecology* **1**, 223–236.

**PDF:** `Vegetation succession after fire in sclerophyll woodland.pdf`

**Reference string:** `Purdie Slatyer 1976`

**Records in database:**

| Trait | n |
|---|---|
| disp1 | 30 |
| repr3 | 14 |
| repr3a | 32 |
| surv1 | 165 |
| surv5 | 2 |
| surv7 | 1 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** `Class` (Table 3 — Mode of regeneration of species after burning)

**Value mapping**

| Raw value | norm_value |
|---|---|
| Obligate seed regenerators — Fire-sensitive decreasers | None |
| Facultative root resprouters — Fire-resistant decreasers | All |
| Facultative root resprouters — Fire-resistant increasers | All |
| Obligate root resprouters — Fire-resistant decreasers | All |
| Obligate root resprouters — Fire-resistant increasers | All |
| Therophytes | None |

**Notes:** Table 3 assigns every species in the study to one of three regeneration classes (Obligate seed regenerators = OSR; Facultative root resprouters = FRS; Obligate root resprouters = ORS) and sub-classes. OSR fire-sensitive decreasers had all adult plants killed (None). Therophytes were absent from the pre-burn vegetation and regenerated only from seed (None). FRS species can survive fire vegetatively and regenerate from seed. ORS species resprout obligately. These map approximately to surv1 but the proportion surviving (All/Most/Few) is not given per species — only whether they are capable of surviving. The study sites experienced fire intensities of 827–4205 kW/m; not all burns caused full canopy scorch. Mapping ??? values requires expert judgement on whether capability = All or Most.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** `Class` (Table 3 — same column as surv1)

**Value mapping**

| Raw value | norm_value |
|---|---|
| Facultative root resprouters — Fire-resistant decreasers | Long rhizome or root sucker |
| Facultative root resprouters — Fire-resistant increasers | Long rhizome or root sucker |
| Obligate root resprouters — Fire-resistant decreasers | Tuber |
| Obligate root resprouters — Fire-resistant increasers | Long rhizome or root sucker |
| Therophytes | None |

**Notes:** Organ type follows from the class biology, not a separate Table 3 column. FRS species resprout from lateral roots (Long rhizome or root sucker). ORS Fire-resistant decreasers are the geophytic decreasers — orchids and other species with perennating bulbs/corms (Tuber). ORS Fire-resistant increasers are the rhizomatous monocots (Dianella, Lomandra, Caladenia etc.) that spread laterally (Long rhizome or root sucker). OSR and therophytes have no vegetative recovery (None). Eucalyptus tree species (E. macrorhyncha, E. rossii, E. mannifera subsp. maculosa, E. dives) appear in FRS-decreasers and show V=1 vegetative regrowth, but the paper does not specify the organ type (epicormic, lignotuber, basal) — surv4 is not extractable for these species from this source. Exocarpos cupressiformis (FRS increaser via lateral root suckers) is covered by the class mapping.

** Eucs in this study are noted to resprout from Epicormic and/or Ligno, have left as not clear which organ for which species **

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|


---

## rect2 — Establishment pattern

**Status:** skip

**Source column:** `Class` (Table 3) combined with text

**Value mapping**

| Raw value | norm_value |
|---|---|
| Obligate seed regenerators — Fire-sensitive decreasers | Intolerant-Tolerant |
| Therophytes | Intolerant |
| Facultative root resprouters — Fire-resistant decreasers | Tolerant |
| Facultative root resprouters — Fire-resistant increasers | Tolerant |
| Obligate root resprouters | ??? |

**Notes:** OSR fire-sensitive decreasers rely entirely on seed for population continuity after fire and showed very high germination in burnt plots; establishment is enhanced by fire. Therophytes were absent from pre-burn vegetation and regenerated only from seeds in the soil/ash — effectively post-fire only or post-fire enhanced. FRS species showed seedlings in both burnt and unburnt plots across the 2-year study. ORS obligate root resprouters (geophytic classes) showed absent or negligible seedling input. The study covers only 2 years post-fire so longer-term patterns (Episodic, Continuous) cannot be fully confirmed. Values require expert judgement before approving.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ8 — Seed dormancy type

**Status:** approved

**Source column:** text discussion

**Notes:** The paper discusses that fire stimulates germination of leguminous species (Acacia genistifolia, Dillwynia retorta, Daviesia mimosoides) via heat-softening of hard seed coats, indicating physical dormancy. This is mentioned in the text discussion but is not presented as a systematic per-species table. Only named for a subset of species.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Acacia genistifolia | PY |
| Dillwynia retorta | PY |
| Daviesia mimosoides | PY |

---

## disp1 — Propagule dispersal mode

**Status:** approved

**Source column:** dispersal symbols in species names in Table 3 (footnote: "Seed dispersed by wind (\*) or birds (+)")

**Notes:** Table 3 marks wind-dispersed species with \* and bird-dispersed species with + directly in the species name column. Coverage is partial — only marked species have an extractable disp1 value from this paper; unmarked species are not assigned. All \* species are Asteraceae or similar with pappus = wind-hairs. The + species (Exocarpos cupressiformis) has a fleshy receptacle ingested by birds = animal-ingestion.

**Value mapping**

| Raw value | norm_value |
|---|---|
| \* (wind-dispersed) | wind-hairs |
| + (bird-dispersed) | animal-ingestion |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Cirsium semidecandrum | wind-hairs |
| Gnaphalium involucratum | wind-hairs |
| Hypochoeris glabra | wind-hairs |
| Lactuca serriola | wind-hairs |
| Senecio quadridentatus | wind-hairs |
| Sonchus asper | wind-hairs |
| Chondrilla juncea | wind-hairs |
| Helichrysum collinum | wind-hairs |
| Hypochoeris radicata | wind-hairs |
| Helichrysum calycina | wind-hairs |
| Exocarpos cupressiformis | animal-ingestion |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv5 | No per-species maximum longevity data; Pimelea linifolia noted as short-lived but no years given |
| surv6 | No seedbank half-life experiments |
| surv7 | No seed viability duration data per species |
| germ1 | No per-species seedbank type assigned systematically; eucalypt seed noted as not stored in soil but not formally classified |
| grow1 | No per-species age at which regenerative organ develops |
| repr2 | No per-species post-fire flowering classification; maturation of regrowth discussed qualitatively by group |
| repr3 | No age at first flowering from seed per species in years |
| repr3a | Some species noted to flower in first growing season after burning (Table 3 footnote: growing season of first flowering given as V=1, S=1 or 2) but not expressed as years per species in a usable numerical form |
| repr4 | No maturation age per species in years |
