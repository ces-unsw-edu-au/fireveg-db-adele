# Tierney 2006
# Traits: germ8
#
# TRANSCRIPTION NOTES — review before running:
#
# No transcription issues.

library(tidyverse)
source('funx.R')

# 1. Read data
# No CSV — germ8 is exceptions-only (single species from text).
# The exceptions table in mapping.md IS the data.

# 4. Build exceptions tibble and map values to trait vocabulary
germ8_exceptions <- tibble(
  original_name = c('Prostanthera askania'),
  germ8         = c('PD')
)

# 5. Align taxonomy to Bionet
germ8_exceptions <- match_bionet_taxonomy(germ8_exceptions, 'original_name')
germ8_exceptions$original_source <- 'Tierney 2006'

# 6. Pivot to long format
data_long <- germ8_exceptions %>%
  pivot_longer(cols = 'germ8',
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# 7. Construct raw_value
# Source: Results — Seed germination section; Fig. 1; Discussion
data_long <- data_long %>%
  mutate(
    raw_value = 'Results — Seed germination section; Fig. 1; Discussion, High dormancy, partial break by smoke, germination via seed plug'
  )

# 9. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

# germ8 is categorical — add best, lower, upper as NA_real_ (section 8 was skipped)
records <- data_long %>%
  mutate(best  = NA_real_,
         lower = NA_real_,
         upper = NA_real_,
         notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# Save records so combine.R can aggregate across all papers
write_csv(records, 'papers/Tierney 2006/tierney_2006_records.csv')

# Flag duplicates — returns a named list with $exact_partial and $possible
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/Tierney 2006/tierney_2006_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/Tierney 2006/tierney_2006_dupes_possible.csv')

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
