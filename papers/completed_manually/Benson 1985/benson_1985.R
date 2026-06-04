library(tidyverse)
library(APCalign)
# combine tabular data from source
benson_85_data <- read.csv('papers/completed_manually/Benson 1985/benson_1985_T3.csv',
                           na.strings = "") %>%
  left_join(read.csv('papers/completed_manually/Benson 1985/benson_1985_T1.csv') %>% select(-Family),
            by = 'species') %>%
  left_join(read.csv('papers/completed_manually/Benson 1985/benson_1985_F1.csv'),
            by = 'species')


benson_85_data <- match_bionet_taxonomy(benson_85_data, 'species')

benson_85_data <- benson_85_data %>%
  rowwise() %>%
  mutate(
    surv4 = case_when(str_detect(susceptibility, 'fs') ~ 'None',
                      susceptibility == 'r' & str_detect(bionet_name, 'Banksia') ~ 'Lignotuber',
                      susceptibility == 'r' & str_detect(bionet_name, 'Platysace') ~ 'Long rhizome or root sucker',
                      susceptibility == 'r' & str_detect(bionet_name, 'Actinotus') ~ 'Basal',
                      TRUE ~ NA_character_
    ),
    surv1 = case_when(str_detect(susceptibility, 'fs') ~ 'None',
              susceptibility == 'r' & str_detect(bionet_name, 'Banksia') ~ 'All',
              TRUE ~ NA_character_
    )
  ) %>%
  ungroup()


benson_85_data_repr3 <- benson_85_data %>%
  rowwise() %>%
  mutate(
    trait_code = 'repr3',
    trait_type = 'numerical',
    best = list(c(
      if_else(str_detect(a_BW, "\\d\\(.\\)"), str_extract(a_BW, "\\d+(?=\\))"), a_BW),
      if_else(str_detect(b_BW, "\\d\\(.\\)"), str_extract(b_BW, "\\d+(?=\\))"), b_BW),
      if_else(str_detect(c_BW, "\\d\\(.\\)"), str_extract(c_BW, "\\d+(?=\\))"), c_BW),
      if_else(str_detect(d_BW, "\\d\\(.\\)"), str_extract(d_BW, "\\d+(?=\\))"), d_BW),
      if_else(str_detect(a_G, "\\d\\(.\\)"), str_extract(a_G, "\\d+(?=\\))"), a_G)
    )),
    lower = list(c(
      if_else(str_detect(a_BW, "\\d\\(.\\)"), str_extract(a_BW, "\\d+(?=\\()"), NA),
      if_else(str_detect(b_BW, "\\d\\(.\\)"), str_extract(b_BW, "\\d+(?=\\()"), NA),
      if_else(str_detect(c_BW, "\\d\\(.\\)"), str_extract(c_BW, "\\d+(?=\\()"), NA),
      if_else(str_detect(d_BW, "\\d\\(.\\)"), str_extract(d_BW, "\\d+(?=\\()"), NA),
      if_else(str_detect(a_G, "\\d\\(.\\)"), str_extract(a_G, "\\d+(?=\\()"), NA)
    )),
    upper = NA,
    location = list(c('a_BW','b_BW','c_BW','d_BW','a_G')),
    original_source = 'Benson 1985'
    ) %>%
  ungroup() %>%
  unnest(c(best, lower, location)) %>%
  filter(!is.na(best) | !is.na(lower)) %>%
  filter(!str_detect(best, 'no flowering yet')) %>%
  rowwise() %>%
  mutate(
    best = as.numeric(best),
    lower = as.numeric(lower),
  raw_value = {
    val <- cur_data()[[cur_data()$location]]
    paste0('year to first flower after fire, ', val, ' at location: ', location)}
  ) %>%
  ungroup() %>%
  filter(!is.na(best) | !is.na(lower))  # drop rows where value was non-numeric (e.g. 'ND')


# create a trait map, raw sources for norm values and type
trait_map <- tibble::tribble(
  ~trait_code,   ~trait_type,
  "surv1",      "categorical",
  "surv4",      "categorical",
  "repr2",      "categorical",
  "repr4",      "numerical",
  "surv5",      "numerical"
)

benson_85_data_long <- pivot_longer(benson_85_data,
                                    cols = c('repr2', 'surv4', 'repr4', 'surv5', 'surv1'),
                                    names_to = 'trait_code',
                                    values_to = 'trait_value',
                                    values_transform = as.character) %>%
  filter(!is.na(trait_value)) %>%
  left_join(trait_map, by = "trait_code") %>%
  rowwise() %>%
  mutate(norm_value = case_when(trait_code %in% c("repr2", "surv4", "surv1") ~ trait_value),
         best = case_when(trait_code %in% c('surv5', 'repr4') ~ as.numeric(trait_value)),
         upper = NA,
         lower = NA,
         original_source = 'Benson 1985',
         raw_value = case_when(trait_code == 'surv1' ~ paste0('fire susceptibility: ', susceptibility),
                               trait_code == 'surv4' ~ paste0('fire susceptibility: ', susceptibility),
                               trait_code == 'surv5' ~ paste0('Based on figure 1 longevity - location: ', location),
                               trait_code =='repr2' ~ paste0('Based on figure 1 flowering response at location:', location),
                               trait_code == 'repr4' ~ paste0('Based on figure 1 seed data at location: ', location))) %>%
  ungroup() %>%
  select(-trait_value) %>%
  bind_rows(benson_85_data_repr3 %>% select(-c(15:17,19:20)))




benson_85_records <- benson_85_data_long %>%
  select(
    bionet_name, species_code, original_source, trait_code,
    norm_value, best, lower, upper, raw_value
  ) %>%
  # The left_join with F1 (which has one row per species per location) doubles
  # rows for species appearing at both BW and G sites. Traits derived from
  # susceptibility (surv4, surv1) and repr3 site values therefore appear twice
  # with identical content. distinct() removes those exact duplicates while
  # preserving intentional site-level records (repr2, surv5, repr4, repr3)
  # which differ by their raw_value location string.
  distinct()

# write records
write_csv(benson_85_records, 'papers/completed_manually/Benson 1985/benson_1985_records.csv')

database <- read.csv('data/database.csv')

dupes <- flag_duplicates(benson_85_records, database)
# exact/partial: db columns only + match_type (for batch weight update)
write_csv(dupes$exact_partial, 'papers/completed_manually/Benson 1985/benson_85_records_dupes_exact_partial.csv')

# possible: db + new columns + match_type (for manual review)
write_csv(dupes$possible,      'papers/completed_manually/Benson 1985/benson_85_records_dupes_possible.csv')

