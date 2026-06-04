install.packages("remotes")

remotes::install_github("traitecoevo/austraits", dependencies = TRUE, upgrade = "ask")

library(austraits)

austraits <- load_austraits(version = '6.0.0')

austraits %>% lookup_trait('growth')

csp <- extract_trait(austraits, 'clonal_spread_mechanism')
unique(w$traits$value)

pfr <- austraits$traits %>%
  filter(trait_name == 'post_fire_recruitment')


rc <- austraits$traits %>%
  filter(trait_name == 'resprouting_capacity_proportion_individuals')

sp <- data$suggested_name

woodiness <- data %>%
  filter(VR == 'r') %>%
  left_join(w$traits %>% select(taxon_name, value),
            by = c('suggested_name' = 'taxon_name')) %>%
  distinct() %>%
  select(1, 4, 23)

woodiness[, c(1,23)] %>%
  group_by(suggested_name) %>%
  filter(n() > 1) %>%
  print(n = 36)

csp <- extract_trait(austraits, 'clonal_spread_mechanism')

rhizomatic <- data %>%
  filter(VR == 'r') %>%
  left_join(csp$traits %>% select(taxon_name, value),
            by = c('suggested_name' = 'taxon_name')) %>%
  distinct() %>%
  select(1, 4, 23)

m <- woodiness %>%
  full_join(rhizomatic,
            by = c('suggested_name', 'family'),
            suffix = c("_woodiness", "_clonal_spread_mech"))

m %>%
  group_by(suggested_name) %>%
  filter(n() > 1) %>%
  print(n = 36)


 m %>%
  select(value_woodiness, value_clonal_spread_mech) %>%  # just the two columns
  distinct() %>%                                         # keep only unique rows
  arrange(value_woodiness, value_clonal_spread_mech)    # optional: sort nicely

m %>%
  count(value_woodiness, value_clonal_spread_mech)

