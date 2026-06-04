# Wark 1997
# Traits: surv1, surv4, repr2 (exceptions only), repr3, repr3a
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. "Tu1" organ code: the table body uses "Tu1" for orchid/lily tuberoids but
#    the Table 5 legend (p. 29) defines the code as "Tu". Both are mapped to Tuber
#    here. Check whether "Tu1" is a consistent variant in the original or a
#    scanning/printing artefact.
#
# 2. Ambiguous first_flowering values in CSV:
#    - "F2(?)" and "F2?" → treated as F2
#    - "F3?" → treated as F3
#    - "F1 or F2" (Centaurium spicatum) → treated as F1 (first value listed)
#    - bare "?" (Clematis aristata, Amyema pendulum) → left blank (no repr3/repr3a record)
#    Check these species in the original PDF if precision matters.
#
# 3. Non-vascular species (lichens, mosses, liverworts) are included in the CSV
#    as they appear in Table 5. They will fail match_bionet_taxonomy and be
#    excluded from records — this is expected behaviour.
#
# 4. Hymenophyllum cupressiforme: recorded as FRR in the CSV but both organ_codes
#    and first_flowering are blank (both columns show "?" in the table). It will
#    produce a surv1 = All record but no surv4 or repr3a record.

library(tidyverse)
source('funx.R')

data <- read.csv('papers/Wark 1997/wark_1997_data.csv', na.strings = c("", "NA"))

# Clean species names
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# surv1
data <- data %>%
  mutate(
    surv1 = case_when(
      regen_strategy == "OSR" ~ "None",
      regen_strategy == "FRR" ~ "Most",
      regen_strategy == "ORR" ~ "All",
      TRUE ~ NA_character_
    )
  )

# repr3 (OSR only)
data <- data %>%
  mutate(
    repr3 = case_when(
      regen_strategy != "OSR" ~ NA_character_,
      first_flowering == "F1" ~ "1",
      first_flowering == "F2" ~ "2",
      first_flowering == "F3" ~ "3",
      TRUE ~ NA_character_
    )
  )

# repr3a (FRR and ORR only)
data <- data %>%
  mutate(
    repr3a = case_when(
      regen_strategy == "OSR" ~ NA_character_,
      first_flowering == "F1" ~ "1",
      first_flowering == "F2" ~ "2",
      first_flowering == "F3" ~ "3",
      TRUE ~ NA_character_
    )
  )

# Align taxonomy
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Wark 1997'

# Pivot surv1, repr3, repr3a to long format
data_long <- data %>%
  pivot_longer(cols = c(surv1, repr3, repr3a),
               names_to = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# raw_value
data_long <- data_long %>%
  mutate(
    raw_value = case_when(
      trait_code == 'surv1'  ~ paste0('Regeneration strategy, ', regen_strategy),
      trait_code == 'repr3'  ~ paste0('First flowering, ', first_flowering),
      trait_code == 'repr3a' ~ paste0('First flowering, ', first_flowering)
    )
  )

# Numerical best/lower/upper for repr3 and repr3a (all single integer values here)
data_long <- data_long %>%
  mutate(
    best  = if_else(trait_code %in% c('repr3', 'repr3a'), as.numeric(norm_value), NA_real_),
    lower = NA_real_,
    upper = NA_real_
  )

# --- surv4: multi-value organ codes ---
# Note: the table uses "Tu1" for orchid tuberoids; the legend defines this code as "Tu".
# Both "Tu" and "Tu1" are mapped to Tuber below.
# Split organ_codes string into one row per code per species
surv4_data <- data %>%
  filter(regen_strategy %in% c("FRR", "ORR")) %>%
  filter(!is.na(organ_codes)) %>%
  mutate(organ_list = str_split(organ_codes, "\\s+")) %>%
  unnest(organ_list) %>%
  mutate(
    surv4 = case_when(
      organ_list == "L1"   ~ "Lignotuber",
      organ_list == "T1"   ~ "Tuber",
      organ_list == "Tu"   ~ "Tuber",
      organ_list == "Tu1"  ~ "Tuber",
      organ_list == "C1"   ~ "Tuber",
      organ_list == "R1"   ~ "Short rhizome",
      organ_list == "R2"   ~ "Short rhizome",
      organ_list == "RSt1" ~ "Stolon",
      organ_list == "Rsk1" ~ "Long rhizome or root sucker",
      organ_list == "St1"  ~ "Basal",
      TRUE ~ NA_character_
    ),
    trait_code = "surv4",
    raw_value  = paste0('Regeneration strategy organ codes, ', organ_list),
    norm_value = surv4,
    best = NA_real_, lower = NA_real_, upper = NA_real_,
    notes = coalesce(notes, NA_character_)
  ) %>%
  filter(!is.na(norm_value)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# repr2 exceptions-only
repr2_exceptions <- tibble(
  original_name    = c("Caladenia menziesii", "Prasophyllum odoratum"),
  norm_value       = c("Facultative", "Facultative"),
  trait_code       = "repr2",
  raw_value        = "Text — fire-stimulated post-fire flowering"
)
repr2_exceptions <- match_bionet_taxonomy(repr2_exceptions, 'original_name')
repr2_exceptions <- repr2_exceptions %>%
  mutate(original_source = 'Wark 1997',
         best = NA_real_, lower = NA_real_, upper = NA_real_, notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# Combine all records
records <- bind_rows(
  data_long %>%
    mutate(notes = coalesce(notes, NA_character_)) %>%
    filter(!is.na(species_code)) %>%
    select(bionet_name, species_code, original_source, trait_code,
           norm_value, best, lower, upper, raw_value, notes),
  surv4_data,
  repr2_exceptions
)

# Save and flag duplicates
write_csv(records, 'papers/Wark 1997/wark_1997_records.csv')
database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)
write_csv(dupes$exact_partial, 'papers/Wark 1997/wark_1997_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Wark 1997/wark_1997_dupes_possible.csv')

# SQL block (commented — requires authorisation)
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(), ...)
# for (id in dupes$exact_partial$record_id) { ... }
