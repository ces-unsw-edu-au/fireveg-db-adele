# export_database.R
# Exports a snapshot of the litrev database to database.csv for use by the
# pipeline (duplicate detection in flag_duplicates()).
#
# Requires: credentials in secrets/Renviron.local
# Output:   database.csv (not committed — contains unpublished data)

library(DBI)
library(RPostgres)
library(tidyverse)

readRenviron('secrets/Renviron.local')

con <- dbConnect(Postgres(),
                 dbname   = Sys.getenv("DBNAME"),
                 host     = Sys.getenv("DBHOST"),
                 port     = Sys.getenv("DBPORT"),
                 user     = Sys.getenv("DBUSER"),
                 password = Sys.getenv("DBPASSWORD"),
                 sslmode  = 'require')

priority_traits <- list(
  categorical = c('surv1', 'surv4', 'germ1', 'germ8', 'rect2', 'repr2', 'disp1'),
  numerical   = c('surv5', 'surv6', 'surv7', 'grow1', 'repr3', 'repr3a', 'repr4')
)

cat_tables <- setNames(
  lapply(priority_traits$categorical, function(x) {
    dbGetQuery(con, paste0("
      SELECT record_id, weight, species, species_code, main_source,
             original_sources, raw_value, original_notes,
             norm_value::text AS norm_value
      FROM litrev.", x))
  }),
  priority_traits$categorical
) %>% bind_rows(.id = 'trait_code')

num_tables <- setNames(
  lapply(priority_traits$numerical, function(x) {
    dbGetQuery(con, paste0("
      SELECT record_id, weight, species, species_code, main_source,
             original_sources, raw_value, original_notes,
             best, upper, lower
      FROM litrev.", x))
  }),
  priority_traits$numerical
) %>% bind_rows(.id = 'trait_code')

database <- bind_rows(cat_tables, num_tables) %>%
  relocate(record_id, .before = 1) %>%
  relocate(weight, .after = last_col())

dbDisconnect(con)

write.csv(database, 'database.csv', row.names = FALSE)
message('Exported ', nrow(database), ' records to database.csv')
