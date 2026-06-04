# Williams Congdon Grice Clarke 2003

**Citation:** Williams, P.R., Congdon, R.A., Grice, A.C. and Clarke, P.J. (2003) Fire-related cues break seed dormancy of six legumes of tropical eucalypt savannas in north-eastern Australia. *Austral Ecology* 28, 507–514.

**PDF:** `Fire‐related cues break seed dormancy of six legumes of tropical eucalypt savannas in.pdf`

**Reference string:** `Williams Congdon Grice Clarke 2003`

**Records in database:** none for this source in current export.

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## germ8 — Seed dormancy type

**Status:** approved

**Source column:** inferred from experimental response — species that responded to heat shock (80–100°C, 5 min) have physical dormancy; perennial species with no response have unknown/no dormancy

**Notes:** The paper tests fire-related cues (heat shock, smoke, nitrate) on germination of 10 legume species. Six species showed significantly increased germination after heat shock (80–100°C), indicating physical (seed coat) dormancy that is broken by heat. The mechanism is explicitly described as cracking the cuticular layer or opening a strophiolar plug. Four heavy-seeded species showed no significant response.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Significantly increased germination after heat shock 80–100°C | PY |
| No significant increase in germination with fire-related cues | ND |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Chamaecrista mimosoides | PY |
| Crotalaria calycina | PY |
| Crotalaria lanceolata | PY |
| Crotalaria montana | PY |
| Indigofera hirsuta | PY |
| Tephrosia juncea | PY |
| Chamaecrista absus | ND |
| Crotalaria pallida | ND |
| Galactia tenuiflora | ND |
| Glycine tomentella | ND |

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** Table 1 notes and Discussion (two perennial species); life-form descriptions (ephemerals)

**Notes:** Table 1 notes that *Galactia tenuiflora* and *Glycine tomentella* are "perennial species capable of sprouting following fire." The remaining eight species are described as annuals/ephemerals killed by fire. No standardised fire severity is specified (laboratory germination study, not a field burn), so full canopy scorch cannot be assumed — treat as general post-fire fire response. This is an exceptions-only extraction for the ten study species.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Perennial, capable of sprouting following fire | All |
| Annual or ephemeral, killed by fire | None |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Galactia tenuiflora | All |
| Glycine tomentella | All |
| Chamaecrista mimosoides | None |
| Crotalaria calycina | None |
| Crotalaria lanceolata | None |
| Crotalaria montana | None |
| Indigofera hirsuta | None |
| Tephrosia juncea | None |
| Chamaecrista absus | None |
| Crotalaria pallida | None |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ not described per species |
| surv5 | No lifespan data reported |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data; seed viability reported only as a methodological control (tetrazolium test), not as longevity |
| germ1 | Seedbank type not assessed; study is a germination experiment, not a seedbank characterisation |
| grow1 | No data on age to develop regenerative organs |
| rect2 | Establishment pattern not assessed per species |
| repr2 | Post-fire flowering not assessed |
| repr3 | Age at first flowering not reported |
| repr3a | Time to post-fire reproduction from resprouts not reported |
| repr4 | Maturation age not reported |
| disp1 | Dispersal mode not reported |
