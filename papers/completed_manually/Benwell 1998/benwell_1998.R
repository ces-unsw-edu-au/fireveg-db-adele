# Benwell 1998
# Traits: germ1 (original), surv1 (added)
#
# TRANSCRIPTION NOTES:
#
# 1. surv1 mapping uses fire_response codes:
#    OSR-* (Obligate Seeder types) -> None
#    FR-*, OR-*, R (all resprouter types) -> All
#    Entries with '?' (FR-6/9?, FR-7?, FR-6?, OR-10 ?) are excluded —
#    the ? indicates uncertain classification in the paper.
#
# 2. Four species appear twice in the CSV with conflicting fire codes across
#    habitats — these will produce conflicting surv1 records (None + All) and
#    will be flagged by check_records as within-paper duplicates:
#      Coleocarya gracilis: OSR-1 (T5) vs FR-7 (HH 2 yr)
#      Mitrasacme polymorpha: OSR-1 vs FR-4
#      Pimelea linifolia: OSR-1 vs FR-4
#      Pseudanthus orientalis: OSR-1 vs FR-4
#    These reflect genuine habitat-level variation in the paper, not
#    transcription errors. Review before importing.
#
# 3. OR-10, OR-11, and R categories are mapped to surv1 = All but have no
#    germ1 assignment (no seedbank type recorded for obligate resprouters).

# load libraries
library(tidyverse)
library(APCalign)

benwell_data <- read_csv('papers/completed_manually/Benwell 1998/benwell_1998.csv')

# replace the abbreviated genera with full name (run this four times)
benwell_data <- benwell_data %>%
  mutate(genus = if_else(str_detect(species, "^[A-Z]\\."),
                         word(lag(species), 1),
                         word(species, 1)),
         species = str_replace(species, "^[A-Z]\\.", genus)
  )

# remove (2 yrs etc) from data and Alphabet keys at end of species name
benwell_data$original_name <- benwell_data$species %>%
  str_remove("\\(.*") %>%
  str_remove("[A-Z]\\s*$")

benwell_data <- match_bionet_taxonomy(benwell_data, 'original_name')

benwell_data <- benwell_data %>%
  mutate(
    germ1 = case_when(
      fire_response %in% c('OSR-1','FR-4','FR-7') ~ 'Soil-persistent',
      fire_response %in% c('OSR-2','FR-5','FR-8') ~ 'Canopy',
    ),
    surv1 = case_when(
      str_detect(fire_response, '\\?')                                     ~ NA_character_,
      str_detect(fire_response, '^OSR')                                    ~ 'None',
      str_detect(fire_response, '^FR') | str_detect(fire_response, '^OR') |
        fire_response == 'R'                                               ~ 'All',
      TRUE                                                                 ~ NA_character_
    )
  )

benwell_data$original_source <- 'Benwell 1998'

benwell_data_long <- benwell_data %>%
  pivot_longer(cols = c(germ1, surv1),
               names_to = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value)) %>%
  rowwise() %>%
  mutate(
    raw_value = {
      src <- 'fire_response'
      val <- cur_data()[[src]]
      paste0(src, ", ", val)}) %>%
  ungroup() %>%
  select(bionet_name, species_code, original_source, trait_code, norm_value, raw_value)

benwell_data_long$trait_type <- 'categorical'

benwell_records <- benwell_data_long %>%
mutate(
    best = ifelse(trait_type == 'categorical', NA, as.numeric(best)),
    lower = ifelse(trait_type == 'categorical', NA, as.numeric(lower)),
    upper = ifelse(trait_type == 'categorical', NA, as.numeric(upper)),
    norm_value = ifelse(trait_type == 'numerical', NA, norm_value)
  ) %>%
  select(
    bionet_name, species_code, original_source, trait_code,
    norm_value, best, lower, upper, raw_value
  )

# write records
write_csv(benwell_records, 'papers/completed_manually/Benwell 1998/benwell_1998_records.csv')

database <- read.csv('data/database.csv')

dupes <- flag_duplicates(benwell_records, database)
# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/completed_manually/Benwell 1998/benwell_1998_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/completed_manually/Benwell 1998/benwell_1998_dupes_possible.csv')
