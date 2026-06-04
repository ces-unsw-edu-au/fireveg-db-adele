# load libraries
library(tidyverse)
library(APCalign)
source('funx.R')

# read data
data <- read.csv('papers/completed_manually/Keith 1991/dharawal_84_89.csv',
                 na.strings = c("x", "."))  # use read.csv bc read_csv reads the f values as logical FALSE and change x and . values (not applicable and no data) to NA values
traits <- read_csv('papers/completed_manually/Keith 1991/dharawal_84_89_traits.csv')[1:17, ]
species <- read_csv('papers/completed_manually/Keith 1991/dharawal_84_89_species.csv')

# re-name columns
colnames(data)[1] <- 'original_species_code'
colnames(traits)[4] <- 'maps_to'

# rename trait names to give descriptive colnames
traits$Name <- sub('^.* - ', '', traits$Name)
traits$Name <- gsub(' ', '_', traits$Name)

#create name map
name_map <- setNames(traits$Name, traits$Code)

# apply names to columns
colnames(data) <- ifelse(
  colnames(data) %in% names(name_map),
  name_map[colnames(data)],
  colnames(data)
)

# remove the (FAMILY) from the species names
species <- species %>%
  mutate(species = str_remove(.[[2]], "\\s*\\(.*\\)"))

# add full species names to data df as first col
data <- data %>%
  left_join(species[, c('Spp code', 'species')],
            by = c('original_species_code' = "Spp code")) %>%
  relocate(species, .before = 1) # make first col

# align species with current names in Australian Plant Census using APCAlign

data <- match_bionet_taxonomy(data, 'species')
# Baumea gunnii --> Machaerina gunnii according to plantNet
# Lepidosperma flexuosa   ---> grouped with Lepidosperma filiforme according to plantNet

# add family column data as some interpretations depend on family
data <- data %>%
  mutate(family = get_apc_genus_family_lookup(word(data$bionet_name, 1)) %>%
           pull(family)) %>%
  relocate(family, .before = 4)

# map original values to fire trait values based on given key
data <- data %>%
  mutate(
    surv1 = case_when(
      vegetative_recovery == 'o' & original_species_code %in% c("Acacrubi", "Pimelini", "Vimijunc") ~ "Few",
      vegetative_recovery == 'o' ~ 'None'
    ),
    surv2 = case_when(
      fire_avoidance == 'a'~ 'Stem survival & no resprouting',
      fire_avoidance == 'n' & vegetative_recovery == 'o' ~ 'Stem mortality & no resprouting'
    ),
    surv3 = case_when(
      fire_avoidance == 'a' ~ 'Few',
      fire_avoidance == 'n' & vegetative_recovery =='o' ~ "None"
    ),
    germ1 = case_when(
      propagule_storage == 'c' ~ 'Canopy',
      propagule_storage == 's' ~ 'Soil-persistent',
      propagule_storage == 'n' ~ 'Non-canopy'
    ),
    germ2 = case_when(
      heat_response == 'h' ~ 'Yes',
      heat_response == 'l' ~ 'No'
    ),
    germ4 = case_when(
      dormancy_mechanism == 'f' ~ 'Either'
    ),
    # no records have values over 90
    #germ8 = case_when(
    #  non_dormant_seed_fraction > 90 ~ 'Non-dormant'
    #),
    germ10 = case_when(
      spontaneous_release_of_seed == 'v' ~ 'Exhausted when ground fuel partially consumed'
    ),
    repr2 = case_when(
      fruit_production == 'e' ~ 'Exclusive',
      fruit_production == 'f' ~ 'Facultative',
      fruit_production == 'n' ~ 'Negligible'
    ),
    repr3 = as.numeric(str_extract(primary_juvenile_period, "(?<=\\()\\d+(?=-)")), # extract min value from median (min - max)
    repr3a = secondary_juvenile_period, # notes say use median, only one value is listed?
    surv5 = case_when(
      plant_longevity == 1 ~ '1-5',
      plant_longevity == 2 ~ '5-20',
      plant_longevity == 3 ~ '21-60',
      plant_longevity == 4 ~ '>60',
      plant_longevity == 5 ~ NA_character_  # indefinite — no numerical value assignable
    )
  ) %>%
  # mutate surv4, several applicable values, must do rowwise
  rowwise() %>%
  mutate(
    surv4 = list(c(
      if (!is.na(vegetative_spread) && vegetative_spread == "i")  "Long rhizome or root sucker",
      if (!is.na(vegetative_spread) && vegetative_spread == "cd") "Short rhizome",
      if (!is.na(bud_location) && bud_location == "e")  "Epicormic",
      if (!is.na(bud_type) && bud_type == "a")  "Apical"
    ))
  ) %>%
  ungroup() %>%
  unnest(surv4, keep_empty = TRUE)

# apply the full raw value to the data df to be used for raw_value later

# create parse function to separate different definitions from traits$Values
parse_values <- function(x) {
  if (!grepl("^[a-z]+-", x)) return(NULL) # only applies to strings which start with 'lowercase digit -'

  keys <- strsplit(x, ",\\s*")[[1]]
  values <- strsplit(keys, "\\s*-\\s+")
  setNames(
    sapply(values, `[`, 2),
    sapply(values, `[`, 1)
  )
}

# create map for definitions, keyed to the traits$Code (colnames(data))
parse_map <- setNames(
  lapply(traits$Values, parse_values),
  traits$Name)


# apply across all rows in data, leaving those that don't have a parse key
for (i in seq_len(nrow(traits))) {

  name <- traits$Name[i]

  if (!name %in% colnames(data)) next

  map <- parse_values(traits$Values[i])

  data[[name]] <- map[data[[name]]]
}

data$reference <- 'Keith, D. A. (1991). Coexistence and species diversity in upland swamp vegetation: the roles of an environmental gradient and recurring fires. PhD thesis, University of Sydney'
data$original_source <- 'Keith 1991'

# get trait columns
trait_cols <- data %>%
  select(surv1:surv4) %>%
  colnames()

# pivot longer according to trait code, remove rows where trait code is NA.
data_long <- data %>%
  pivot_longer(cols = all_of(trait_cols),
               names_to = 'trait_code',
               values_to = 'norm_value',
               values_transform = as.character) %>%
  filter(!is.na(norm_value))

# filter only priority traits for now
data_long <- data_long %>%
  filter(trait_code %in% c('germ1', 'germ8', 'grow1', 'surv1', 'surv4', 'surv5', 'surv6', 'surv7', 'rect2', 'repr2', 'repr3', 'repr3a', 'repr4', 'disp1'))

# create a trait map, raw sources for norm values and type
trait_map <- tibble::tribble(
  ~trait_code, ~raw_source_col,            ~trait_type,
  "surv1",     "vegetative_recovery",      "categorical",
  "surv2",     "fire_avoidance",            "categorical",
  "surv3",     "fire_avoidance",            "categorical",
  "surv4",     c("vegetative_spread",
                 "bud_location",
                 "bud_type"),              "categorical",
  "germ1",     "propagule_storage",         "categorical",
  "germ2",     "heat_response",             "categorical",
  "repr2",     "fruit_production",         "categorical",
  "repr3",     "primary_juvenile_period",   "numerical",
  "repr3a",    "secondary_juvenile_period", "numerical",
  "surv5",     "plant_longevity",           "numerical"
)

# assign trait_map by code
data_long <- data_long %>%
  left_join(trait_map, by = "trait_code")

# categorical long df
# remove surv4 as this will be handled differently due to being sourced from different raw values
data_long_cat <- data_long %>%
  filter(trait_type == 'categorical') %>%
  filter(trait_code != 'surv4') %>%
  rowwise() %>%
  mutate(
    raw_value = {
      src <- raw_source_col
      val <- cur_data()[[src]]
      paste0(src, ", ", val)}) %>%
  ungroup()

# surv4
data_long_surv4 <-
  data_long %>%
  filter(trait_code == 'surv4') %>%
  rowwise %>%
  mutate(
    raw_value = {
      if (norm_value %in% c('Long rhizome or root sucker','Short rhizome')) {
        src <- raw_source_col[[1]]
        val <- cur_data()[[src]]

        paste0("{", src, ",",val, "}")
      }
      else if (norm_value == 'Epicormic') {
        src <- raw_source_col[[2]]
        val <- cur_data()[[src]]

        paste0("{", src, ",",val, "}")
      }
      else if (norm_value == 'Apical') {
        src <- raw_source_col[[3]]
        val <- cur_data()[[src]]

        paste0("{", src, ",",val, "}")


      }
    }) %>%
  ungroup()

# bind surv4
data_long_cat <- data_long_cat %>%
  bind_rows(data_long_surv4)

# numerical traits
data_long_num <- data_long %>%
  filter(trait_type == 'numerical') %>%
  rowwise() %>%
  mutate(
    best = if (str_detect(norm_value, '^\\d+$')) norm_value else NA,
    lower = if (str_detect(norm_value, '^\\d+\\s*-\\s*\\d+')) str_extract(norm_value, '^\\d+')
    else if (str_detect(norm_value, '^>\\d+')) str_extract(norm_value, '\\d+')
    else NA,
    upper = if (str_detect(norm_value, '^\\d+\\s*-\\s*\\d+')) str_extract(norm_value, '\\d+$')
    else if (str_detect(norm_value, '^<\\d+')) str_extract(norm_value, '\\d+')
    else NA,
    raw_value = {
      src <- raw_source_col
      val <- norm_value
      paste0(src, ", ", val)}) %>%
  ungroup()

# combine categorical and numerical traits
data_long <- data_long_num %>% bind_rows(data_long_cat)

# add notes to match firetraits process
data_long <- data_long %>%
  mutate(notes =
           if_else(bionet_name != original_name,
                   paste0('Original name:', original_name),
                   NA))

# create vector of traits
traits <- unique(data_long$trait_code)


dharawal_records <- data_long %>%
  mutate(
    best = ifelse(trait_type == 'categorical', NA, as.numeric(best)),
    lower = ifelse(trait_type == 'categorical', NA, as.numeric(lower)),
    upper = ifelse(trait_type == 'categorical', NA, as.numeric(upper)),
    norm_value = ifelse(trait_type == 'numerical', NA, norm_value)
  ) %>%
  select(
    bionet_name, species_code, original_source, trait_code,
    norm_value, best, lower, upper, raw_value
  ) %>%
  filter(!is.na(species_code)) %>%
  distinct()  # removes duplicates caused by unnest(surv4) creating multiple rows per species

# 6. Save records so combine.R can aggregate across all papers
write_csv(dharawal_records, 'papers/completed_manually/Keith 1991/keith_1991_records.csv')

# 7. Flag duplicates
database <- read.csv('database.csv')
dupes <- flag_duplicates(dharawal_records, database)

# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/completed_manually/Keith 1991/keith_1991_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/completed_manually/Keith 1991/keith_1991_dupes_possible.csv')

