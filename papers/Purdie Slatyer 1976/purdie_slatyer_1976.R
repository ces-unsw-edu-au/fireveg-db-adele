# Purdie Slatyer 1976
# Traits: surv1, surv4, germ8, disp1
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. EUCALYPTUS EXCLUDED FROM surv4: E. macrorhyncha, E. rossii,
#    E. mannifera subsp. maculosa, and E. dives appear as Facultative root
#    resprouters — Fire-resistant decreasers, but the paper does not specify
#    the regenerative organ type for these tree species. They are excluded from
#    surv4 records (norm_value set to NA and filtered out).
#
# 2. germ8 AND disp1 ARE EXCEPTIONS-ONLY: no CSV column is used for these
#    traits. Data come directly from the mapping.md exceptions tables.
#    germ8: Acacia genistifolia, Dillwynia retorta, Daviesia mimosoides —
#    fire stimulates germination via heat-softening of hard seed coats (PY).
#    disp1: species marked with * (wind-dispersed) or + (bird-dispersed) in
#    Table 3 footnote. NOTE: mapping.md lists Cirsium semidecandrum as a
#    wind-dispersal exception, but Appendix II has Cerastium semidecandrum
#    (no * marker) — likely a typo in mapping.md. Hardenbergia violacea
#    does carry a * marker in Table 3 and is included instead.
#
# 3. MODE OF REGENERATION UNKNOWN: Seven species at the bottom of Table 3
#    (Acacia implexa, Cassinia aculeata, C. longifolia, C. quinquefaria,
#    Hydrocotyle sp., Omphacomeria acerba, Opercularia hispida) are listed
#    under "Mode of regeneration unknown". They are included in the CSV but
#    produce NA norm_values for both surv1 and surv4, and are filtered out.
#
# 4. ABBREVIATIONS IN TABLE: Eucalyptus species are abbreviated in Table 3
#    (E. macrorhyncha, etc.). Full names have been restored in the CSV.
#
# 5. PARENTHETICAL SPECIES: Several species appear in brackets in Table 3,
#    indicating rare species for which no seedlings were found. These are
#    included in surv1/surv4 records as their class assignment is not in doubt.

library(tidyverse)
source('R/funx.R')

# 1. Read data
data <- read.csv('papers/Purdie Slatyer 1976/purdie_slatyer_1976_data.csv')

# 2. No column renaming needed — column names are already clean.

# 3. Clean species names for taxonomy matching
#    Strip dispersal markers (* and +) from species names, and remove any
#    parenthetical descriptions.
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove_all("^[*+]+") %>%        # remove leading * or + dispersal markers
      str_remove("\\s*\\(.*\\)") %>%      # remove parenthetical suffixes
      str_trim()
  )

# 4. Map surv1 values from class column
data <- data %>%
  mutate(
    surv1 = case_when(
      class == 'Obligate seed regenerators — Fire-sensitive decreasers' ~ 'None',
      class == 'Therophytes'                                             ~ 'None',
      class == 'Facultative root resprouters — Fire-resistant decreasers' ~ 'All',
      class == 'Facultative root resprouters — Fire-resistant increasers' ~ 'All',
      class == 'Obligate root resprouters — Fire-resistant decreasers'  ~ 'All',
      class == 'Obligate root resprouters — Fire-resistant increasers'  ~ 'All',
      class == 'Mode of regeneration unknown'                           ~ NA_character_,
      TRUE ~ NA_character_
    )
  )

# 5. Map surv4 values from class column
#    Eucalyptus species are excluded (organ type not specified in paper).
eucalyptus_spp <- c(
  'Eucalyptus macrorhyncha',
  'Eucalyptus rossii',
  'Eucalyptus mannifera subsp. maculosa',
  'Eucalyptus dives'
)

data <- data %>%
  mutate(
    surv4 = case_when(
      original_name %in% eucalyptus_spp                                          ~ NA_character_,
      class == 'Facultative root resprouters — Fire-resistant decreasers'        ~ 'Long rhizome or root sucker',
      class == 'Facultative root resprouters — Fire-resistant increasers'        ~ 'Long rhizome or root sucker',
      class == 'Obligate root resprouters — Fire-resistant decreasers'           ~ 'Tuber',
      class == 'Obligate root resprouters — Fire-resistant increasers'           ~ 'Long rhizome or root sucker',
      class == 'Therophytes'                                                     ~ 'None',
      class == 'Mode of regeneration unknown'                                    ~ NA_character_,
      TRUE ~ NA_character_
    )
  )

# 6. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Purdie Slatyer 1976'

# 7. Pivot surv1 and surv4 to long format
data_long_csv <- data %>%
  pivot_longer(cols = c('surv1', 'surv4'),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value)) %>%
  mutate(raw_value = paste0('Class, ', class))

# 8. germ8 exceptions — from mapping.md
#    Fire stimulates germination via heat-softening of hard seed coats (PY)
#    for three leguminous species (text discussion of fire effects on seeds).
germ8_species <- tibble(
  original_name = c(
    'Acacia genistifolia',
    'Dillwynia retorta',
    'Daviesia mimosoides'
  ),
  trait_code = 'germ8',
  norm_value = 'PY',
  raw_value  = 'Text discussion, fire stimulates germination via heat-softening of hard seed coats'
)

germ8_matched <- match_bionet_taxonomy(germ8_species, 'original_name')
germ8_matched$original_source <- 'Purdie Slatyer 1976'

# 9. disp1 exceptions — from Table 3 footnote
#    * = wind-dispersed (wind-hairs), + = bird-dispersed (animal-ingestion)
#    Species marked with * in Table 3 are listed below.
#    Exocarpos cupressiformis is handled via the mapping.md exceptions table
#    (animal-ingestion), included here explicitly.
disp1_species <- tibble(
  original_name     = c(
    'Gnaphalium involucratum',
    'Hypochoeris glabra',
    'Lactuca serriola',
    'Senecio quadridentatus',
    'Sonchus asper',
    'Chondrilla juncea',
    'Hardenbergia violacea',
    'Helichrysum collinum',
    'Hypochoeris radicata',
    'Helichrysum calycina',
    'Exocarpos cupressiformis'
  ),
  dispersal_symbol  = c(
    '*', '*', '*', '*', '*',
    '*', '*', '*', '*', '*',
    '+'
  ),
  trait_code = 'disp1',
  norm_value = c(
    'wind-hairs', 'wind-hairs', 'wind-hairs', 'wind-hairs', 'wind-hairs',
    'wind-hairs', 'wind-hairs', 'wind-hairs', 'wind-hairs', 'wind-hairs',
    'animal-ingestion'
  )
)

disp1_species <- disp1_species %>%
  mutate(raw_value = paste0('Table 3 species footnote, ', dispersal_symbol))

disp1_matched <- match_bionet_taxonomy(disp1_species, 'original_name')
disp1_matched$original_source <- 'Purdie Slatyer 1976'

# 10. Combine all four traits
data_long <- bind_rows(
  data_long_csv,
  germ8_matched,
  disp1_matched
)

# 11. Add best / lower / upper (NA for all — all traits are categorical)
data_long <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  )

# 12. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

records <- data_long %>%
  mutate(notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 13. Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

write_csv(records, 'papers/Purdie Slatyer 1976/purdie_slatyer_1976_records.csv')

# 14. Flag duplicates
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Purdie Slatyer 1976/purdie_slatyer_1976_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Purdie Slatyer 1976/purdie_slatyer_1976_dupes_possible.csv')

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
#   dbExecute(con, paste0("UPDATE litrev.germ8 SET weight = 0 WHERE record_id = ", id))
# }
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.disp1 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
