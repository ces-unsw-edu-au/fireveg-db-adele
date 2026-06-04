# Morrison Renwick 2000
# Traits: surv1, surv4, germ1
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. Table 1 uses em-dashes (—) to indicate absence of a bud type. These are
#    treated as NA in the multi-value pivot (no record produced for that organ).
#
# 2. surv4: Acacia binervia, Acacia parramattensis, Casuarina littoralis, and
#    Hakea sericea have no buds of any type (all dashes). They will produce no
#    surv4 records after the pivot — this is expected per mapping.md notes
#    (obligate seeders / no vegetative recovery organ).
#
# 3. surv1: Jacksonia scoparia has 0.0% high-intensity survival, mapping to
#    None. This is consistent with mapping.md notes.
#
# 4. germ1: Hakea sericea exception only — no CSV column needed. Value taken
#    directly from the mapping.md exceptions table.
#
# 5. Table 2 stem survival values are means across sampled individuals; the
#    high-intensity fire caused 100% leaf-scorch for all plants (scorch height
#    10–15 m), making it the approved proxy for full canopy scorch (surv1).

library(tidyverse)
source('funx.R')

# 1. Read data
data <- read.csv('papers/Morrison Renwick 2000/morrison_renwick_2000_data.csv')

# 2. Rename source columns to R-friendly names
# Original column names from mapping.md:
#   surv1 source: "Stem survival (%) — High-intensity" (Table 2)
#   surv4 sources: "Stem aerial buds", "Stem basal buds", "Root buds" (Table 1)
# read.csv converts special characters and spaces to dots.
data <- data %>%
  rename(
    stem_survival_hi  = stem_survival_pct_high_intensity,
    aerial_buds       = stem_aerial_buds,
    basal_buds        = stem_basal_buds,
    root_buds         = root_buds
  )

# 3. Clean species names for taxonomy matching
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# 4a. Map surv1 values using the % resprouting thresholds from mapping.md
# No species-level exceptions for surv1.
data <- data %>%
  mutate(
    surv1 = case_when(
      stem_survival_hi == 0.0                                    ~ 'None',
      stem_survival_hi >  0.0 & stem_survival_hi <= 30.0        ~ 'Few',
      stem_survival_hi > 30.0 & stem_survival_hi <= 70.0        ~ 'Half',
      stem_survival_hi > 70.0 & stem_survival_hi <= 90.0        ~ 'Most',
      stem_survival_hi > 90.0                                    ~ 'All',
      TRUE ~ NA_character_
    )
  )

# 4b. Map surv4 organ columns — one column per organ type, presence = mapped
#     norm_value, absence (— or NA) = NA_character_ (no record produced).
# Value mapping from mapping.md:
#   epicormic  -> Epicormic
#   stem base  -> Basal
#   lignotuber -> Lignotuber
#   suckers    -> Long rhizome or root sucker
# No species-level exceptions for surv4.
data <- data %>%
  mutate(
    surv4_epicormic = case_when(
      aerial_buds == 'epicormic' ~ 'Epicormic',
      TRUE ~ NA_character_
    ),
    surv4_basal = case_when(
      basal_buds == 'stem base'  ~ 'Basal',
      basal_buds == 'lignotuber' ~ 'Lignotuber',
      TRUE ~ NA_character_
    ),
    surv4_root = case_when(
      root_buds == 'suckers' ~ 'Long rhizome or root sucker',
      TRUE ~ NA_character_
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Morrison Renwick 2000'

# 6a. Pivot surv1 to long format (single-value trait)
data_long_surv1 <- data %>%
  select(bionet_name, species_code, original_source, original_name,
         stem_survival_hi, surv1, notes) %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0('Stem survival (%) — High-intensity, ', stem_survival_hi)
  )

# 6b. Pivot surv4 to long format (multi-value trait)
# Each organ present for a species produces its own database row.
data_long_surv4 <- data %>%
  pivot_longer(
    cols           = c(surv4_epicormic, surv4_basal, surv4_root),
    names_to       = NULL,
    values_to      = 'norm_value',
    values_transform = as.character
  ) %>%
  filter(!is.na(norm_value)) %>%
  mutate(
    trait_code = 'surv4',
    raw_value  = paste0(
      'Stem aerial buds, ', aerial_buds, '; ',
      'Stem basal buds, ', basal_buds, '; ',
      'Root buds, ', root_buds
    )
  )

# 6c. Build germ1 records directly from mapping.md exceptions table
#     (no CSV column — text-only extraction)
germ1_exceptions <- tibble(
  species       = c('Hakea sericea'),
  norm_value    = c('Canopy'),
  original_name = c('Hakea sericea')
)

germ1_matched <- match_bionet_taxonomy(germ1_exceptions, 'original_name')
germ1_matched$original_source <- 'Morrison Renwick 2000'

data_long_germ1 <- germ1_matched %>%
  mutate(
    trait_code = 'germ1',
    raw_value  = 'qualitative description in text: serotinous canopy-stored seedbank'
  )

# 7. Bind all traits
data_long <- bind_rows(data_long_surv1, data_long_surv4, data_long_germ1)

# 8. Section 8 skipped — all approved traits are categorical.

# 9. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

# All traits are categorical: add best, lower, upper as NA_real_.
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

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# Save records so combine.R can aggregate across all papers
write_csv(records, 'papers/Morrison Renwick 2000/morrison_renwick_2000_records.csv')

# Flag duplicates
database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/Morrison Renwick 2000/morrison_renwick_2000_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/Morrison Renwick 2000/morrison_renwick_2000_dupes_possible.csv')

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
# dbDisconnect(con)
