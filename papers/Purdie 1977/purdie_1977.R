# Purdie 1977
# Traits: surv1, surv4, rect2 (from Appendix 1 Part I); germ8 (exceptions only from Part II)
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. "Hulgosa australis" (NGI): transcribed exactly as printed in Appendix 1. This
#    does not match a known Australian plant genus and will likely fail
#    match_bionet_taxonomy. Manually identify the correct species name before import.
#
# 2. Pimelea species discrepancy: Appendix 1 lists "Pimelea pubescens R.Br." as
#    an FSD species, but the text on p. 29 names "Pimelea linifolia" as one of the
#    three FSD shrubs. The CSV uses the Appendix 1 name (P. pubescens) as that is
#    the source column. Check the original to confirm which name is correct.
#
# 3. UK (unknown regrowth class) species excluded: Cassinia aculeata, C. longifolia,
#    and Omphacomeria acerba appear in Appendix 1 with class "UK" and have been
#    omitted from the CSV as there is no approved norm_value mapping for this class.

library(tidyverse)
source('R/funx.R')

data <- read.csv('papers/Purdie 1977/purdie_1977_data.csv', na.strings = c("", "NA"))

# Clean species names — strip parenthetical remarks and 's.l.' qualifiers
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# surv1 — Resprouting (full canopy scorch)
# FSD = None (100% mortality); T = None (therophytes, no pre-burn vegetative presence)
# NGD/NGI = Most (rootstock-based, high but not always complete survival)
# GD/GI = All (geophytes, underground organs very well protected)
data <- data %>%
  mutate(
    surv1 = case_when(
      regrowth_class == "FSD" ~ "None",
      regrowth_class == "NGD" ~ "Most",
      regrowth_class == "GD"  ~ "All",
      regrowth_class == "NGI" ~ "Most",
      regrowth_class == "GI"  ~ "All",
      regrowth_class == "T"   ~ "None",
      TRUE ~ NA_character_
    )
  )

# surv4 — Regenerative organ
# NGD = rootstocks/root tussocks → Basal
# GD = bulbs → Tuber
# NGI = rootstocks and suckers from lateral roots → Long rhizome or root sucker
# GI = rhizomes → Long rhizome or root sucker
# FSD and T = no vegetative regenerative organ → NA (excluded by filter later)
data <- data %>%
  mutate(
    surv4 = case_when(
      regrowth_class == "NGD" ~ "Basal",
      regrowth_class == "GD"  ~ "Tuber",
      regrowth_class == "NGI" ~ "Long rhizome or root sucker",
      regrowth_class == "GI"  ~ "Long rhizome or root sucker",
      TRUE ~ NA_character_
    )
  )

# rect2 — Establishment pattern
# FSD: seedlings present in burnt plots, absent/rare in unburnt → Intolerant
# NGD/NGI: seedlings present in both burnt and unburnt → Tolerant
# GD, GI, T: insufficient data → NA (excluded by filter later)
data <- data %>%
  mutate(
    rect2 = case_when(
      regrowth_class == "FSD"                    ~ "Intolerant",
      regrowth_class %in% c("NGD", "NGI")        ~ "Tolerant",
      TRUE                                        ~ NA_character_
    )
  )

# Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Purdie 1977'

# Pivot surv1, surv4, rect2 to long format
# filter(!is.na(norm_value)) removes:
#   - surv4 rows where regrowth_class is FSD or T (NA)
#   - rect2 rows where regrowth_class is GD, GI, or T (NA)
data_long <- data %>%
  pivot_longer(cols = c(surv1, surv4, rect2),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# Construct raw_value from regrowth class code
data_long <- data_long %>%
  mutate(
    raw_value = paste0('Regrowth class, ', regrowth_class)
  )

# germ8 — Seed dormancy type (exceptions only from Part II text)
# Four leguminous species show heat-stimulated germination (physical dormancy, PY)
# attributed to fire softening hard seed testas (Part II Discussion, p. 43)
germ8_exceptions <- tibble(
  original_name = c("Acacia genistifolia", "Dillwynia retorta",
                    "Daviesia mimosoides", "Pultenaea procumbens"),
  norm_value    = "PY",
  trait_code    = "germ8",
  raw_value     = "Part II text — heat-stimulated germination"
)
germ8_exceptions <- match_bionet_taxonomy(germ8_exceptions, 'original_name')
germ8_exceptions <- germ8_exceptions %>%
  mutate(original_source = 'Purdie 1977',
         best = NA_real_, lower = NA_real_, upper = NA_real_, notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# Combine all records into standard long format
records <- bind_rows(
  data_long %>%
    mutate(best = NA_real_, lower = NA_real_, upper = NA_real_, notes = coalesce(notes, NA_character_)) %>%
    select(bionet_name, species_code, original_source, trait_code,
           norm_value, best, lower, upper, raw_value, notes),
  germ8_exceptions
)

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# Save records and flag duplicates against database export
write.csv(records, 'papers/Purdie 1977/purdie_1977_records.csv', row.names = FALSE)
#database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)
write.csv(dupes$exact_partial, 'papers/Purdie 1977/purdie_1977_dupes_exact_partial.csv', row.names = FALSE)
write.csv(dupes$possible,      'papers/Purdie 1977/purdie_1977_dupes_possible.csv',      row.names = FALSE)

# SQL block (commented — requires authorisation before running)
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv('DB_NAME'),
#                  host     = Sys.getenv('DB_HOST'),
#                  port     = Sys.getenv('DB_PORT'),
#                  user     = Sys.getenv('DB_USER'),
#                  password = Sys.getenv('DB_PASSWORD'))
# dbWriteTable(con, 'traits', records, append = TRUE, row.names = FALSE)
# dbDisconnect(con)
