# Read Bellairs 1999
# Traits: germ8
#
# TRANSCRIPTION NOTES — review before running:
#
# No transcription issues.
# This script is exceptions-only: no CSV is used.
# All data is taken directly from Table 2 and the Results/Discussion.
#
# EXCLUDED SPECIES (no germ8 value assigned):
#
# Stipa scabra subsp. scabra — smoke REDUCED germination (30.2 -> 19.9%*); adverse effect,
#   no germ8 value assigned per mapping rules.
#
# Danthonia pallida — no smoke response, but covering-structure dormancy IS present
#   (dehusking increased germination from ~20% to >60%; Discussion p.572). Smoke did not
#   overcome this dormancy. Cannot assign ND (dormancy is apparent) and cannot assign PY
#   (smoke did not increase germination). Excluded as ambiguous.
#
# Digitaria brownii — no smoke response, but seeds were highly dormant (viability 94%,
#   germination <25%). Neither dehusking nor smoke overcame dormancy (Discussion p.572).
#   Mechanism unknown; excluded as ambiguous.
#
# Eragrostis elongata — no smoke response; germination (41.9%) substantially below
#   viability (92%), indicating dormancy present but not smoke- or structure-mediated.
#   Excluded as ambiguous.
#
# CLASSIFICATION LOGIC:
#
# PY  — smoke increased germination AND covering structures contribute to dormancy:
#   Paspalidium distans, Stipa scabra subsp. falcata, Themeda triandra.
#   Paper (p.567): "Paspalidium distans and Themeda triandra differed from the preceding
#   species, in that the covering structures hindered smoke stimulation."
#   For Stipa scabra subsp. falcata (Table 3 / Fig. 1a): smoking husked seeds increased
#   germination, but this was further increased by removing covering structures, confirming
#   structures contribute to dormancy.
#
# PD  — smoke increased germination AND covering structures do NOT inhibit the response:
#   Chloris ventricosa, Dichanthium sericeum, Panicum decompositum, Panicum effusum,
#   Poa labillardieri.
#   Paper (p.567): "Presence of covering structures did not inhibit smoke stimulation of
#   germination for any of these species, indicating that the covering structures do not
#   prevent the active water soluble compounds in the smoke from being taken up by the
#   caryopsis." Chloris ventricosa and Dichanthium sericeum had only a small proportion of
#   dormant seeds; the husk had little effect on germination (Discussion p.572).
#
# ND  — no smoke response AND no dormancy apparent (germination ~= seed viability):
#   Group 2 species (smoke affected rate only, not final %; germination without smoke ~=
#   viability): Danthonia eriantha, Danthonia linkii var. fulva, Danthonia racemosa,
#   Chloris truncata, Microlaena stipoides (Discussion p.571).
#   Group 3 species where germination ~ viability: Bothriochloa decipiens,
#   Cymbopogon refractus, Eriochloa pseudoacrotricha (Discussion p.571-572).

library(tidyverse)
source('funx.R')

# 1. Build exceptions tibble directly from paper
# germ8 — Seed dormancy type
# One row per species; norm_value is PY, PD, or ND.

exceptions <- tibble(
  original_name = c(
    # PY: smoke increased germination; covering structures contribute to dormancy
    'Paspalidium distans',
    'Stipa scabra',
    'Themeda triandra',
    # PD: smoke increased germination; covering structures do NOT inhibit response
    'Chloris ventricosa',
    'Dichanthium sericeum',
    'Panicum decompositum',
    'Panicum effusum',
    'Poa labillardieri',
    # ND: no smoke response; no dormancy apparent (germination ~ seed viability)
    'Danthonia eriantha',
    'Danthonia linkii',
    'Danthonia racemosa',
    'Chloris truncata',
    'Microlaena stipoides',
    'Bothriochloa decipiens',
    'Cymbopogon refractus',
    'Eriochloa pseudoacrotricha'
  ),
  norm_value = c(
    'PY', 'PY', 'PY',
    'PD', 'PD', 'PD', 'PD', 'PD',
    'ND', 'ND', 'ND', 'ND', 'ND', 'ND', 'ND', 'ND'
  ),
  raw_source = c(
    # PY
    'Table 2: smoke 30.5%** vs control 17.5%; covering structures hindered smoke stimulation, removal significantly increased germination (Results p.567, Discussion)',
    'Table 2: smoke 34.1%*** vs control 14.0% (husked); dehusking further increased germination to 31.4%*** (Table 2); covering structures contribute to dormancy (Fig. 1a, Results p.567)',
    'Table 2: smoke 86.6%* vs control 75.2%; covering structures hindered smoke stimulation, removal increased germination to 92.4%*** (Table 2, Results p.567)',
    # PD
    'Table 2: smoke 97%* vs control 89.6%; only small proportion of dormant seeds; husk had little effect on germination (Discussion p.572)',
    'Table 2: smoke 98.3%** vs control 93.0%; only small proportion of dormant seeds; husk had little effect on germination (Discussion p.572)',
    'Table 2: smoke 63.1%*** vs control 7.7%; husked seeds only; covering structures did not inhibit smoke stimulation (Results p.567)',
    'Table 2: smoke 16.7%*** vs control 0%; husked seeds only; covering structures did not inhibit smoke stimulation (Results p.567)',
    'Table 2: smoke 23.5%* vs control 10%; covering structures did not inhibit smoke stimulation (Results p.567)',
    # ND
    'Table 2: smoke 96.1 vs control 93.9 (n.s. final); viability 100%; germination without smoke ~ viability, no dormancy apparent (Discussion p.571)',
    'Table 2: smoke 86.6 vs control 92.6 (n.s. final); viability 87%; germination without smoke ~ viability, no dormancy apparent (Discussion p.571)',
    'Table 2: smoke 97.8 vs control 96.5 (n.s. final); viability 97%; germination without smoke ~ viability, no dormancy apparent (Discussion p.571)',
    'Table 2: smoke 90.4 vs control 86.6 (n.s. final); viability 93%; germination without smoke ~ viability, no dormancy apparent (Discussion p.571)',
    'Table 2: smoke 79.5 vs control 86.4 (n.s. final); viability 95%; low level of seed dormancy, no smoke response (Discussion p.571)',
    'Table 2: smoke 93.7 vs control 92.6 (n.s.); viability 100%; no smoke response, germination ~ viability (Group 3, Discussion p.571)',
    'Table 2: smoke 49.7 vs control 43.7 (n.s.); viability 42%; no smoke response, germination ~ viability (Group 3, Discussion p.571)',
    'Table 2: smoke 67.8 vs control 69.4 (n.s.); viability 75%; appeared not dormant, germination ~ viability (Group 3, Discussion p.572)'
  )
)

# Note: Stipa scabra subsp. falcata is entered as 'Stipa scabra' for Bionet matching;
# match_bionet_taxonomy will attempt to match the subspecies name.
# If unmatched, the row will be filtered in step 5 — review bionet_name output.

# 2. Align taxonomy to Bionet
exceptions <- match_bionet_taxonomy(exceptions, 'original_name')
exceptions$original_source <- 'Read Bellairs 1999'

# 3. Construct records
# Each row is already one value per species — no pivot needed.
data_long <- exceptions %>%
  mutate(
    trait_code = 'germ8',
    raw_value  = paste0('Table 2 / text, ', raw_source)
  )

# 4. Add best / lower / upper (NA for categorical traits) and select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

records <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_,
    notes = coalesce(notes, NA_character_)
  ) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 5. Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# 6. Save records so combine.R can aggregate across all papers
write_csv(records, 'papers/Read Bellairs 1999/read_bellairs_1999_records.csv')

# 7. Flag duplicates
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/Read Bellairs 1999/read_bellairs_1999_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/Read Bellairs 1999/read_bellairs_1999_dupes_possible.csv')

# SQL to set weight = 0 for exact/partial duplicate records
# Requires record_id in the database export. Run only if authorised to write to the database.
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"), host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"), user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.germ8 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
