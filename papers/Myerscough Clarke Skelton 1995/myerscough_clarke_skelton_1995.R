# Myerscough Clarke Skelton 1995
# Traits: surv1, surv4, germ1
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. FIRE REGENERATION SYNDROMES: Appendix II lists fire response syndromes using
#    Roman numerals (II, IV, V, VI, VII) following Gill & Bradstock (1992). These
#    map directly to integer categories 2, 4, 5, 6, 7. Categories 1, 3, 8, 9 do
#    not appear in this dataset. The paper reports seven classes of fire-response
#    syndromes (I–VII); see Gill & Bradstock (1992) for full definitions.
#
# 2. CATEGORY 9 (surv4): No species in this dataset have category 9. Category 9
#    maps to NA for surv4 (organ unknown) — no surv4 record would be produced.
#    This logic is included in the mapping for completeness.
#
# 3. GERM1 — OBLIGATE SEEDERS ONLY: germ1 is extracted only for obligate seeders
#    (fire regeneration syndromes 1–3). Categories 4–9 are resprouters or have
#    mixed strategies; germ1 does not apply. In this dataset only category 2
#    (non-canopy seed storage) produces germ1 records.
#
# 4. EXCLUDED SPECIES: Two species with "?" fire response (Caustis recurvata,
#    Conospermum taxifolium) and "Sp. Monocot a" (also "?") are excluded —
#    no syndrome value was assigned in the paper.
#
# 5. SPELLING: Species names are transcribed exactly as printed in Appendix II.
#    Notable: "Xanthosida pilosa" (Apiaceae) appears to be a variant spelling of
#    Xanthosia pilosa; "Eriastemon australasius" is the 1995 name for what is
#    now Philotheca australasica; "Mtrasacme polymorpha" is a likely printing
#    error for Mitrasacme polymorpha. Bionet taxonomy matching will handle
#    synonymy. "Sp. Monocot b" (category IV) is included as it has a valid
#    syndrome but will not match Bionet and will be filtered out.

library(tidyverse)
source('R/funx.R')

# 1. Read data
data <- read.csv('papers/Myerscough Clarke Skelton 1995/myerscough_clarke_skelton_1995_data.csv')

# 2. No column renaming needed — column names are already clean.

# 3. Clean species names for taxonomy matching
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# 4. Map fire_regen_syndrome to trait values
# surv1: adult plant survival after fire
# surv4: regenerative organ used for resprouting
# germ1: seed storage location (obligate seeders only; NA for resprouters)
#
# Mapping rules (from mapping.md):
#   surv1:  1–3 → None;  4–7 → All;  8 → None;  9 → All
#   surv4:  1–3 → None;  4 → Long rhizome or root sucker;  5 → Basal;
#           6 → Epicormic;  7 → Apical;  8 → None;  9 → NA (unknown)
#   germ1:  1 → Canopy;  2 → Non-canopy;  3 → Transient;  4–9 → NA (not applicable)

data <- data %>%
  mutate(
    surv1 = case_when(
      fire_regen_syndrome %in% c(1, 2, 3) ~ 'None',
      fire_regen_syndrome %in% c(4, 5, 6, 7, 9) ~ 'All',
      fire_regen_syndrome == 8 ~ 'None',
      TRUE ~ NA_character_
    ),
    surv4 = case_when(
      fire_regen_syndrome %in% c(1, 2, 3) ~ 'None',
      fire_regen_syndrome == 4 ~ 'Long rhizome or root sucker',
      fire_regen_syndrome == 5 ~ 'Basal',
      fire_regen_syndrome == 6 ~ 'Epicormic',
      fire_regen_syndrome == 7 ~ 'Apical',
      fire_regen_syndrome == 8 ~ 'None',
      fire_regen_syndrome == 9 ~ NA_character_,  # organ unknown — no record
      TRUE ~ NA_character_
    ),
    germ1 = case_when(
      fire_regen_syndrome == 1 ~ 'Canopy',
      fire_regen_syndrome == 2 ~ 'Soil-persistent',
      fire_regen_syndrome == 3 ~ 'Transient',
      fire_regen_syndrome %in% c(4, 5, 6, 7, 8, 9) ~ NA_character_,  # resprouters
      TRUE ~ NA_character_
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Myerscough Clarke Skelton 1995'

# 6. Pivot all three trait columns to long format
trait_cols <- c('surv1', 'surv4', 'germ1')

data_long <- data %>%
  pivot_longer(cols = all_of(trait_cols),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# 7. Construct raw_value
# All traits derive from the fire_regen_syndrome column in Appendix II.
data_long <- data_long %>%
  mutate(
    raw_value = paste0('Fire regeneration syndrome, ', fire_regen_syndrome)
  )

# 8. Section 8 skipped — all three approved traits are categorical.
# Add best/lower/upper as NA so the final select succeeds.
data_long <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  )

# 9. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

records <- data_long %>%
  mutate(notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

write_csv(records, 'papers/Myerscough Clarke Skelton 1995/myerscough_clarke_skelton_1995_records.csv')

# Flag duplicates
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Myerscough Clarke Skelton 1995/myerscough_clarke_skelton_1995_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Myerscough Clarke Skelton 1995/myerscough_clarke_skelton_1995_dupes_possible.csv')

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
# }
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv4 SET weight = 0 WHERE record_id = ", id))
# }
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.germ1 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
