# Wills Read 2007

**Citation:** Wills, T.J. and Read, J. (2007) Soil seed bank dynamics in post-fire heathland succession in south-eastern Australia. *Plant Ecology* 190, 1–12.

**PDF:** `Soil seed bank dynamics in post-fire heathland succession in south-eastern Australia.pdf`

**Reference string:** `Wills Read 2007`

**Records in database:** none for this source in current export.

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## germ1 — Seedbank type

**Status:** skip

**Source column:** `MR` (Mode of Regeneration) in Appendix 1

**Notes:** Appendix 1 lists 34 species with a Mode of Regeneration (MR) column using codes: OS (obligate seeder, >91% seed germination), OR (obligate resprouter, 0–10% seed germination), FR (facultative resprouter, 11–90% seed germination). These codes describe regeneration mode rather than seedbank type directly. However, species presence in the germinable soil seedbank (detected in soil cores) combined with MR codes allows inference of seedbank type. Species coded OS or FR that appear in the seedbank have a soil-persistent or transient seedbank. The paper does not distinguish between soil-persistent and transient per species, but the experimental design (sampling across 3–26 year post-fire chronosequence) and the discussion confirm that many species maintain seeds in the soil. Seedbank type cannot be cleanly resolved to Canopy/Soil-persistent/Transient/None per species from the data provided — the MR column describes regeneration mode, not seedbank persistence class. This is not straightforwardly mappable to germ1 vocabulary without additional per-species inference beyond what the paper reports.

---

## surv1 — Resprouting - full canopy scorch

**Status:** skip

**Source column:** `MR` (Mode of Regeneration) in Appendix 1

**Notes:** The MR column codes can indicate whether species resprout: OR = obligate resprouter (resprout = All), OS = obligate seeder (resprout = None), FR = facultative resprouter (resprout = Most or Few). However, these codes are regeneration mode classifications, not measurements of resprouting after a standardised full canopy scorch event. The paper's focus is soil seedbank dynamics, not resprouting quantification. The MR codes are attributed to T. Wills (unpublished data) and are not derived from this paper's own field measurements. Because surv1 requires per-species data derived from the paper's own results, this is not extractable.

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv1 | MR codes in appendix indicate regeneration mode but are not derived from this paper's own resprouting measurements; no standardised full-canopy-scorch assessment |
| surv4 | Regenerative organ not described per species |
| surv5 | No lifespan data reported |
| surv6 | No seedbank half-life data reported; chronosequence covers only 26 years and does not estimate species-level decay rates |
| surv7 | No seed longevity data per species |
| germ1 | Seedbank type (Canopy/Soil-persistent/Transient/None) not distinguished per species; MR codes describe regeneration mode, not seedbank persistence class |
| germ8 | Seed dormancy type not assessed per species; heat treatment used to promote germination but not interpreted as dormancy classification |
| grow1 | Age to develop regenerative organs not reported |
| rect2 | Establishment pattern not assessed per species |
| repr2 | Post-fire flowering not assessed |
| repr3 | Age at first flowering not reported |
| repr3a | Time to post-fire reproduction from resprouts not reported |
| repr4 | Maturation age not reported |
| disp1 | Dispersal mode not reported |
