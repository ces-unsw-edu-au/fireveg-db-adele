library(readxl)

torrington <- read_csv('papers/completed_manually/Clarke Fulloon 1999/fire_and_rare_plants_torrington_state_species_traits.csv')
t1 <- read_excel('data/torrington/torrington_table_14.xlsx')
t2 <- read_excel('data/torrington/torrington_table_15.xlsx')
t <- bind_rows(t1, t2)


torrington <- match_bionet_taxonomy(torrington, 'species')

t <- match_bionet_taxonomy(t, 'Species Name')

torrington <- full_join(torrington, t, by = c('bionet_name', 'species_code', 'taxon_rank'))

# ref
torrington$reference <- 'Clarke P. J, Fulloon Lindsay. Fire and rare plants: Torrington State Recreation Area'
torrington$original_source <- 'Clarke Fulloon 1999'

torrington[torrington == '-'] <- NA

# mutate into traits - not doing repr1 as not a 'priority' trait
torrington <- torrington %>%
  mutate(
    surv5 = gsub("\\s*[A-Za-z]", "", longevity),
    repr3 = gsub("\\s*[A-Za-z]", "", primary_juvenile_period),
    disp1 = case_when(
      str_detect(dispersal, 'ants') ~ 'ant',
      str_detect(dispersal, 'passive') ~ 'passive',
      str_detect(dispersal, 'wind') ~ 'wind-unspec.',
      str_detect(dispersal, 'water') ~ 'water',
      str_detect(dispersal, 'vertebrates') ~ 'animal-ingestion',
      str_detect(dispersal, 'animal') ~ 'animal-unspec.',
    ),
    germ1 = case_when(
      str_detect(`Fire Response`, '1') ~ 'Canopy',
      str_detect(`Fire Response`, '2') ~ 'Soil-persistent'
    ),
    surv4 = case_when(
      str_detect(`Fire Response`, '4') ~ 'Long rhizome or root sucker',
      str_detect(`Fire Response`, '5') ~ 'Basal',
      str_detect(`Fire Response`, '6') ~ 'Epicormic',
      str_detect(`Fire Response`, '7') ~ 'Apical',
    )
  )

# get trait columns
trait_cols <- torrington %>%
  select(surv5:surv4) %>%
  colnames()

trait_map <- tibble::tribble(
  ~trait_code, ~raw_source_col,            ~trait_type,
  "disp1",     "dispersal",            "categorical",
  "surv4",     "Fire Response",              "categorical",
  "germ1",     "Fire Response",         "categorical",
  "repr3",     "primary_juvenile_period",   "numerical",
  "surv5",     "longevity",           "numerical"
)

# pivot longer according to trait code, remove rows where trait code is NA.
torrington_long <- torrington %>%
  pivot_longer(cols = all_of(trait_cols),
               names_to = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value)) %>%
  left_join(trait_map, by = "trait_code")


# assign trait_map by code
torrington_num <- torrington_long %>%
  filter(trait_type == 'numerical') %>%
rowwise() %>%
  mutate(
    best = if (str_detect(norm_value, '^\\d+$')) norm_value else NA,
    lower = if (str_detect(norm_value, '^\\d+\\s*-\\s*\\d+')) str_extract(norm_value, '^\\d+')
    else if (str_detect(norm_value, '^>\\s*\\d+')) str_extract(norm_value, '\\d+')
    else NA,
    upper = if (str_detect(norm_value, '^\\d+\\s*-\\s*\\d+')) str_extract(norm_value, '(?<=-)\\d+')
    else if (str_detect(norm_value, '^<\\s*\\d+')) str_extract(norm_value, '(?<=<\\s)\\d+')
    else NA,
    raw_value = {
      src <- raw_source_col
      val <- cur_data()[[raw_source_col]]
      paste0(src, ", ", val)}) %>%
  ungroup()

torrington_cat <- torrington_long %>%
  filter(trait_type == 'categorical') %>%
  rowwise() %>%
  mutate(
    raw_value = {
      src <- raw_source_col
      val <- cur_data()[[src]]
      paste0(src, ", ", val)}) %>%
  ungroup()

fire_response <- c(
  '1' = 'Propagules remained after fires passage are held as viable canopy-stored seed',
  '2' = 'Propagules remaining after fires passage are held as soil-stored seed',
  '4' = 'Resprout from root suckers or rhizomes',
  '5' = 'Resprout from basal stem buds such as those in lignotubers',
  '6' = 'Resprout from epicormic shoots',
  '7' = 'Regrowth from unharmed usually terminal aerial buds'
)

# replace the fire response codes with their text meaning
torrington_cat$raw_value <- str_replace_all(torrington_cat$raw_value, fire_response)

# combine
torrington_long <- torrington_num %>% bind_rows(torrington_cat)

torrington_records <- torrington_long %>%
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

write_csv(torrington_records, 'papers/completed_manually/Clarke Fulloon 1999/clarke_fulloon_1999_records.csv')
database <- read.csv('database.csv')
dupes <- flag_duplicates(torrington_records, database)
write_csv(dupes$exact_partial, 'papers/completed_manually/Clarke Fulloon 1999/clarke_fulloon_1999_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/completed_manually/Clarke Fulloon 1999/clarke_fulloon_1999_dupes_possible.csv')


