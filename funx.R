# funx.R
library(tidyverse)
library(APCalign)
# taxonomic matching

match_bionet_taxonomy <- function(df, species_name_column){

  # rename the species_name_column to original_name
  df <- df %>%
    rename(original_name = all_of(species_name_column))

  # create a species list with suggested APCalign name
  species_list <- df %>%
    pull(original_name) %>%
    create_taxonomic_update_lookup()

  # join the suggested name and taxon rank to df
  df <- df %>%
    left_join(species_list %>% select(original_name, suggested_name, taxon_rank),
              by = "original_name",
              multiple = 'first') %>%
    relocate(c(suggested_name, taxon_rank), .before = 2)

  # import the bionet species list with APCalign suggested name
  bionet_species <- read.csv('data/bionet_species_with_apcalign_suggested_name.csv')

  # match the species from source to bionet species names
  df_exact_match <- df %>%
    left_join(
      bionet_species %>% select(bionet_name, species_code),
      by = c("original_name" = "bionet_name")) %>%
    mutate(bionet_name = if_else(
      !is.na(species_code),
      original_name,
      NA)
    ) %>%
    relocate(c(bionet_name, species_code), .before = 1) %>%
    distinct()

  # for names that do not match exactly, match by suggested name from APC align for both sources
  df_suggested_match <- df_exact_match %>%
    filter(is.na(species_code)) %>%
    select(-c(species_code, bionet_name)) %>%
    left_join(bionet_species[ , c('suggested_name', 'bionet_name', 'species_code')],
              by = 'suggested_name') %>%
    relocate(c(bionet_name, species_code), .before = 1) %>%
    distinct()

  # combine to give the df with the bionet_name and species_code applied
  df <- df_exact_match %>%
    filter(!is.na(species_code)) %>%
    bind_rows(df_suggested_match) %>%
    select(-suggested_name)

  return(df)
}





