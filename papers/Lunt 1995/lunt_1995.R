# Lunt 1995
# Traits: germ1
#
# TRANSCRIPTION NOTES — review before running:
#
# No transcription issues.

library(tidyverse)
source('R/funx.R')

# 1. Build hardcoded tibble from mapping.md exceptions table
# No CSV exists or is needed — all data is in the mapping.md exceptions table.
# germ1 values are inferred from viability data (Table 2) and Discussion:
# Chrysocephalum apiculatum identified as Soil-persistent; all other five species
# described as Transient or short-term persistent.

data <- tibble(
  species = c(
    'Chrysocephalum apiculatum',
    'Arthropodium strictum',
    'Bulbine bulbosa',
    'Burchardia umbellata',
    'Craspedia variabilis',
    'Leptorhynchos squamatus'
  ),
  germ1 = c(
    'Soil-persistent',
    'Transient',
    'Transient',
    'Transient',
    'Transient',
    'Transient'
  )
)

# 2. Clean species names for taxonomy matching
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# 3. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Lunt 1995'

# 4. Pivot to long format
trait_cols <- c('germ1')

data_long <- data %>%
  pivot_longer(cols = all_of(trait_cols),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# 5. Construct raw_value
# Source column: inference from viability data (Table 2) and Discussion
data_long <- data_long %>%
  mutate(
    raw_value = paste0(
      'inference from viability data (Table 2) and Discussion, ',
      norm_value
    )
  )

# 6. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

# germ1 is categorical — add best, lower, upper as NA_real_ (section 8 was skipped)
records <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_,
    notes = coalesce(notes, NA_character_)
  ) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 7. Save records and flag duplicates

# Remove rows where species could not be matched to Bionet — these cannot be imported.
records <- records %>%
  filter(!is.na(species_code))

# Save records so combine.R can aggregate across all papers
write_csv(records, 'papers/Lunt 1995/lunt_1995_records.csv')

# Flag duplicates — returns a named list with $exact_partial and $possible
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/Lunt 1995/lunt_1995_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/Lunt 1995/lunt_1995_dupes_possible.csv')

# SQL to set weight = 0 for exact/partial duplicate records
# Requires record_id in the database export. Run only if authorised to write to the database.
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"), host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"), user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.germ1 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
