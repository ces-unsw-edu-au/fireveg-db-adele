library(RPostgres)
library(DBI)
library(tidyverse)

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


dbGetQuery(con, "
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'litrev' AND table_name = 'surv1'
    ORDER BY ordinal_position
  ")

# get all the lit rev tables
litrev_tables <- dbGetQuery(con, "
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'litrev'
")$table_name

# remove ref list and trait info
litrev_tables <- setdiff(litrev_tables, c("ref_list","trait_info"))

# create empty list
trait_tables <- list()

# create list and make everything a character because cant bind rows otherwise (boo)
for (tables in litrev_tables) {
  df <- dbGetQuery(con, paste0("SELECT * FROM litrev.", tables))

  df$trait_code <- tables

  df[] <- lapply(df, as.character)

  trait_tables[[tables]] <- df
}

# bind into df
df <- bind_rows(trait_tables)


a <- df %>%
  filter(str_detect(original_sources, 'Benson 1985|Benwell 1998'))

bens <- df %>%
  filter(str_detect(original_sources, 'Benson 1985'))

benw <- df %>%
  filter(str_detect(original_sources, 'Benwell 1998'))

keith <- df %>%
  filter(str_detect(original_sources, 'Keith 1991'))

k <- records[['surv1']] %>% bind_rows()


bionet_species_from_db <- dbGetQuery(con, "SELECT * FROM species.bionet")
write.csv(bionet_species_from_db, 'secrets/data/bionet_species_exported120226.csv', row.names = F)
repr3 <- dbGetQuery(con, "SELECT * FROM litrev.repr3")
surv5 <- dbGetQuery(con, "SELECT * FROM litrev.surv5")
surv4 <- dbGetQuery(con, "SELECT * FROM litrev.surv4")

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

cat_traits <- priority_traits %>% filter(trait_type == 'categorical') %>% pull(trait_code)

num_traits <- priority_traits %>% filter(trait_type == 'numerical') %>% pull(trait_code)

cat_tables <- setNames(
  lapply(cat_traits, function(x) {
    dbGetQuery(con, paste0("
      SELECT species, species_code, main_source, original_sources, raw_value, original_notes, norm_value::text AS norm_value, record_id, weight
      FROM litrev.", x))
  }),
  cat_traits
) %>% bind_rows(.id = 'trait_code')


num_tables <- setNames(
  lapply(num_traits, function(x) {
    dbGetQuery(con, paste0("
      SELECT species, species_code, main_source, original_sources, raw_value, original_notes, best, upper, lower FROM litrev.", x))
  }),
  num_traits
) %>% bind_rows(.id = 'trait_code')



a <- bind_rows(cat_tables, num_tables)

patterns <- c('"Southern Region Checklist",2007', '2016",authors', a[grepl("as a policeman", a$original_sources), 4])
replacements <- c('"Southern Region Checklist" 2007', '2016" authors', 'Northern Territory Herbarium 2014')

for (i in seq_along(patterns)){
  a$original_sources <- sub(patterns[i], replacements[i], a$original_sources, fixed = T)
}

database <- a %>%
  relocate(record_id, .before = 1) %>%
  relocate(weight, .after = 13)

a$sources <- strsplit(gsub('[{"}]', "", a$original_sources), ",|; ")

a <- a %>%
  unnest(sources)

a$sources <- sub("_", " ", a$sources)

sources <- data.frame(sources =sort(unique(a$sources)))

sources_per_species <- a %>%
  group_by(species) %>%
  summarise(n_sources = n_distinct(sources),
            n_records = n(),
            sources = paste(unique(sources), collapse = ';')) %>%
  arrange(desc(n_sources))

a <- a %>%
  left_join(sources_per_species %>% select(-sources), by = 'species')

species_per_source <- a %>%
  group_by(sources, main_source) %>%
  summarise(n_species = n_distinct(species),
            n_records = n(),
            species_with_n_sources = paste0(unique(species), " (", n_sources, ")", collapse = '; ')) %>%
  arrange(desc(n_species))


species_per_source_FFRD <- species_per_source %>%
  filter(main_source == 'NSWFFRDv2.1')

species_per_source_austraits <- species_per_source %>%
  filter(str_detect(main_source, 'austraits'))

table(duplicated(species_per_source$sources))

dupes <- a %>%
  group_by(sources, trait_code, species, norm_value) %>%
  summarise(n_main = n_distinct(main_source),
            main_sources = list(main_source)) %>%
  filter(n_main > 1)


field_sites <- dbGetQuery(con, "SELECT * FROM form.field_site")
field_visit <- dbGetQuery(con, "SELECT * FROM form.field_visit")
field_samples <- dbGetQuery(con, "SELECT * FROM form.field_samples")
fire_history <- dbGetQuery(con, "SELECT * FROM form.fire_history")
observers <- dbGetQuery(con, "SELECT * FROM form.observerid")
quadrats <- dbGetQuery(con, "SELECT * FROM form.quadrat_samples")
surveys <- dbGetQuery(con, "SELECT * FROM form.surveys")
nsw_units <- dbGetQuery(con, "SELECT * FROM vegetation.nsw_units")

# field_samples and visit and field_visit_veg_description and estimates and raw and quadrats by visit_id
# field sites and fire_history by site_label
# observers to field_visit by userkey = mainobserver
# quadrats has record_id
# field visit to surveys by survey_name


#table_schema                        table_name
#1                form                     field_samples
#2                form                        field_site
#3                form                       field_visit
#4                form       field_visit_veg_description
#5                form  field_visit_vegetation_estimates
#6                form field_visit_vegetation_raw_values
#7                form                      fire_history
#8                form                        observerid
#9                form                   quadrat_samples
#10               form                           surveys

dbGetQuery(con, "
  SELECT table_schema, table_name
  FROM information_schema.tables
  WHERE table_type = 'BASE TABLE'
  ORDER BY table_schema, table_name
")


# get all the traits and join them to one table?

dbGetQuert(con, "
           SELECT")



trait_info <- dbGetQuery(con, "SELECT * FROM litrev.trait_info")

ref_list <- dbGetQuery(con, "SELECT * FROM litrev.ref_list")
