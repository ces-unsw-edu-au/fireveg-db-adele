# Kirkpatrick 1984
# Traits: surv1, rect2
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. "Oleria ledifolia" (line 26 of CSV) is likely a typo for "Olearia ledifolia".
#    match_bionet_taxonomy may not resolve it — check report_unmatched output.
#
# 2. Species with "spp." suffix (Danthonia spp., Deyeuxia spp., Agrostis spp.,
#    Oreobolus spp., Gnaphalium spp., Luzula spp.) will not match to Bionet
#    and will be dropped. This is expected — spp. entries cannot be imported.
#
# 3. surv1 mapping: RC 1/2/4 → None (killed by fire); RC 3 → Half (resprout
#    but fail to attain pre-fire cover); RC 5 → All (full vegetative recovery).
#    RC 3 → Half is a cover-based inference, not a direct survival count. See
#    mapping.md notes for full class definitions.
#
# 4. rect2 mapping: RC 4 → Intolerant (fire-stimulated seedling establishment,
#    greater cover in burned areas); RC 5 → Tolerant (present at equal or
#    greater levels in both burned and unburned). RC 1/2/3 excluded (insufficient
#    evidence to classify seedling recruitment pattern from RC alone).
#
# 5. 24 surv1 records already in the database for this source. Many are likely
#    from RC 1 (None) or RC 5 (All) species. flag_duplicates will identify
#    overlaps; RC 3 (Half) records are new and unlikely to duplicate.
#    rect2 has no existing records for this source.

library(tidyverse)
source('R/funx.R')

# 1. Read data
data <- read.csv('papers/Kirkpatrick 1984/kirkpatrick_1984_data.csv',
                 na.strings = c("", "NA"))

# 2. No rename needed — column names already clean.

# 3. No name cleaning needed — species names are clean binomials.
#    match_bionet_taxonomy handles trailing author abbreviations internally.

# 4. Map trait values
data <- data %>%
  mutate(
    surv1 = case_when(
      RC %in% c(1, 2, 4) ~ 'None',
      RC == 3             ~ 'Half',
      RC == 5             ~ 'All',
      TRUE                ~ NA_character_
    ),
    rect2 = case_when(
      RC == 4 ~ 'Intolerant',
      RC == 5 ~ 'Tolerant',
      TRUE    ~ NA_character_   # RC 1/2/3 excluded — insufficient evidence
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'species')
data$original_source <- 'Kirkpatrick 1984'

# 6a. Build surv1 long-format records
data_long_surv1 <- data %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0('RC', RC, ' (', family, ')')
  )

# 6b. Build rect2 long-format records
data_long_rect2 <- data %>%
  filter(!is.na(rect2)) %>%
  mutate(
    trait_code = 'rect2',
    norm_value = rect2,
    raw_value  = paste0('RC', RC, ' (', family, ')')
  )

# 7. Bind all traits
data_long <- bind_rows(data_long_surv1, data_long_rect2)

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

write_csv(records, 'papers/Kirkpatrick 1984/kirkpatrick_1984_records.csv')

database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Kirkpatrick 1984/kirkpatrick_1984_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Kirkpatrick 1984/kirkpatrick_1984_dupes_possible.csv')

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
#   dbExecute(con, paste0("UPDATE litrev.rect2 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
