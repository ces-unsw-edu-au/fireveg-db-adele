# Rice Westoby 1981
# Traits: disp1 (myrmecochory — ant dispersal only)
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. "Gahni aspera": transcribed exactly as printed in Appendix 1. This appears
#    to be a typo in the original for Gahnia aspera. Will likely match via
#    match_bionet_taxonomy's suggested-name step, but verify the output.
# ALL GOOD - fixed by match_bionet_taxonomy()
#
# 2. Synonym notation: species names with "(=A. terminalis)" style synonym notes
#    are cleaned by str_remove("\\s*\\(.*\\)") — confirm the resulting name is
#    the accepted name for taxonomy matching.
#ALL GOOD
#
# 3. Coverage: only the 68 "star" (undoubted myrmecochore) species produce records.
#    The 30 "dagger" (possibly myrmecochore) and 163 "unmarked" species are excluded.
#    Dagger species are not imported as they are uncertain; no disp1 value for non-
#    myrmecochores is assigned from this paper.
# ALL GOOD

library(tidyverse)
source('R/funx.R')

data <- read.csv('papers/Rice Westoby 1981/rice_westoby_1981_data.csv',
                 na.strings = c("", "NA"))

# Clean species names
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# disp1 — only star species get a record
data <- data %>%
  mutate(
    disp1 = case_when(
      myrmecochore_status == "star" ~ "ant",
      TRUE ~ NA_character_
    )
  )

# Align taxonomy
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Rice Westoby 1981'

# Pivot to long format (filter removes non-star species)
data_long <- data %>%
  pivot_longer(cols = 'disp1',
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# raw_value
data_long <- data_long %>%
  mutate(
    raw_value = paste0('Appendix 1 myrmecochore status: dispersed by ants ')
  )

records <- data_long %>%
  mutate(best = NA_real_, lower = NA_real_, upper = NA_real_, notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# Save and flag duplicates
write.csv(records, 'papers/Rice Westoby 1981/rice_westoby_1981_records.csv', row.names = FALSE)
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)
write.csv(dupes$exact_partial, 'papers/Rice Westoby 1981/rice_westoby_1981_dupes_exact_partial.csv', row.names = FALSE)
write.csv(dupes$possible,      'papers/Rice Westoby 1981/rice_westoby_1981_dupes_possible.csv',      row.names = FALSE)

# SQL block (commented — requires authorisation)
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(), ...)
