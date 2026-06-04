# Rice Westoby 1981

**Citation:** Rice, B. and Westoby, M. (1981). Myrmecochory in sclerophyll vegetation of the West Head, New South Wales. *Australian Journal of Ecology*, 6, 291–298.

**PDF:** `Myrmecochory in sclerophyll vegetation of the West Head  New South.pdf`

**Reference string:** `Rice Westoby 1981`

**Records in database:**

| Trait | n |
|---|---|
| surv5 | 1 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## disp1 — Propagule dispersal mode

**Status:** approved

**Source column:** Appendix 1 (species list with myrmecochore status indicated by `*` = undoubted myrmecochore, `†` = possibly myrmecochore, unmarked = non-myrmecochore)

**Notes:** The Appendix lists ~200 species with per-species classification as undoubted myrmecochore (`*`), possible myrmecochore (`†`), or non-myrmecochore (unmarked). This gives extractable per-species dispersal mode data for the Animal (myrmecochory = ant dispersal) category. However, non-myrmecochore species are not assigned to other dispersal modes (wind, gravity, ballistic, etc.) — they are simply classified as not ant-dispersed. The paper covers only one dispersal mode axis. Extraction would be valid for the myrmecochore species as `ant`; non-myrmecochore species are not assigned a disp1 value from this paper (their actual dispersal mode is unspecified — `Unknown` is not a valid disp1 vocabulary value).

**Value mapping**

| Raw value | norm_value |
|---|---|
| * (undoubted myrmecochore) | ant |
| unmarked (non-myrmecochore) | NA |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv1 | No per-species fire response (resprouting) data; paper is about dispersal mode |
| surv4 | No regenerative organ data |
| surv5 | No longevity data |
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data |
| germ1 | No seedbank type data |
| germ8 | No seed dormancy data |
| grow1 | No data on age to develop regenerative organs |
| rect2 | No recruitment pattern data per species |
| repr2 | No post-fire flowering response data |
| repr3 | No age at first flower data |
| repr3a | No time to first post-fire reproduction data |
| repr4 | No maturation age data |
