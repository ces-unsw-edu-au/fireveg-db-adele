# Williams Congdon Grice Clarke 2003
# Traits: germ8, surv1
#
# No CSV — all records derived directly from mapping.md exceptions tables.
# Data source for germ8: laboratory germination experiment (Table 1/Results).
#   Species showing significantly increased germination after heat shock
#   80-100 degrees C (5 min) have physical dormancy (PY); mechanism is
#   cracking the cuticular layer or opening the strophiolar plug (explicit
#   in paper text, p.508). Four heavy-seeded species showed no significant
#   increase with any fire-related cue (ND).
# Data source for surv1: Table 1 footnotes and Discussion.
#   Galactia tenuiflora and Glycine tomentella explicitly described as
#   "perennial species capable of sprouting following fire" (Table 1 footnote).
#   Remaining 8 species described as ephemerals killed by fire.
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. germ8 classification is based on statistical significance (ANOVA, one-factor)
#    of heat shock response in germination experiment, not a direct dormancy
#    type assay. PY is inferred from significant heat response + explicit
#    mechanism description in paper text.
#
# 2. Galactia tenuiflora and Glycine tomentella are classified ND for germ8
#    (no significant heat response, germination < 25% in all treatments).
#    Paper notes this may reflect suboptimal incubation conditions or
#    after-ripening requirements not tested — dormancy mechanism uncertain.
#
# 3. surv1 for this paper comes from a laboratory germination study, not a
#    standardised field burn. "Capable of sprouting following fire" is the
#    basis for All; annual/ephemeral life form is the basis for None.

library(tidyverse)
source('funx.R')

# 6a. Build germ8 records from mapping.md exceptions table
germ8_exceptions <- tibble(
  original_name = c(
    'Chamaecrista mimosoides',
    'Crotalaria calycina',
    'Crotalaria lanceolata',
    'Crotalaria montana',
    'Indigofera hirsuta',
    'Tephrosia juncea',
    'Chamaecrista absus',
    'Crotalaria pallida',
    'Galactia tenuiflora',
    'Glycine tomentella'
  ),
  norm_value = c(
    'PY', 'PY', 'PY', 'PY', 'PY', 'PY',
    'ND', 'ND', 'ND', 'ND'
  ),
  raw_value = c(
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'significantly increased germination after heat shock 80-100 degrees C; mechanism: seed coat cracking/strophiolar plug opening',
    'no significant increase in germination with exposure to any fire-related cue',
    'no significant increase in germination with exposure to any fire-related cue',
    'no significant increase in germination with exposure to any fire-related cue; germination <25% in all treatments',
    'no significant increase in germination with exposure to any fire-related cue; germination <25% in all treatments'
  )
)

germ8_matched <- match_bionet_taxonomy(germ8_exceptions, 'original_name')
germ8_matched$original_source <- 'Williams Congdon Grice Clarke 2003'

data_long_germ8 <- germ8_matched %>%
  mutate(trait_code = 'germ8')

# 6b. Build surv1 records from mapping.md exceptions table
surv1_exceptions <- tibble(
  original_name = c(
    'Galactia tenuiflora',
    'Glycine tomentella',
    'Chamaecrista mimosoides',
    'Crotalaria calycina',
    'Crotalaria lanceolata',
    'Crotalaria montana',
    'Indigofera hirsuta',
    'Tephrosia juncea',
    'Chamaecrista absus',
    'Crotalaria pallida'
  ),
  norm_value = c(
    'All', 'All',
    'None', 'None', 'None', 'None', 'None', 'None', 'None', 'None'
  ),
  raw_value = c(
    'Table 1 footnote: perennial species capable of sprouting following fire',
    'Table 1 footnote: perennial species capable of sprouting following fire',
    'Table 1: ephemeral herb that completes its life cycle within a single year; killed by fire',
    'Table 1: ephemeral herb that completes its life cycle within a single year; killed by fire',
    'Table 1: ephemeral herb (exotic); killed by fire',
    'Table 1: ephemeral herb that completes its life cycle within a single year; killed by fire',
    'Table 1: ephemeral herb that completes its life cycle within a single year; killed by fire',
    'Table 1: ephemeral herb that completes its life cycle within a single year; killed by fire',
    'Table 1: ephemeral herb (exotic); killed by fire',
    'Table 1: ephemeral herb (exotic); killed by fire'
  )
)

surv1_matched <- match_bionet_taxonomy(surv1_exceptions, 'original_name')
surv1_matched$original_source <- 'Williams Congdon Grice Clarke 2003'

data_long_surv1 <- surv1_matched %>%
  mutate(trait_code = 'surv1')

# 7. Bind all traits
data_long <- bind_rows(data_long_germ8, data_long_surv1)

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

write_csv(records, 'papers/Williams Congdon Grice Clarke 2003/williams_congdon_grice_clarke_2003_records.csv')

database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Williams Congdon Grice Clarke 2003/williams_congdon_grice_clarke_2003_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Williams Congdon Grice Clarke 2003/williams_congdon_grice_clarke_2003_dupes_possible.csv')

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
#   dbExecute(con, paste0("UPDATE litrev.surv1 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
