# Van Moezel Loneragan Bell 1987
# Traits: surv1, repr3, repr3a, repr2, germ1
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. <N / ≤N values (repr3 / repr3a): upper-bound values from the Appendix
#    (e.g. "<4", "≤4") are preserved as "<4" in norm_value so that the
#    best/lower/upper parsing can set upper = 4. ≤N is treated as equivalent to <N.
#    Plain integers (e.g. "2") are point estimates. Resolved — no action needed.
#
# 2. Pimelea suaveolens annotation: there is some uncertainty about whether the
#    annotation ² on one row belongs to P. suaveolens or the adjacent P. sulphurea.
#    Check the original PDF to confirm which species carries the annotation.
#
# 3. repr2 source: the Facultative records for repr2 are derived from the CSV
#    annotation column (values 1 and 2 from Appendix 1 superscripts), superseding
#    the 11 hardcoded exceptions in mapping.md. The CSV-derived list may include
#    additional species not in the mapping.md exceptions table — check both lists match.

library(tidyverse)
source('funx.R')

# Read data
data <- read.csv('papers/Van Moezel Loneragan Bell 1987/van_moezel_1987_data.csv',
                 na.strings = c("", "NA"))

# Clean species names (remove parentheticals, s.l., etc.)
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )


# ≤ in csv are showing as ?
data <- data %>% mutate(juvenile_period = str_replace_all(juvenile_period, "\\?", "≤"))

# --- Map surv1 ---
data <- data %>%
  mutate(
    surv1 = case_when(
      fire_response == "Sprout"         ~ "All",
      fire_response == "Seed"           ~ "None",
      fire_response == "Sprout & Seed"  ~ "Most",
      fire_response == "Seed & Sprout"  ~ "Most",
      TRUE ~ NA_character_
    )
  )

# --- Map repr3 (Seed and Seed & Sprout species only) ---
# Upper bounds (<N, ≤N) are preserved as "<N" in norm_value so the
# best/lower/upper parsing can set upper = N. Plain integers are point estimates.
data <- data %>%
  mutate(
    repr3 = case_when(
      !(fire_response %in% c("Seed", "Seed & Sprout")) ~ NA_character_,
      is.na(juvenile_period)                           ~ NA_character_,
      juvenile_period == "1"                            ~ "1",
      juvenile_period == "2"                            ~ "2",
      juvenile_period %in% c("<2", "≤2")               ~ "<2",
      juvenile_period %in% c("<4>2", "≤4>2")           ~ "2-4",
      juvenile_period %in% c("<5>2", "≤5>2")           ~ "2-5",
      juvenile_period %in% c("<4", "≤4")               ~ "<4",
      juvenile_period %in% c("<5", "≤5")               ~ "<5",
      juvenile_period %in% c("<6", "≤6")               ~ "<6",
      TRUE ~ NA_character_
    )
  )

# --- Map repr3a (Sprout and Sprout & Seed species only) ---
data <- data %>%
  mutate(
    repr3a = case_when(
      !(fire_response %in% c("Sprout", "Sprout & Seed")) ~ NA_character_,
      is.na(juvenile_period)                             ~ NA_character_,
      juvenile_period == "1"                              ~ "1",
      juvenile_period == "2"                              ~ "2",
      juvenile_period %in% c("<2", "≤2")                 ~ "<2",
      juvenile_period %in% c("<4>2", "≤4>2")             ~ "2-4",
      juvenile_period %in% c("<5>2", "≤5>2")             ~ "2-5",
      juvenile_period %in% c("<4", "≤4")                 ~ "<4",
      juvenile_period %in% c("<5", "≤5")                 ~ "<5",
      juvenile_period %in% c("<6", "≤6")                 ~ "<6",
      TRUE ~ NA_character_
    )
  )

# --- Map repr2 (from annotation column — superscripts 1 and 2 on JP values) ---
# Annotation 1 = "Flowering mainly restricted to period 1 or 2 years following fire" -> Facultative
# Annotation 2 = "Flowering restricted to period 2-4 years after fire" -> Facultative
# Annotation 3 = phenological shift only, not used for repr2
data <- data %>%
  mutate(
    repr2 = case_when(
      annotation %in% c(1, 2) ~ "Facultative",
      TRUE ~ NA_character_
    )
  )

# --- Map germ1 (exceptions only — no column from data) ---
germ1_exceptions <- tibble(
  original_name = c("Hakea obliqua", "Eremaea fimbriata", "Beaufortia elegans",
                    "Acacia pulchella", "Kennedia prostrata"),
  germ1 = c("Canopy", "Canopy", "Canopy", "Soil-persistent", "Soil-persistent")
)

# Align taxonomy
data <- match_bionet_taxonomy(data, 'original_name')
germ1_exceptions <- match_bionet_taxonomy(germ1_exceptions, 'original_name')

data$original_source <- 'Van Moezel Loneragan Bell 1987'
germ1_exceptions$original_source <- 'Van Moezel Loneragan Bell 1987'

# --- Pivot surv1, repr3, repr3a, repr2 to long format ---
data_long <- data %>%
  pivot_longer(cols = c(surv1, repr3, repr3a, repr2),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# Construct raw_value
data_long <- data_long %>%
  mutate(
    raw_value = case_when(
      trait_code == 'surv1'  ~ paste0('Fire Response, ', fire_response),
      trait_code == 'repr3'  ~ paste0('Juvenile Period, ', juvenile_period),
      trait_code == 'repr3a' ~ paste0('Juvenile Period, ', juvenile_period),
      trait_code == 'repr2'  ~ paste0('Juvenile Period annotation, ', annotation)
    )
  )

# --- Add germ1 records ---
germ1_long <- germ1_exceptions %>%
  mutate(
    trait_code = 'germ1',
    raw_value  = 'Seedbank description, text'
  ) %>%
  rename(norm_value = germ1)

# Parse numerical norm_values (repr3, repr3a) into best / lower / upper
# norm_value conventions:
#   "2"   → point estimate: best = 2, lower = NA, upper = NA
#   "<4"  → upper bound:    best = 4, lower = NA, upper = 4
#   ">4"  → lower bound:    best = 4, lower = 4,  upper = NA
#   "2-4" → range:          best = 3, lower = 2,  upper = 4
data_long <- data_long %>%
  mutate(
    best = case_when(
      trait_code %in% c('repr3', 'repr3a') & str_detect(norm_value, "^[0-9.]+$") ~
        as.numeric(norm_value),
      TRUE ~ NA_real_
    ),
    lower = case_when(
      trait_code %in% c('repr3', 'repr3a') & str_detect(norm_value, "^>") ~
        as.numeric(str_extract(norm_value, "[0-9.]+")),
      trait_code %in% c('repr3', 'repr3a') & str_detect(norm_value, "-") ~
        as.numeric(str_extract(norm_value, "^[0-9.]+")),
      TRUE ~ NA_real_
    ),
    upper = case_when(
      trait_code %in% c('repr3', 'repr3a') & str_detect(norm_value, "^<") ~
        as.numeric(str_extract(norm_value, "[0-9.]+")),
      trait_code %in% c('repr3', 'repr3a') & str_detect(norm_value, "-") ~
        as.numeric(str_extract(norm_value, "[0-9.]+$")),
      TRUE ~ NA_real_
    )
  )

# Combine all records
records <- bind_rows(
  data_long %>%
    mutate(notes = coalesce(notes, NA_character_)) %>%
    select(bionet_name, species_code, original_source, trait_code,
           norm_value, best, lower, upper, raw_value, notes),
  germ1_long %>%
    mutate(best = NA_real_, lower = NA_real_, upper = NA_real_,
           notes = coalesce(notes, NA_character_)) %>%
    select(bionet_name, species_code, original_source, trait_code,
           norm_value, best, lower, upper, raw_value, notes)
)

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

# Save records
write_csv(records, 'papers/Van Moezel Loneragan Bell 1987/van_moezel_1987_records.csv')

# Flag duplicates
#database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)
write_csv(dupes$exact_partial, 'papers/Van Moezel Loneragan Bell 1987/van_moezel_1987_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Van Moezel Loneragan Bell 1987/van_moezel_1987_dupes_possible.csv')

# SQL block (commented out — requires authorisation)
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"),  host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"),  user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.{trait} SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
