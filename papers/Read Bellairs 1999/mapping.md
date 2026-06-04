# Read Bellairs 1999

**Citation:** Read, T.R. and Bellairs, S.M. (1999). Smoke affects the germination of native grasses of New South Wales. *Australian Journal of Botany*, 47, 563–576.

**PDF:** `Smoke affects the Germination of Native Grasses of New South Wales.pdf`

**Reference string:** `Read Bellairs 1999`

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

**Source column:** Table 2 (smoke treatment germination %, control germination %, seed viability %)

**Notes:** The paper provides per-species germination data under smoke and control treatments for 20 native grass species (Table 2). The degree of dormancy in untreated seeds is inferable from control germination relative to seed viability, and the paper explicitly discusses dormancy mechanisms (physical/covering-structure-based dormancy vs. no dormancy) at the species level. However, the paper does not assign formal dormancy type vocabulary (PY, PD, etc.) — it describes covering-structure-mediated dormancy (lemma/palea/glumes) and smoke-responsive dormancy, which corresponds to Chemical or Physiological dormancy. Mapping to controlled vocabulary would require inference. Leave as skip pending reviewer judgement.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Smoke increased germination, covering structures contribute to dormancy | PY |
| Smoke increased germination, covering structures do not inhibit smoke response | PD |
| No smoke response, no dormancy apparent | ND |
| Smoke reduced germination | ??? |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv1 | No per-species fire response (resprouting) data; study is a germination experiment |
| surv4 | No regenerative organ data |
| surv5 | No longevity data |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data; seed viability reported as a % at time of experiment only |
| germ1 | No seedbank type classification per species |
| grow1 | No data on age to develop regenerative organs |
| rect2 | No field recruitment data per species; only laboratory and glasshouse germination trials |
| repr2 | No post-fire flowering response data |
| repr3 | No age at first flower data |
| repr3a | No time to first post-fire reproduction from resprouts |
| repr4 | No maturation age data |
| disp1 | No dispersal mode data |
