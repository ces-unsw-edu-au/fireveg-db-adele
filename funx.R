# funx.R
library(tidyverse)
library(APCalign)
# taxonomic matching

match_bionet_taxonomy <- function(df, species_name_column){

  # rename the species_name_column to original_name
  # Skip if already named original_name — no-op renames fail in some dplyr versions
  if (species_name_column != "original_name") {
    df <- df %>%
      rename(original_name = all_of(species_name_column))
  }

  # Normalise names: extract the formal binomial or trinomial only, stripping
  # trailing author abbreviations that are not wrapped in parentheses (e.g.
  # "Angophora floribunda Sweet" -> "Angophora floribunda";
  # "Dianella laevis R.Br." -> "Dianella laevis";
  # "Brachyloma daphnoides subsp. glabrum Benth." -> "Brachyloma daphnoides subsp. glabrum").
  # The coalesce fallback preserves the original string for informal names
  # (e.g. "Orchid sp. 1") that don't match the pattern.
  df <- df %>%
    mutate(
      original_name = coalesce(
        str_extract(original_name,
                    paste0("^[A-Z][a-zÀ-ž-]+ ",       # Genus
                           "[a-zÀ-ž][a-zÀ-ž-]+", # species epithet
                           "(?:\\s+(?:subsp\\.|ssp\\.|var\\.|f\\.)",  # optional rank marker
                           "\\s+[a-zÀ-ž][a-zÀ-ž-]+)?"  # infra-epithet
                    )),
        original_name
      )
    )

  # create a species list with suggested APCalign name
  species_list <- df %>%
    pull(original_name) %>%
    create_taxonomic_update_lookup()

  # join the suggested name and taxon rank to df
  # distinct() keeps the first (highest-quality) row per original_name, preventing
  # many-to-many duplicates when APCalign returns multiple matches for one name.
  df <- df %>%
    left_join(
      species_list %>%
        select(original_name, suggested_name, taxon_rank) %>%
        distinct(original_name, .keep_all = TRUE),
      by = "original_name"
    ) %>%
    relocate(c(suggested_name, taxon_rank), .before = 2) %>%
    # APCalign sometimes appends a bracketed qualifier to suggested_name
    # (e.g. "Lepidosperma lineare [alternative possible name]") when the match
    # is uncertain. Strip it so the downstream bionet joins can find the name.
    mutate(suggested_name = str_remove(suggested_name, "\\s*\\[.*\\]"))

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

  # unmatched after exact step — split off for the two fallback strategies
  df_unmatched <- df_exact_match %>%
    filter(is.na(species_code)) %>%
    select(-c(species_code, bionet_name))

  # Strategy 2: look up our APCalign suggested_name directly as a bionet_name.
  # This handles version drift: APCalign correctly resolves a synonym to its accepted
  # name (e.g. "Acacia botrycephala" -> "Acacia terminalis"), but the bionet_species
  # file was built with a different APCalign version whose suggested_name for the
  # same bionet entry may differ — so matching on suggested_name-to-suggested_name
  # would miss it. Checking suggested_name-to-bionet_name bridges the gap.
  # na_matches = "never" so NA suggested_names don't join anything.
  # distinct() collapses any duplicates introduced if bionet_species has repeated
  # bionet_name entries or the input has near-duplicate rows.
  df_direct_suggested <- df_unmatched %>%
    left_join(
      bionet_species %>% select(bionet_name, species_code),
      by = c("suggested_name" = "bionet_name"),
      na_matches = "never"
    ) %>%
    mutate(bionet_name = if_else(!is.na(species_code), suggested_name, NA_character_)) %>%
    relocate(c(bionet_name, species_code), .before = 1) %>%
    distinct()

  # Strategy 3: for still-unmatched names, match by suggested_name from APCalign
  # for both sources (original two-sided suggested_name join).
  # na_matches = "never" prevents NA suggested_names from matching each other.
  # When multiple bionet entries share the same suggested_name (e.g. a species and
  # its subspecies all resolve to the same accepted name), we keep only the closest
  # match: the entry where bionet_name == suggested_name (species-level over subsp.).
  # Falls back to the first available row if no exact bionet_name match exists.
  df_suggested_match <- df_direct_suggested %>%
    filter(is.na(species_code)) %>%
    select(-c(species_code, bionet_name)) %>%
    left_join(bionet_species[ , c('suggested_name', 'bionet_name', 'species_code')],
              by = 'suggested_name',
              na_matches = "never") %>%
    relocate(c(bionet_name, species_code), .before = 1) %>%
    group_by(original_name) %>%
    arrange(if_else(!is.na(bionet_name) & bionet_name == suggested_name, 0L, 1L),
            .by_group = TRUE) %>%
    slice(1) %>%
    ungroup()

  # Strategy 4: subspecies / variety prefix match.
  # For species-level names that have no bionet entry as a species (only as subspecies
  # or varieties), extract just the binomial from each bionet_name and join on
  # original_name. E.g. "Hibbertia stricta" is absent from bionet as a species but
  # "Hibbertia stricta subsp. stricta" is present; extracting "Hibbertia stricta"
  # from that bionet_name finds the match.
  # bionet_binomials is pre-deduplicated to one row per binomial (nominotypical
  # subspecies preferred — last epithet repeats the species epithet) so the join
  # itself produces at most one row per input row without needing a post-join slice.
  bionet_binomials <- bionet_species %>%
    mutate(species_binomial = str_extract(bionet_name, "^[A-Z][a-z-]+ [a-z-]+")) %>%
    filter(!is.na(species_binomial)) %>%
    select(bionet_name, species_code, species_binomial) %>%
    group_by(species_binomial) %>%
    arrange(
      if_else(word(bionet_name, -1) == word(species_binomial, 2), 0L, 1L),
      .by_group = TRUE
    ) %>%
    slice(1) %>%
    ungroup()

  df_subsp_match <- df_suggested_match %>%
    filter(is.na(species_code)) %>%
    select(-c(species_code, bionet_name)) %>%
    left_join(bionet_binomials,
              by = c("original_name" = "species_binomial"),
              na_matches = "never") %>%
    mutate(
      bionet_name = if_else(!is.na(species_code), bionet_name, NA_character_),
      notes = if_else(!is.na(species_code),
                      paste0("original name: ", original_name),
                      NA_character_)
    ) %>%
    relocate(c(bionet_name, species_code), .before = 1)

  # combine to give the df with the bionet_name and species_code applied
  df <- df_exact_match %>%
    filter(!is.na(species_code)) %>%
    bind_rows(df_direct_suggested %>% filter(!is.na(species_code))) %>%
    bind_rows(df_suggested_match %>% filter(!is.na(species_code))) %>%
    bind_rows(df_subsp_match)

  return(df)
}


# Print any species that failed Bionet taxonomy matching (will be dropped at save step).
# Call this on the long-format data frame BEFORE the final select(), while original_name
# is still in scope.  Prints the distinct original names so they can be checked manually.
report_unmatched <- function(data) {
  unmatched <- data %>%
    filter(is.na(species_code)) %>%
    distinct(original_name)
  if (nrow(unmatched) > 0) {
    message(nrow(unmatched), ' original name(s) with NA species_code — will be dropped:')
    print(unmatched$original_name)
  } else {
    message('All species matched to Bionet (no NA species_code).')
  }
  invisible(unmatched)
}


# Validate a records data frame before writing to CSV.
# Call AFTER filter(!is.na(species_code)) and BEFORE write_csv().
# Prints a one-line summary plus any issues found.
# Returns the issues vector invisibly so callers can act on failures if needed.
#
# Checks performed:
#   1. Record count is non-zero
#   2. Required columns are all present
#   3. No NA in species_code, trait_code, or raw_value
#   4. norm_values are in the allowed vocabulary (categorical traits)
#   5. Numerical norm_values parse consistently with best/lower/upper
#   6. No unexpected duplicate species+trait combinations

check_records <- function(records) {
  vocab <- list(
    surv1 = c('None', 'Few', 'Half', 'Most', 'All', 'Unknown'),
    surv4 = c('Epicormic', 'Apical', 'Lignotuber', 'Basal', 'Tuber', 'Tussock',
              'Long rhizome or root sucker', 'Short rhizome', 'Stolon', 'None'),
    germ1 = c('Canopy', 'Soil-persistent', 'Transient', 'Non-canopy'),
    germ8 = c('PY', 'PD', 'PY-PD', 'MPD', 'MD', 'ND'),
    rect2 = c('Intolerant', 'Intolerant-Tolerant', 'Tolerant',
              'Tolerant-Requiring', 'Requiring', 'Unknown'),
    repr2 = c('Exclusive', 'Facultative', 'Negligible', 'Unknown'),
    disp1 = c('wind-hairs', 'wind-wing', 'wind-unspec.', 'animal-ingestion',
              'animal-cohesion', 'animal-unspec.', 'ant', 'water',
              'ballistic', 'passive', 'other')
  )
  numerical_traits <- c('surv5', 'surv6', 'surv7', 'grow1',
                        'repr3', 'repr3a', 'repr4')
  # surv4 and disp1 legitimately produce multiple records per species
  multi_value_traits <- c('surv4', 'disp1')

  issues <- character(0)

  message('check_records(): ', nrow(records), ' record(s) | ',
          n_distinct(records$species_code), ' species | traits: ',
          paste(sort(unique(records$trait_code)), collapse = ', '))

  if (nrow(records) == 0) {
    message('  !! No records produced — check script logic.')
    return(invisible('no records'))
  }

  # 2. Required columns
  required <- c('bionet_name', 'species_code', 'original_source',
                'trait_code', 'norm_value', 'best', 'lower', 'upper', 'raw_value')
  missing <- setdiff(required, names(records))
  if (length(missing) > 0)
    issues <- c(issues, paste0('missing columns: ', paste(missing, collapse = ', ')))

  # 3. NA in key columns
  if (any(is.na(records$species_code)))
    issues <- c(issues, 'NA species_code present — filter(!is.na(species_code)) not applied')
  if (any(is.na(records$trait_code)))
    issues <- c(issues, 'NA trait_code present')
  n_empty_raw <- sum(is.na(records$raw_value) | records$raw_value == '')
  if (n_empty_raw > 0)
    issues <- c(issues, paste0(n_empty_raw, ' row(s) with empty raw_value'))

  # 4. Vocabulary check (categorical traits)
  for (trait in intersect(names(vocab), unique(records$trait_code))) {
    bad <- records %>%
      filter(trait_code == trait, !is.na(norm_value),
             !norm_value %in% vocab[[trait]])
    if (nrow(bad) > 0)
      issues <- c(issues, paste0(trait, ': unrecognised norm_value: ',
                                 paste(sort(unique(bad$norm_value)), collapse = ', ')))
  }

  # 5. Numerical trait consistency
  num_rows <- records %>% filter(trait_code %in% numerical_traits)
  if (nrow(num_rows) > 0) {
    bad_num <- num_rows %>% filter(!str_detect(norm_value, '[0-9]'))
    if (nrow(bad_num) > 0)
      issues <- c(issues, paste0('numerical trait non-numeric norm_value: ',
                                 paste(unique(bad_num$norm_value), collapse = ', ')))

    bad_gt <- num_rows %>%
      filter(str_detect(norm_value, '^>'), is.na(lower) | !is.na(upper))
    if (nrow(bad_gt) > 0)
      issues <- c(issues, paste0(nrow(bad_gt), ' row(s): ">X" norm_value but lower/upper mismatch'))

    bad_lt <- num_rows %>%
      filter(str_detect(norm_value, '^<'), !is.na(lower) | is.na(upper))
    if (nrow(bad_lt) > 0)
      issues <- c(issues, paste0(nrow(bad_lt), ' row(s): "<X" norm_value but lower/upper mismatch'))

    bad_range <- num_rows %>%
      filter(str_detect(norm_value, '^[0-9].*-[0-9]'), is.na(lower) | is.na(upper))
    if (nrow(bad_range) > 0)
      issues <- c(issues, paste0(nrow(bad_range), ' row(s): range norm_value but lower or upper is NA'))

    bad_best <- num_rows %>% filter(is.na(best) & is.na(lower) & is.na(upper))
    if (nrow(bad_best) > 0)
      issues <- c(issues, paste0(nrow(bad_best), ' numerical row(s) with no value in best, lower, or upper'))
  }

  # 6. Duplicate species+trait (expected only for multi-value traits)
  single_value_records <- records %>%
    filter(!trait_code %in% multi_value_traits, !is.na(species_code))
  dupes <- single_value_records %>%
    count(species_code, trait_code) %>%
    filter(n > 1)
  if (nrow(dupes) > 0)
    issues <- c(issues, paste0(nrow(dupes), ' duplicate species+trait combination(s) in single-value trait(s)'))

  if (length(issues) == 0) {
    message('  OK')
  } else {
    for (issue in issues) message('  !! ', issue)
  }

  invisible(issues)
}


# Flag records in the database export that overlap with newly processed records.
# Returns a df of database rows that are potential duplicates, with a match_type column:
#   exact   - species_code + trait_code + source + value all match
#   partial - species_code + trait_code + source match, value differs
#   possible - species_code + trait_code + value match, source differs
#
# Whoever sets weight = 0 will need a re-export of the database that includes record_id.

flag_duplicates <- function(new_records, database) {

  joined <- new_records %>%
    inner_join(database, by = c("species_code", "trait_code"),
               suffix = c(".new", ".db"),
               relationship = "many-to-many")

  if (nrow(joined) == 0) return(list(exact_partial = tibble(), possible = tibble()))

  joined <- joined %>%
    mutate(
      value_match = case_when(
        # Numerical traits: match on best/lower/upper regardless of whether
        # norm_value is also populated. Must come before the norm_value branch
        # because numerical records have both populated; norm_value.db is NULL
        # in the database for numerical traits so norm_value comparison fails.
        !is.na(best.new) | !is.na(lower.new) | !is.na(upper.new) ~
          (is.na(best.new)  | as.character(best.new)  == as.character(best.db))  &
          (is.na(lower.new) | as.character(lower.new) == as.character(lower.db)) &
          (is.na(upper.new) | as.character(upper.new) == as.character(upper.db)),
        # Categorical traits: match on norm_value
        !is.na(norm_value.new) ~
          norm_value.new == norm_value.db,
        TRUE ~ FALSE
      ),
      source_match = str_detect(original_sources, fixed(original_source))
    ) %>%
    mutate(
      match_type = case_when(
        source_match & value_match        ~ "exact",
        source_match & !value_match       ~ "partial",
        is.na(original_sources) & value_match ~ "possible"
      )
    ) %>%
    filter(!is.na(match_type))

  exact_partial <- joined %>%
    filter(match_type %in% c("exact", "partial")) %>%
    select(record_id, species_code, species, trait_code, main_source,
           original_sources,
           norm_value.db, best.db, lower.db, upper.db,
           match_type) %>%
    rename(norm_value = norm_value.db, best = best.db,
           lower = lower.db, upper = upper.db)

  possible <- joined %>%
    filter(match_type == "possible") %>%
    select(record_id, species_code, species, trait_code, main_source,
           original_sources,
           norm_value.db, best.db, lower.db, upper.db,
           match_type) %>%
    rename(norm_value = norm_value.db, best = best.db,
           lower = lower.db, upper = upper.db)

  list(exact_partial = exact_partial, possible = possible)
}

