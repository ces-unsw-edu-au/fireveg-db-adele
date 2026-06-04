# Auld 1991
# Traits: surv1, germ8
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. Several species appear twice in the CSV with population suffixes:
#    Acacia myrtifolia (1)/(2), Acacia suaveolens (1)/(2),
#    Acacia terminalis (1)/(2), Acacia ulicifolia (1)/(2).
#    Platytobium formosum appears as "Platytobium formosum OR" and
#    "Platytobium formosum BL" (site codes, not taxonomy).
#    All population suffixes and site codes are stripped in step 3.
#    Both instances share the same fire_response value so distinct() at
#    step 10 collapses them to one record per species.
#
# 2. surv1 mapping includes uncertain codes per mapping.md:
#    FS;R? -> Few, R? -> Few, FS;R -> Most.
#    FS? (Dillwynia brunioides only) maps to NA — no surv1 record produced
#    for this species. It still receives a germ8 record.
#
# 3. germ8 = PY for all 35 species. The paper explicitly states dormancy in
#    all study species (Fabaceae) is physical (hard seed coat, impermeable to
#    water), broken by heat during fire. Applied as a family-level inference;
#    no CSV column needed.
#
# 4. 27 surv1 records already in the database for this source. flag_duplicates
#    will identify these for retirement.

library(tidyverse)
source('funx.R')

# 1. Read data
data <- read.csv('papers/Auld 1991/auld_1991_fire_response.csv',
                 na.strings = c("", "NA"))

# 2. No rename needed — column names already clean.

# 3. Clean species names: strip population suffixes (1)/(2) and site codes OR/BL
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+(OR|BL)$") %>%
      str_trim()
  )

# 4. Map surv1 values per mapping.md
data <- data %>%
  mutate(
    surv1 = case_when(
      fire_response == 'FS'    ~ 'None',
      fire_response == 'R'     ~ 'All',
      fire_response == 'FS;R?' ~ 'Few',
      fire_response == 'R?'    ~ 'Few',
      fire_response == 'FS;R'  ~ 'Most',
      fire_response == 'FS?'   ~ NA_character_,
      TRUE                     ~ NA_character_
    ),
    # germ8: PY for all species (Fabaceae physical dormancy)
    germ8 = 'PY'
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Auld 1991'

# 6a. Build surv1 long-format records
data_long_surv1 <- data %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0('Probable fire response, ', fire_response)
  )

# 6b. Build germ8 long-format records (all species)
data_long_germ8 <- data %>%
  mutate(
    trait_code = 'germ8',
    norm_value = germ8,
    raw_value  = 'Fabaceae; paper states all study species have hard seed coat physical dormancy broken by heat'
  )

# 7. Bind all traits
data_long <- bind_rows(data_long_surv1, data_long_germ8)

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
records <- records %>%
  filter(!is.na(species_code)) %>%
  distinct()  # collapses identical records from same-species population duplicates

write_csv(records, 'papers/Auld 1991/auld_91_records.csv')

database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Auld 1991/auld_91_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Auld 1991/auld_91_dupes_possible.csv')

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
#   dbExecute(con, paste0("UPDATE litrev.germ8 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
