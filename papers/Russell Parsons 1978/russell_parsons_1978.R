# Russell Parsons 1978
# Traits: surv1, rect2
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. ARITHMETIC DISCREPANCY IN PAPER: p. 56 states "Of the 22 woody species
#    recorded at this site [site 5], these latter four species were the only ones
#    definitely establishing only from seeds after fire; 16 species re-established
#    from rootstocks and the status of three species was uncertain." However,
#    4 + 16 + 3 = 23, not 22. The paper's own count of 22 is inconsistent with
#    the breakdown given. It is unclear which species was miscounted.
#
# 2. WOODY SPECIES COUNT: CSV corrected to 22 species matching the paper's stated
#    count. The initial transcription included 27 species by being too liberal about
#    what counts as woody. Six species were removed (Correa reflexa — absent from
#    site 5 entirely; Hibbertia procumbens, H. acicularis, Amperea xiphoclada,
#    Comesperma ericinum, Acrotriche serrulata — not woody per the paper's count)
#    and one was added (Acacia myrtifolia — woody shrub present at site 5 with
#    cover 0.68, overlooked in initial transcription). The paper's arithmetic is
#    internally inconsistent (states 22 total but breakdown is 4+16+3=23); the CSV
#    has 22 species with 15 rootstockers, consistent with the stated total of 22.
#
# 3. SURV1 UNNAMED RESPROUTERS: The 16 resprouter species are not named in the
#    paper text; they are inferred as the woody site-5 species not among the
#    4 obligate seeders or 3 uncertain species named on p. 56. The regeneration
#    mode "re-established from rootstocks" has been assigned to all remaining
#    woody species in the CSV. This is consistent with the mapping.md spec.
#
# 4. RECT2 DATA SOURCE: rect2 records come entirely from the species-level
#    exceptions table in mapping.md (three named species from text, p. 56).
#    No CSV column is needed. Note that mapping.md contains a typo for one
#    species: "Acrotriche serrulate" should be "Acrotriche serrulata" (confirmed
#    by Appendix 1 spelling). The correct spelling is used in this script.
#
# 5. SURV5: mapping.md lists surv5 as "No lifespan data per species" — not
#    approved. No surv5 records are produced.

library(tidyverse)
source('funx.R')

# 1. Read data
data <- read.csv('papers/Russell Parsons 1978/russell_parsons_1978_data.csv')

# 2. No column renaming needed — column names are already clean.

# 3. Clean species names for taxonomy matching
data <- data %>%
  mutate(
    original_name = species %>%
      str_remove("\\s*\\(.*\\)") %>%
      str_remove("\\s+s\\.l\\.$") %>%
      str_trim()
  )

# 4. Map surv1 values
# Species-level exceptions (from mapping.md) go FIRST, before the general mapping.
# The 7 named species (4 obligate seeders, 3 uncertain) are listed as exceptions.
# All remaining species default to their regeneration_mode value.
data <- data %>%
  mutate(
    surv1 = case_when(
      # Obligate seeders — named explicitly on p. 56
      species == 'Hakea sericea'          ~ 'None',
      species == 'Dillwynia glaberrima'   ~ 'None',
      species == 'Dillwynia sericea'      ~ 'None',
      species == 'Marianthus procumbens'  ~ 'None',
      # Uncertain — named explicitly on p. 56
      species == 'Hakea teretifolia'      ~ 'Unknown',
      species == 'Isopogon ceratophyllus' ~ 'Unknown',
      species == 'Pimelea humilis'        ~ 'Unknown',
      # General mapping: remaining species re-established from rootstocks
      regeneration_mode == 're-established from rootstocks' ~ 'All',
      # Fallback (should not be reached given the exceptions above cover all
      # other raw values)
      TRUE ~ NA_character_
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Russell Parsons 1978'

# 6. Pivot surv1 to long format
# rect2 is constructed separately from the exceptions table (no CSV column).

trait_cols <- c('surv1')

data_long_surv1 <- data %>%
  pivot_longer(cols = all_of(trait_cols),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# rect2: three species identified from text (p. 56) as post-fire pioneers or
# restricted to younger stands. Data comes directly from mapping.md exceptions —
# no CSV column exists for this trait.
# "Acrotriche serrulate" in mapping.md is a typo; correct spelling used here.
rect2_species <- tibble(
  species        = c('Xanthosia pusilla', 'Laxmannia sessiliflora', 'Acrotriche serrulata'),
  original_name  = c('Xanthosia pusilla', 'Laxmannia sessiliflora', 'Acrotriche serrulata'),
  norm_value     = c('Intolerant',        'Intolerant',             'Intolerant'),
  trait_code     = 'rect2',
  regeneration_mode = NA_character_
)

rect2_matched <- match_bionet_taxonomy(rect2_species, 'original_name')
rect2_matched$original_source <- 'Russell Parsons 1978'

data_long_rect2 <- rect2_matched %>%
  filter(!is.na(norm_value))

# Combine both traits
data_long <- bind_rows(data_long_surv1, data_long_rect2)

# 7. Construct raw_value
# surv1: source is text (p. 56) and Appendix 1; raw column is "regeneration_mode"
# rect2: source is text (p. 56); no CSV column — raw value is the paper description
data_long <- data_long %>%
  mutate(
    raw_value = case_when(
      trait_code == 'surv1' ~ paste0('regeneration_mode, ', regeneration_mode),
      trait_code == 'rect2' ~ paste0(
        'Text p. 56, ',
        case_when(
          species == 'Xanthosia pusilla'      ~
            'found only in two youngest stands, dense carpets of seedlings immediately after fire',
          species == 'Laxmannia sessiliflora'  ~
            'restricted to three youngest stands, may disappear in long-unburnt heath',
          species == 'Acrotriche serrulata'    ~
            'restricted to three youngest stands, may disappear in long-unburnt heath',
          TRUE ~ NA_character_
        )
      ),
      TRUE ~ NA_character_
    )
  )

# 8. Section 8 skipped — both approved traits (surv1, rect2) are categorical.
# Add best/lower/upper as NA so the final select succeeds.

data_long <- data_long %>%
  mutate(
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  )

# 9. Select final columns
# Report any species that failed Bionet matching before original_name is dropped.
report_unmatched(data_long)

records <- data_long %>%
  mutate(notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates

# Remove rows where species could not be matched to Bionet
records <- records %>%
  filter(!is.na(species_code))

write_csv(records, 'papers/Russell Parsons 1978/russell_parsons_1978_records.csv')

# Flag duplicates
database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Russell Parsons 1978/russell_parsons_1978_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Russell Parsons 1978/russell_parsons_1978_dupes_possible.csv')

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
# }
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.rect2 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
