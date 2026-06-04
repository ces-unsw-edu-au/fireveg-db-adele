# Bradstock Tozer Keith 1997

**Citation:** Bradstock, R. A., Tozer, M. G. and Keith, D. A. (1997). Effects of high frequency fire on floristic composition and abundance in a fire-prone heathland near Sydney. *Australian Journal of Botany* **45**, 641–655.

**PDF:** `Effects of high frequency fire on floristic composition and abundance in a fire-prone heathland near Sydney.pdf`

**Reference string:** `Bradstock Tozer Keith 1997`

**Records in database:**

| Trait | n |
|---|---|
| surv1 | 25 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting (full canopy scorch)

**Status:** approved

**Source column:** `functional_group`

**Value mapping**

| Raw value | norm_value |
|---|---|
| serotinous_obligate_seeder | None |
| soil_stored_obligate_seeder | None |
| resprouter_soil_seedbank_vegetative_spread | All |
| resprouter_soil_seedbank_no_vegetative_spread | All |
| serotinous_resprouter_no_vegetative_spread | All |
| resprouter_transient_seedbank_no_vegetative_spread | All |

> Note: Table 2 organises all species into six functional groups defined by mode of recovery (obligate seeder vs resprouter), seed bank type, and capacity for vegetative spread. The functional group headings directly encode surv1. All obligate seeder groups map to `None`; all resprouter groups map to `All`. The paper states mode of recovery was determined by examining above- and below-ground parts of post-fire plants for charred remains — resprouting confirmed by presence of charred material attached to a living shoot. The R script uses the functional_group column from the CSV. The raw functional group string values in the CSV may differ from those shown here; verify against the actual CSV column values.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## germ1 — Seedbank type

**Status:** approved

**Source column:** `functional_group`

**Value mapping**

| Raw value | norm_value |
|---|---|
| serotinous_obligate_seeder | Canopy |
| soil_stored_obligate_seeder | Soil-persistent |
| resprouter_soil_seedbank_vegetative_spread | Soil-persistent |
| resprouter_soil_seedbank_no_vegetative_spread | Soil-persistent |
| serotinous_resprouter_no_vegetative_spread | Canopy |
| resprouter_transient_seedbank_no_vegetative_spread | Transient |

> Note: Seedbank type is encoded in the functional group classification. Serotinous = Canopy; soil-stored = Soil-persistent; transient = Transient. This is consistent with the R script (btk_97.R) which uses str_detect on the functional_group string. The paper describes the method for determining seed storage: serotinous fruits identified by inspection; soil-stored seeds inferred from conspicuous pulse of post-fire germination; transient assumed where neither serotinous fruits nor conspicuous post-fire germination occurred. Seed germination data from Keith (1991, 1996) allowed prediction of seedbank type for a number of species.

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv4 | Regenerative organ type not recorded per species; paper records only whether vegetative spread occurs (rhizomes/suckers), not the specific organ type |
| surv5 | Plant longevity not covered |
| surv6 | Seedbank half-life not covered |
| surv7 | Seed longevity not covered |
| germ8 | Seed dormancy mechanism not recorded per species |
| grow1 | Age at development of regenerative organs not covered |
| rect2 | Establishment pattern not classified per species; paper compares frequency across fire regimes, not per-species recruitment pattern classification |
| repr2 | Post-fire flowering response not covered |
| repr3 | Age at first flowering not covered |
| repr3a | Time to first post-fire reproduction from resprouts not covered |
| repr4 | Maturation age not covered |
| disp1 | Dispersal mode not covered |
