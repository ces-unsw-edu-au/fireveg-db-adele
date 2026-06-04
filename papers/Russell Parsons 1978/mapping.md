# Russell Parsons 1978

**Citation:** Russell, R.P. and Parsons, R.F. (1978). Effects of time since fire on heath floristics at Wilson's Promontory, Southern Australia. *Australian Journal of Botany*, 26, 53–61.

**PDF:** `Effects of time since fire on heath floristics at Wilson's Promontor.pdf`

**Reference string:** `Russell Parsons 1978`

**Records in database:**

| Trait | n |
|---|---|
| rect2 | 1 |
| surv1 | 20 |
| surv5 | 2 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** Text (p. 56) and Appendix 1

**Notes:** The paper states that of 22 woody species at site 5 (burnt October 1971), 16 re-established from rootstocks (resprouters), 4 established only from seed (obligate seeders: *Hakea sericea*, *Dillwynia glaberrima*, *D. sericea*, *Marianthus procumbens*), and 3 were uncertain (*Hakea teretifolia*, *Isopogon ceratophyllus*, *Pimelea humilis*). The broader text states 73% of shrub species can definitely regenerate from rootstocks. This constitutes per-species regeneration mode data for woody species at site 5, sufficient to extract surv1 (None = obligate seeders; All/Most = resprouters). However, the data come only from a single post-fire site and cover only 22 woody species, with several additional species listed in Appendix 1 with no regeneration mode indicated. The classification is inferrable for the named species only.

**Value mapping**

| Raw value | norm_value |
|---|---|
| re-established from rootstocks | All |
| establishing only from seeds after fire | None |
| status uncertain | Unknown |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Hakea sericea | None |
| Dillwynia glaberrima | None |
| Dillwynia sericea | None |
| Marianthus procumbens | None |
| Hakea teretifolia | Unknown |
| Isopogon ceratophyllus | Unknown |
| Pimelea humilis | Unknown |

---

## rect2 — Establishment pattern

**Status:** approved

**Source column:** Text (p. 56); species list by site (Appendix 1)

**Notes:** The paper identifies *Xanthosia pusilla* as a post-fire pioneer (found only in youngest two stands, described as forming dense seedling carpets immediately after fire). *Laxmannia sessiliflora* and *Acrotriche serrulata* are noted as restricted to the three youngest stands. Most other species are present across all age-since-fire classes with no clear post-fire-only pattern. However, classification is based on presence/absence across only 5 stands varying in age since fire, not direct observation of establishment events. Sufficient for a small number of species at minimum, but the evidence base is thin.

**Value mapping**

| Raw value | norm_value |
|---|---|
| found only in youngest stands, seedling carpets immediately post-fire | Intolerant |
| present across all stands | Tolerant |
| restricted to younger stands, possibly short-lived | ??? |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Xanthosia pusilla | Intolerant |
| Laxmannia sessiliflora | Intolerant |
| Acrotriche serrulate | Intolerant |
---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ not specified per species; only "rootstock" used as a general term |
| surv5 | No lifespan data per species |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data |
| germ1 | No per-species seedbank type classification |
| germ8 | No seed dormancy data |
| grow1 | No data on age to develop regenerative organs |
| repr2 | No post-fire flowering response data |
| repr3 | No age at first flower data |
| repr3a | No time to first post-fire reproduction data |
| repr4 | No maturation age data |
| disp1 | No dispersal mode data |
