library(tidyverse)
source('funx.R')

# combine.R
# Aggregates outputs across all processed papers into single files:
#   all_records.csv             — all new trait records ready for upload
#   all_dupes_exact_partial.csv — all exact/partial duplicates for weight update
#   all_dupes_possible.csv      — all possible duplicates for manual review

# Read each paper's records file and validate individually.
# Checking per-file (not on the combined set) keeps the duplicate species+trait
# check meaningful — cross-paper duplicates are expected and handled separately
# by flag_duplicates; within-paper duplicates on single-value traits are errors.
record_files <- list.files('papers', pattern = '_records\\.csv$',
                           recursive = TRUE, full.names = TRUE)

records_list <- map(record_files, ~read.csv(., na.strings = c("", "NA")) %>%
                      mutate(
                        species_code = as.character(species_code),
                        best         = as.numeric(best),
                        lower        = as.numeric(lower),
                        upper        = as.numeric(upper),
                        across(where(is.logical), as.character)
                      ))

cat('\n===== check_records across all papers =====\n')
walk2(record_files, records_list, function(f, r) {
  cat('\n', basename(dirname(f)), '\n', sep = '')
  check_records(r)
})
cat('\n===========================================\n\n')

all_records <- bind_rows(records_list)

# Remove within-paper duplicates caused by old synonyms or subspecies collapsing
# to the same modern accepted Bionet name (e.g. multiple Danthonia spp. all
# resolving to Rytidosperma indutum with identical trait values).
# distinct() on all columns collapses truly identical rows while preserving
# legitimate multi-record cases where values or raw_values differ.
all_records <- all_records %>% distinct()

# Numerical traits store values in best/lower/upper; norm_value is NA in the
# database for these traits. Clear it here so the upload file is consistent.
numerical_traits <- c('surv5', 'surv6', 'surv7', 'grow1',
                      'repr3', 'repr3a', 'repr4')
all_records <- all_records %>%
  mutate(norm_value = if_else(trait_code %in% numerical_traits,
                              NA_character_, norm_value))

write.csv(all_records, 'all_records.csv', row.names = FALSE)

# combine exact/partial dupe files from all paper scripts
exact_partial_files <- list.files('papers', pattern = '_dupes_exact_partial\\.csv$',
                                  recursive = TRUE, full.names = TRUE)
exact_partial_files <- exact_partial_files[file.size(exact_partial_files) > 0]

all_dupes_exact_partial <- map_dfr(exact_partial_files,
                                   ~read.csv(., na.strings = c("", "NA")) %>%
                                     mutate(
                                       across(where(is.logical), as.character),
                                       across(any_of(c('best','lower','upper')), as.numeric),
                                       across(any_of(c('species_code','record_id')), as.character)
                                     ))

write.csv(all_dupes_exact_partial, 'all_dupes_exact_partial.csv', row.names = FALSE)

# combine possible dupe files from all paper scripts
possible_files <- list.files('papers', pattern = '_dupes_possible\\.csv$',
                             recursive = TRUE, full.names = TRUE)
possible_files <- possible_files[file.size(possible_files) > 0]

all_dupes_possible <- map_dfr(possible_files,
                              ~read.csv(., na.strings = c("", "NA")) %>%
                                mutate(
                                  across(where(is.logical), as.character),
                                  across(any_of(c('best','lower','upper','best.db','lower.db','upper.db')), as.numeric),
                                  across(any_of(c('species_code','record_id')), as.character)
                                ))

write.csv(all_dupes_possible, 'all_dupes_possible.csv', row.names = FALSE)
