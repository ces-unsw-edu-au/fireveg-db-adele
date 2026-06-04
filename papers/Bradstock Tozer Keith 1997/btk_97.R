# Bradstock Tozer Keith 1997
# Traits: surv1, germ1
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. CSV has 'soil_stored_obligate seeder' with a SPACE (not underscore) for
#    28 species. Exact string matching would fail for these. str_detect is used
#    throughout to handle this and any other minor encoding variation.
#
# 2. Banksia oblongifolia has functional_group = 'serotinous_resprouter' — this
#    value does not appear in the mapping.md table but resolves correctly via
#    str_detect: contains 'resprouter' -> surv1 = All; contains 'serotinous' ->
#    germ1 = Canopy. No exception row needed.
#
# 3. surv1 has 25 records already in the database for this source. flag_duplicates
#    will identify these; retire with weight = 0 if authorised.
#
# 4. Functional group classification method (per paper): mode of recovery
#    confirmed by presence of charred remains attached to living post-fire shoots.
#    Seed storage type: serotinous fruits identified by inspection; soil-stored
#    inferred from conspicuous post-fire germination pulse; transient assumed
#    where neither serotinous fruits nor conspicuous post-fire germination occurred.

library(tidyverse)
source('R/funx.R')

# 1. Read data
data <- read.csv('papers/Bradstock Tozer Keith 1997/function_group_table.csv')

# 2. No rename needed — column names already clean

# 3. No name cleaning needed — binomials are clean; match_bionet_taxonomy
#    handles any trailing author abbreviations internally.

# 4. Map trait values using str_detect on functional_group
#    str_detect handles the space/underscore inconsistency and the
#    'serotinous_resprouter' value not listed in mapping.md.
data <- data %>%
  mutate(
    surv1 = case_when(
      str_detect(functional_group, 'resprouter') ~ 'All',
      str_detect(functional_group, 'obligate')   ~ 'None',
      TRUE ~ NA_character_
    ),
    germ1 = case_when(
      str_detect(functional_group, 'serotinous') ~ 'Canopy',
      str_detect(functional_group, 'soil')       ~ 'Soil-persistent',
      str_detect(functional_group, 'transient')  ~ 'Transient',
      TRUE ~ NA_character_
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'species')
data$original_source <- 'Bradstock Tozer Keith 1997'

# 6a. Build surv1 long-format records
data_long_surv1 <- data %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0('functional_group, ', functional_group)
  )

# 6b. Build germ1 long-format records
data_long_germ1 <- data %>%
  filter(!is.na(germ1)) %>%
  mutate(
    trait_code = 'germ1',
    norm_value = germ1,
    raw_value  = paste0('functional_group, ', functional_group)
  )

# 7. Bind all traits
data_long <- bind_rows(data_long_surv1, data_long_germ1)

# 8. Section 8 skipped — both traits are categorical.

# 9. Select final columns
report_unmatched(data_long)

records <- data_long %>%
  mutate(
    notes = coalesce(notes, NA_character_),
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  ) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates
records <- records %>% filter(!is.na(species_code))

write_csv(records, 'papers/Bradstock Tozer Keith 1997/btk_97_records.csv')

database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Bradstock Tozer Keith 1997/btk_97_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Bradstock Tozer Keith 1997/btk_97_dupes_possible.csv')

# SQL to set weight = 0 for exact/partial duplicate records
# Requires record_id in the database export. Run only if authorised to write to the database.
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"), host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"), user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv1 SET weight = 0 WHERE record_id = ", id))
#   dbExecute(con, paste0("UPDATE litrev.germ1 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
