library(tidyverse)
source('R/funx.R')

# read data
data <- read.csv('papers/Clarke Knox 2002/clarke_2002.csv',
                 na.strings = c("", "NA"))

data <- data %>%
  rename(fire_response = Fire.response)

# clean taxon names for taxonomy matching — remove parenthetical ecotype/form descriptions
# and s.l. qualifiers, which are not part of the formal name
data <- data %>%
  mutate(
    original_name = Taxon %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# map surv1 — species-level exceptions checked first, then defaults by fire_response
data <- data %>%
  mutate(
    surv1 = case_when(
      # species-level exceptions
      Taxon == 'Acacia filicifolia'                      ~ 'Few',
      Taxon == 'Leucopogon microphyllus var. pilibundus' ~ 'Few',
      Taxon == 'Rhytidosporum procumbens'                ~ 'Few',
      Taxon == 'Correa reflexa (green perianth)'         ~ 'Most',
      Taxon == 'Daviesia latifolia'                      ~ 'Most',
      Taxon == 'Micromyrtus sessilis'                    ~ 'Most',
      # defaults
      fire_response %in% c('Resprouts', 'Resprouts*', 'Resprout')  ~ 'All',
      fire_response %in% c('Obligate seeder', 'Obligate seeder*')  ~ 'None',
      fire_response == 'Obligate seeder (75%)'           ~ 'Few',   # ~25% survive
      fire_response %in% c('Resprouts/variable', 'Variable',
                            'Obligate seeder/variable')  ~ 'Unknown',
      TRUE ~ NA_character_  # 'Structure' (Kunzea obovata only) — meaning unclear, excluded
    )
  )

# align taxonomy to bionet
data <- match_bionet_taxonomy(data, 'original_name')

data$original_source <- 'Clarke Knox 2002'

# pivot to long format
data_long <- data %>%
  pivot_longer(cols = 'surv1',
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# construct raw_value and flag inferred entries (marked * in source)
data_long <- data_long %>%
  mutate(
    raw_value = paste0('Fire response, ', fire_response),
    notes = if_else(str_detect(fire_response, '\\*'),
                    'Inferred from morphology or sister taxa',
                    NA_character_)
  )

clarke_knox_records <- data_long %>%
  mutate(best  = NA_real_,
         lower = NA_real_,
         upper = NA_real_) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes) %>%
  filter(!is.na(species_code))

# Species appearing in multiple communities with conflicting surv1 values
# (same species classified as both resprouter and obligate seeder in different
# vegetation types in the appendix) are resolved to 'Half'. Raw values from
# both communities are concatenated to document the conflict.
clarke_knox_records <- clarke_knox_records %>%
  group_by(species_code, trait_code) %>%
  mutate(
    norm_value = case_when(
      # None + All or None + Most → Half (contradictory extremes, middle ground)
      n_distinct(norm_value) > 1 &
        any(norm_value == 'None') &
        any(norm_value %in% c('All', 'Most'))             ~ 'Half',
      # None + Few → Few (both indicate limited/no resprouting; Few is more informative)
      n_distinct(norm_value) > 1 &
        any(norm_value == 'None') &
        any(norm_value == 'Few')                           ~ 'Few',
      TRUE ~ first(norm_value)
    ),
    raw_value = if_else(n_distinct(raw_value) > 1,
                        paste(sort(unique(raw_value)), collapse = ' / '),
                        first(raw_value))
  ) %>%
  slice(1) %>%
  ungroup()

# save records for combine.R
write.csv(clarke_knox_records, 'papers/Clarke Knox 2002/clarke_knox_records.csv', row.names = FALSE)

# flag duplicates against database export
database <- read.csv('data/database.csv')
dupes <- flag_duplicates(clarke_knox_records, database)
write.csv(dupes$exact_partial, 'papers/Clarke Knox 2002/clarke_knox_dupes_exact_partial.csv', row.names = FALSE)
write.csv(dupes$possible,      'papers/Clarke Knox 2002/clarke_knox_dupes_possible.csv',      row.names = FALSE)

# SQL to set weight = 0 for duplicate records (requires record_id in database export)
# Uncomment and run only if authorised to write to the database:
# library(DBI)
# library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"),  host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"),  user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv1 SET weight = 0 WHERE record_id = ", id))
# }
