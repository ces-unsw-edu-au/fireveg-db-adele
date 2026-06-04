# Wright Boyd Clarke Peter 2007
# Traits: surv4
#
# TRANSCRIPTION NOTES — review before running:
#
# No transcription issues.
# This script is exceptions-only: no CSV is used.
# All data is taken directly from the mapping.md exceptions table.

library(tidyverse)
source('R/funx.R')

# 1. Build exceptions tibble directly from mapping.md
# surv4 — Regenerative organ
# Sources:
#   Underground organs: "The buds of these two species [kempeana, aneura] occur on
#     laterally branching roots, as well as around the central trunk." (Results, Resprouting buds)
#   A. maitlandii: "buds on a single robust taproot in a collar ~4-5 cm below the soil surface"
#     — taproot fits Tuber definition (non-woody subsoil organ). (Results, Resprouting buds)
#   A. melleodora: "shallowest bud depth of the four species; buds near stem base" (Figure 1)
#   Epicormic: "A. kempeana, A. maitlandii and A. melleodora all showed relatively strong
#     ability to resprout from above-ground stems, with 76, 60 and 50% above-ground
#     resprouting respectively" (Table 2, low-severity long-interval treatment)
#   A. aneura: obligate seeder, sporadic basal resprouting only — no epicormic record.
#
# Each value is its own row — 9 rows total, 9 database records.

exceptions <- tibble(
  original_name = c(
    'Acacia maitlandii',
    'Acacia maitlandii',
    'Acacia melleodora',
    'Acacia melleodora',
    'Acacia kempeana',
    'Acacia kempeana',
    'Acacia kempeana',
    'Acacia aneura',
    'Acacia aneura'
  ),
  surv4_value = c(
    'Tuber',
    'Epicormic',
    'Basal',
    'Epicormic',
    'Long rhizome or root sucker',
    'Basal',
    'Epicormic',
    'Long rhizome or root sucker',
    'Basal'
  ),
  raw_source = c(
    'buds on a single robust taproot in a collar ~4-5 cm below the soil surface (Results, Resprouting buds)',
    '60% above-ground stem resprouting, low-severity long-interval treatment (Table 2)',
    'shallowest bud depth of the four species; buds near stem base (Figure 1, Results)',
    '50% above-ground stem resprouting, low-severity long-interval treatment (Table 2)',
    'buds on laterally branching roots (Results, Resprouting buds)',
    'buds around the central trunk (Results, Resprouting buds)',
    '76% above-ground stem resprouting, low-severity long-interval treatment (Table 2)',
    'buds on laterally branching roots (Results, Resprouting buds)',
    'buds around the central trunk (Results, Resprouting buds)'
  )
)

# 2. Align taxonomy to Bionet
exceptions <- match_bionet_taxonomy(exceptions, 'original_name')
exceptions$original_source <- 'Wright Boyd Clarke Peter 2007'

# 3. Construct records in long format
# Each row is already one value per species — no pivot needed.
data_long <- exceptions %>%
  mutate(
    trait_code = 'surv4',
    norm_value = surv4_value,
    raw_value  = paste0('Resprouting buds, ', raw_source)
  )

# 4. Add best / lower / upper (NA for categorical traits) and select final columns
records <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_,
    notes = coalesce(notes, NA_character_)
  ) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)  # raw_source dropped here

# 5. Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# 6. Save records so combine.R can aggregate across all papers
write_csv(records, 'papers/Wright Boyd Clarke Peter 2007/wright_boyd_clarke_peter_2007_records.csv')

# 7. Flag duplicates
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/Wright Boyd Clarke Peter 2007/wright_boyd_clarke_peter_2007_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/Wright Boyd Clarke Peter 2007/wright_boyd_clarke_peter_2007_dupes_possible.csv')

# SQL to set weight = 0 for exact/partial duplicate records
# Requires record_id in the database export. Run only if authorised to write to the database.
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"), host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"), user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv4 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
