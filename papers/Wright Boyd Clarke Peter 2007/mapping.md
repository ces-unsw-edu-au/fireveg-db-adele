# Wright Boyd Clarke Peter 2007

**Citation:** Wright, B.R. and Clarke, P.J. (2007) Resprouting responses of Acacia shrubs in the Western Desert of Australia – fire severity, interval and season influence survival. *International Journal of Wildland Fire* 16, 317–323.

**PDF:** `Resprouting responses of Acacia shrubs in the Western Desert of Australia - fire severity, interval and season influence surviva.pdf`

**Reference string:** `Wright Boyd Clarke Peter 2007`

**Records in database:** none for this source in current export.

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** skip

**Source column:** `% survival` columns in Table 3 (adult survival by fire severity, season and interval); Table 2 (proportion resprouting from above-ground buds v. total survivors)

**Notes:** The paper reports per-species post-fire survival percentages for four Acacia species under high- and low-severity experimental burns. The low-severity treatment approximates a full canopy scorch (above-ground scorched by propane torch, no basal heating applied), with survival recorded 6 months post-burn. Under the low-severity long-interval treatment, survival was: A. kempeana 63%, A. maitlandii 78%, A. melleodora 45%, A. aneura 57% (from Table 3 severity column). However, surv1 requires a categorical classification (All/Most/Few/None) rather than continuous percentage survival, and these results vary substantially by season — there is no single summary value per species. Additionally, A. aneura is described as an obligate seeder but showed some sporadic basal resprouting (39% total survival). The data are too conditional on fire season and interval to map cleanly to surv1 vocabulary without collapsing important variation.

---

## surv4 — Regenerative organ

**Status:** approved

**Source column:** Results section ("Resprouting buds") and Figure 1

**Notes:** The paper describes per-species resprouting bud location. *A. maitlandii* has buds on a single robust taproot in a collar ~4–5 cm below the soil surface — equivalent to a lignotuber. *A. kempeana* and *A. aneura* have buds on laterally branching roots (= Long rhizome or root sucker) as well as around the central trunk base (= Basal) — two records each. *A. melleodora* is reported in Figure 1 to have the shallowest bud depth of the four species; buds are near the stem base (= Basal). Low-severity burns also record above-ground (epicormic) stem resprouting in Table 2 — but epicormic buds are secondary to the underground organs for these species under higher-severity fire. *A. aneura* is an obligate seeder that shows only sporadic basal resprouting; its surv4 record should carry a low confidence flag.

**Multi-value:** *A. kempeana* and *A. aneura* resprout from both lateral roots and trunk base — two records each. Use the multi-value pivot pattern (see PIPELINE.md step 6).

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Acacia maitlandii | Tuber |
| Acacia maitlandii | Epicormic |
| Acacia melleodora | Basal |
| Acacia melleodora | Epicormic |
| Acacia kempeana | Long rhizome or root sucker |
| Acacia kempeana | Basal |
| Acacia kempeana | Epicormic |
| Acacia aneura | Long rhizome or root sucker |
| Acacia aneura | Basal |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv1 | Per-species survival percentages reported but vary substantially by fire season; no single categorical classification (All/Most/Few/None) can be derived without collapsing critical variation |
| surv5 | No lifespan data reported; paper notes species are "long-lived" but no numerical values given |
| surv6 | No seedbank half-life data; seedbank described as "soil-stored" but no persistence estimates given |
| surv7 | No seed longevity data |
| germ1 | Seedbank described as "soil-stored" for all four species collectively; no per-species seedbank type classification |
| germ8 | Seed dormancy noted as heat-cued for Acacia spp. (one sentence) but not assessed in this paper; no per-species dormancy data |
| grow1 | No data on age to develop regenerative organs |
| rect2 | Seedling recruitment not assessed; paper focuses on adult and juvenile resprouting survival |
| repr2 | Post-fire flowering not assessed |
| repr3 | Age at first flowering not reported |
| repr3a | Time to post-fire reproduction from resprouts not reported |
| repr4 | Maturation age not reported |
| disp1 | Dispersal mode not reported |
