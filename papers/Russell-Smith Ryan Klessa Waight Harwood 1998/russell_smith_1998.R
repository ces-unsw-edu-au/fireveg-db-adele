# Russell-Smith Ryan Klessa Waight Harwood 1998
# Traits: surv1, repr3
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. Callitris intratropica (Rain forest Trees, Obligate seeder): marked with an asterisk (*)
#    in the Appendix, indicating populations outside the study area of two obligate seeder
#    species. No superscript repr3 code is assigned; repr3_code left blank.
#
# 2. Two species were missing from the prior partial CSV and have been added:
#    - Fluegga tirosa (Rain forest Shrubs, Vegetative resprouter) — present in PDF p.845
#      left column between Exocarpus latifolius and Glochidion apodogymum.
#    - Tarenna australis (Rain forest Shrubs, Vegetative resprouter) — present at the
#      bottom of the Rain forest Shrubs vegetative resprouter section on p.845.
#
# 3. Several species names appear to be misspelled or uncertain in the original Appendix;
#    transcribed as printed and flagged here for review:
#    - "Antidema ghesaembilla" / "Antidema parvifolium" — corrected to "Antidesma" (the
#      correct genus, clearly readable in PDF and consistent with family EUP = Euphorbiaceae).
#    - "Grevia DNA7426" — corrected to "Grewia DNA7426" (correct genus spelling).
#    - "Daeasta reclinata" (prior CSV) — corrected to "Daviesia reclinata" (family code FAB
#      = Fabaceae is consistent with Daviesia; likely a scan/OCR artefact).
#    - "Minura macrorhiza" (prior CSV) — corrected to "Minuria macrorhiza" (Asteraceae daisy
#      genus; typo in prior transcription).
#    - "Sebastiana chamelauceaen" (prior CSV) — corrected to "Sebastiania chamelaeucean"
#      (Euphorbiaceae genus; the terminal epithet remains uncertain — transcribed as printed).
#    - "Tephrosia congsicua" (prior CSV) — corrected to "Tephrosia conspicua" (clear
#      misspelling; corrected to standard spelling).
#    - "Cryptiandra DNA131164" (prior CSV) — corrected to "Cryptandra DNA131164"
#      (Rhamnaceae genus; extra 'i' removed).
#    - "Jacksonia DNA45829" (prior CSV) — corrected to "Jacksonia DNA445829" (prior CSV
#      was missing a digit; consistent with the Obligate seeder Jacksonia DNA445829 and
#      distinct from the Vegetative resprouter Pittrodia DNA445829 — note that both share
#      the code 445829 but different genera; transcribed as printed).
#    - "Hibiscus holtserrica" (prior CSV) — corrected to "Hibiscus holoserica" (transcribed
#      as printed in PDF; may be "Hibiscus holoserica" or "holserrica" — flagged for review).
#    - "Psychotria loncerates" — uncertain spelling; transcribed as printed. Likely
#      "Psychotria lanceolaris" or "Psychotria longicornis" — flagged for review.
#    - "Lisistoina inermis" — uncertain; transcribed as printed. May be a DNA specimen name.
#    - "Calytrix achueta" — may be "Calytrix achaeta"; transcribed as printed.
#    - "Calytrix sericiflorae" — may be "Calytrix sericea" or another epithet; transcribed
#      as printed.
#    - "Corymbacea lateriflora" — may be "Corymbaea lateriflora" or "Gymnostachys lateriflora";
#      transcribed as printed.
#    - "Gonocarpus leptothecea" — may be "Gonocarpus leptothecus"; transcribed as printed.
#    - "Homalocalyx ericaeus" — may be "Homalocalyx ericeus"; transcribed as printed.
#    - "Pittrodia jamesii", "Pittrodia terrifolia", "Pittrodia DNA445829",
#      "Pittrodia grandisepala", "Pittrodia angustisepala" — some of these may be
#      "Prostanthera" or other Lamiaceae; transcribed as printed.
#    - "Acacia sericiflorae" — may be "Acacia sericea" or another epithet; transcribed as
#      printed (distinct from Calytrix sericiflorae above).
#    - "Acacia ambelata" — may be "Acacia ambleta" or "Acacia ambelata"; transcribed as
#      printed.
#    - "Boronia kamagiona" — uncertain; transcribed as printed.
#    - "Calycoptepas collinus" — uncertain genus; transcribed as printed.
#    - "Acacia cataruae" — uncertain; transcribed as printed.
#    - "Acacia multisilliqua" — likely "Acacia multisilliqua" or "Acacia multisiligua";
#      transcribed as printed.
#    - "Leptosoima villosam" — uncertain; may be "Leptosema villosum"; transcribed as
#      printed.
#    - "Stemodia lybrifolia" — may be "Stemodia lythrifolia"; transcribed as printed.
#    - "Tephrosia spechii" — may be "Tephrosia spechtii"; transcribed as printed.
#    - "Pachymena sphaerandrum" — uncertain; transcribed as printed.
#    - "Solanum angulata" and "Solanum villosam" appear in the Obligate seeders section
#      of Woodland/heath Shrubs; transcribed as printed.
#    - "Leucopogon acuminata" appears as an Obligate seeder; transcribed as printed.
#    - "Myrtella DNA13407" and "Myrtella DNA16369" — DNA codes may be truncated (e.g.
#      DNA130407, DNA163690); transcribed as printed.
#    - "Acacia protantha" — repr3 code 4 assigned; check if superscript is 4.
#    - "Jacksonia DNA445829" appears in both Vegetative resprouter (Pittrodia DNA445829)
#      and Obligate seeder sections — note these are different genera (Pittrodia vs
#      Jacksonia) sharing the same DNA specimen number; both retained as printed.
#
# 4. The Appendix key note on Callitris intratropica (asterisk *) states it represents
#    populations outside the study area; it is listed as Obligate seeder. Because the
#    asterisk is not a superscript code 1–5, no repr3 value is assigned.

library(tidyverse)
source('funx.R')

data <- read.csv('papers/Russell-Smith Ryan Klessa Waight Harwood 1998/russell_smith_1998_data.csv',
                 na.strings = c("", "NA"))

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
      regen_type == "Vegetative resprouter" ~ "All",
      regen_type == "Obligate seeder"       ~ "None",
      TRUE ~ NA_character_
    )
  )

# repr3 (obligate seeders only)
data <- data %>%
  mutate(
    repr3 = case_when(
      regen_type != "Obligate seeder" ~ NA_character_,
      is.na(repr3_code)               ~ NA_character_,
      repr3_code == 1 ~ "1",
      repr3_code == 2 ~ "2",
      repr3_code == 3 ~ "3",
      repr3_code == 4 ~ "4",
      repr3_code == 5 ~ "5",
      TRUE ~ NA_character_
    )
  )

# Align taxonomy
data <- match_bionet_taxonomy(data, 'original_name')
data$original_source <- 'Russell-Smith Ryan Klessa Waight Harwood 1998'

# Pivot to long format
data_long <- data %>%
  pivot_longer(cols = c(surv1, repr3),
               names_to  = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# raw_value
data_long <- data_long %>%
  mutate(
    raw_value = case_when(
      trait_code == 'surv1' ~ paste0('Appendix ', vegetation_type, ' — ', regen_type,
                                     if_else(!is.na(regen_codes),
                                             paste0(' (', regen_codes, ')'), '')),
      trait_code == 'repr3' ~ paste0('Appendix repr3 code, ', repr3_code)
    )
  )

# best/lower/upper for numerical repr3
data_long <- data_long %>%
  mutate(
    best  = if_else(trait_code == 'repr3', as.numeric(norm_value), NA_real_),
    lower = NA_real_,
    upper = NA_real_
  )

records <- data_long %>%
  mutate(notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# Remove rows where species could not be matched to Bionet,
# and drop genus-level matches (e.g. 'Boronia spp.') — multiple source species
# with DNA accession codes all resolve to the same genus entry, producing
# spurious duplicates with conflicting or identical trait values.
records <- records %>%
  filter(!is.na(species_code)) %>%
  filter(!str_detect(coalesce(bionet_name, ''), '\\bspp\\.'))

# Save and flag duplicates
write.csv(records,
          'papers/Russell-Smith Ryan Klessa Waight Harwood 1998/russell_smith_1998_records.csv',
          row.names = FALSE)
database <- read.csv('database.csv')
dupes <- flag_duplicates(records, database)
write.csv(dupes$exact_partial,
          'papers/Russell-Smith Ryan Klessa Waight Harwood 1998/russell_smith_1998_dupes_exact_partial.csv',
          row.names = FALSE)
write.csv(dupes$possible,
          'papers/Russell-Smith Ryan Klessa Waight Harwood 1998/russell_smith_1998_dupes_possible.csv',
          row.names = FALSE)

# SQL block (commented — requires authorisation)
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"),  host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"),  user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv1 SET weight = 0 WHERE record_id = ", id))
# }
