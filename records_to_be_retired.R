# get full trait records from database

# load libraries
library(RPostgres)
library(DBI)
library(tidyverse)

# enter details to access db
readRenviron("secrets/Renviron.local")
host <- Sys.getenv("DBHOST")
port <- Sys.getenv("DBPORT")
name <- Sys.getenv("DBNAME")
user <- Sys.getenv("DBUSER")
password <- Sys.getenv("DBPASSWORD")

drv <- Postgres() ##
con <- dbConnect(drv,
                 dbname = Sys.getenv("DBNAME"),
                 host = Sys.getenv("DBHOST"),
                 port = Sys.getenv("DBPORT"),
                 user = Sys.getenv("DBUSER"),
                 password = Sys.getenv("DBPASSWORD"),
                 sslmode = 'require')

# identify priority traits
priority_traits <- c('germ1', 'germ8', 'grow1', 'surv1', 'surv4', 'surv5', 'surv6', 'surv7', 'rect2', 'repr2', 'repr3', 'repr3a', 'repr4', 'disp1')

# create a trait map, raw sources for norm values and type
priority_traits <- tibble::tribble(
  ~trait_code,          ~trait_type,
  "surv1",          "categorical",
  "surv4",          "categorical",
  "germ1",         "categorical",
  "germ8",         "categorical",
  "grow1",         "numerical",
  "rect2",         "categorical",
  "repr2",         "categorical",
  "repr3",         "numerical",
  "repr3a",       "numerical",
  "repr4",         "numerical",
  "disp1",        "categorical",
  "surv5",          "numerical",
  "surv6",         "numerical",
  "surv7",         "numerical"
)

# extract categorical trait code
cat_traits <- priority_traits %>% filter(trait_type == 'categorical') %>% pull(trait_code)

# extract numeric trait code
num_traits <- priority_traits %>% filter(trait_type == 'numerical') %>% pull(trait_code)

# extract categorical tables
cat_tables <- setNames(
  lapply(cat_traits, function(x) {
    dbGetQuery(con, paste0("
      SELECT species, species_code, main_source, original_sources, raw_value, original_notes, norm_value::text AS norm_value
      FROM litrev.", x))
  }),
  cat_traits
) %>% bind_rows(.id = 'trait_code')

# extract numerical tables
num_tables <- setNames(
  lapply(num_traits, function(x) {
    dbGetQuery(con, paste0("
      SELECT species, species_code, main_source, original_sources, raw_value, original_notes, best, upper, lower FROM litrev.", x))
  }),
  num_traits
) %>% bind_rows(.id = 'trait_code')

# combine to give full database of priority traits.
database <- bind_rows(cat_tables, num_tables)

# rework sources to match format
database$sources <- strsplit(gsub('[{"}]', "", database$original_sources), ",|; ")

database <- database %>%
  unnest(sources)

database$sources <- sub("_", " ", database$sources)

# give row number streamline matching duplicates
database <- database %>%
  mutate(row_number = row_number()) %>%
  relocate(row_number, .before = 1)

# isolate database records from imported records
records_from_authors <- database %>%
  filter(str_detect(database$sources, 'Benwell 1998|Benson 1985|Clarke Fulloon 1999|Keith 1991')
  ) %>%
  filter(!str_detect(original_sources,'Benson 1985b'))


# combine ingested records
combined_records <- bind_rows(dharawal_records,
                              benwell_records,
                              benson_85_records,
                              torrington_records)


# records that match between db and new imports by trait code, source, species, and trait values
matching <- inner_join(records_from_authors,
                       combined_records,
                       by = c('trait_code', 'sources' = 'original_source', 'species_code', 'species' = 'bionet_name', 'norm_value', 'best', 'upper', 'lower'))


# records that are by the imported papers, but are not in imported records
non_matching <- anti_join(records_from_authors,
                          combined_records,
                          by = c("sources" = "original_source", "trait_code", "species" = 'bionet_name')
)

non_matching_values <- anti_join(records_from_authors,
                                 combined_records,
                                 by = c("sources" = "original_source", "trait_code", "species" = 'bionet_name', 'norm_value', 'best', 'upper', 'lower')
)

# records where trait value differs between new import and original db record
non_matching_values_only <- anti_join(records_from_authors,
                          combined_records,
                          by = c("sources" = "original_source", "trait_code", "species" = 'bionet_name', 'norm_value', 'best', 'upper', 'lower')
) %>%
  anti_join(non_matching,
            by = c("sources", "trait_code", "species", 'norm_value', 'best', 'upper', 'lower'))

#write.csv(non_matching, 'data/non_matching2.csv', row.names = F)

#write.csv(non_matching_values_only, 'data/non_matching_values2.csv', row.names = F)

potential_matches <- inner_join(database %>% filter(is.na(original_sources)) %>% select(-sources),
                                combined_records,
                                by = c('trait_code', 'species_code', 'species' = 'bionet_name', 'norm_value', 'best', 'upper', 'lower')) %>%
  relocate(raw_value.x, .before = 14)

non_matching_checks <- read_csv('data/non_matching.csv')

database_poss_dupe <- database %>%
  left_join(
  non_matching_checks %>%
    select(species, trait_code, sources, best, upper, lower, norm_value, why),
  by = c(
    "species",
    "trait_code",
    "sources",
    "best",
    "upper",
    "lower",
    "norm_value"
  )
) %>%
  mutate(
    dupe_status =
      case_when(row_number %in% matching$row_number ~ 'retire matching record',
                row_number %in% potential_matches$row_number ~ 'potential match - norm / numeric trait values match, source not given',
                row_number %in% non_matching_values_only$row_number ~ 'retire record - new input correct / this is an NA record',
                !is.na(why) ~ paste0('in database, not in records records, reason: ', why)
      )) %>%
  select(-why) %>%
  filter(!is.na(dupe_status))




