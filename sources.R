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
      SELECT species, species_code, main_source, original_sources, raw_value, original_notes, norm_value::text AS norm_value
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


dupes <- a %>%
  group_by(sources, trait_code, species, norm_value) %>%
  summarise(n_main = n_distinct(main_source),
            main_sources = paste(unique(main_source), collapse = ', ')) %>%
  filter(n_main > 1)

write.csv(species_per_source, 'species_per_source.csv', row.names = F)
write.csv(dupes, 'dupe_trait_records.csv', row.names = F)
