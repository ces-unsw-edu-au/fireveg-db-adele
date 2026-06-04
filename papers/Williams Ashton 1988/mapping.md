# Williams Ashton 1988

**Citation:** Williams, R.J. and Ashton, D.H. (1988). Cyclical patterns of regeneration in subalpine heathland communities on the Bogong High Plains, Victoria. *Australian Journal of Botany*, 36: 605–619.

**PDF:** `Cyclical patterns of regeneration in subalpine heathland communitites on the Bogong High Plains.pdf`

**Reference string:** `Williams Ashton 1988`

**Records in database:**

| Trait | n |
|---|---|
| surv5 | 3 |

---

## How to use this file

- Set each trait status to `approved` or `skip`
- If all traits are set to `skip`, no R script will be generated
- Fill in any `???` values before approving
- Add or remove rows in the exceptions table as needed

---

## surv1 — Resprouting - full canopy scorch

**Status:** approved

**Source column:** Table 3 (`Dormant buds` and `Root stock` columns) and text

Table 3 lists life history characteristics of major shrubs on the Bogong High Plains, including whether they have dormant buds and root stock. These indicate capacity for vegetative resprouting. However, this paper does not study fire response directly — it studies shrub phase dynamics (pioneer through degenerate phases) in relation to grazing and natural senescence. The 1939 wildfire is mentioned as historical context. No per-species fire response classification is provided as the primary data.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Dormant buds = + AND/OR Root stock = + | All |
| Dormant buds = - AND Root stock = - (seedling establishment only) | None |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Grevillea australis | None |
| Asterolasia trymalioides | None |

---

## surv4 — Regenerative organ

**Status:** skip

**Source column:** Table 3 (`Stem layering`, `Dormant buds`, `Root stock`) and text

Table 3 documents whether each major shrub has stem layering, dormant buds, and root stock capacity. These can be mapped to regenerative organ types. The paper gives this for 7 species of major shrubs in the three heath communities.

**Multi-value:** Table 3 has a separate column per organ type — if a species has more than one present, use the multi-value pivot pattern (see PIPELINE.md step 6) to produce one record per organ.

**Value mapping**

| Raw value | norm_value |
|---|---|
| Root stock = + | Long rhizome or root sucker |
| Dormant buds = + only | Basal |
| Stem layering only, no dormant buds, no root stock | Basal |

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Grevillea australis | None |
| Asterolasia trymalioides | None |
| Hovea longifolia | Lignotuber |
| Kunzea muelleri | Lignotuber |
| Phebalium squamulosum | Lignotuber |
| Prostanthera cuneata | Lignotuber |
| Orites lancifolia | Lignotuber |

---

## surv5 — Standing plant longevity (max)

**Status:** approved

**Source column:** text (Discussion — "Persistence and Longevity of Shrubs" section)

The paper provides age estimates for major shrubs from ring structure analysis and known establishment dates. Values are given as ranges or minima for individual species. The life cycle from establishment to death is estimated at 30–50 years for the major shrubs.

Units: years. Species-level values extractable from text:

- *Phebalium squamulosum*: 30–47 years (10 senescent individuals aged)
- *Prostanthera cuneata*: stems c. 30–50 years (ring structure)
- *Asterolasia trymalioides*: at least 40 years (fenced since 1946, no signs of senescence)
- General estimate for major shrubs: 30–50 years

**Species-level exceptions** (override the mapping above)

| Species | norm_value |
|---|---|
| Phebalium squamulosum | 30-47 |
| Prostanthera cuneata | 30-50 |
| Asterolasia trymalioides | >40 |

---

## Other priority traits — not extractable from this paper

| Trait | Reason |
|---|---|
| surv6 | No seedbank half-life data |
| surv7 | No seed longevity data |
| germ1 | No per-species seedbank type classification |
| germ8 | No per-species seed dormancy data |
| grow1 | No per-species age at development of regenerative organ |
| rect2 | Paper does not study post-fire seedling recruitment patterns; focuses on shrub phase dynamics under grazing disturbance |
| repr2 | Post-fire flowering response not measured; paper does not study fire response |
| repr3 | Age at first flowering from seed not measured per species |
| repr3a | Time to first post-fire reproduction from resprouts not measured |
| repr4 | Maturation age not systematically recorded per species |
| disp1 | No per-species dispersal mode data |
