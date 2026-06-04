# run_all.R
# Sources every paper processing script under papers/ from the project root.
# Run this from the terminal with:
#
#   Rscript run_all.R
#
# Or from within RStudio (with project open, working directory = project root):
#
#   source('run_all.R')
#
# Each script is run with tryCatch so a single failure does not stop the rest.
# A summary of successes and failures is printed at the end.
#
# To run only scripts that have not yet produced a records CSV (i.e. unprocessed
# papers only), set RUN_UNPROCESSED_ONLY <- TRUE below.

RUN_UNPROCESSED_ONLY <- FALSE

library(tidyverse)

scripts <- list.files('papers', pattern = '\\.R$',
                      recursive = TRUE, full.names = TRUE)

# remove 'manually' processed ones
scripts <- scripts[-c(4:7)]

if (RUN_UNPROCESSED_ONLY) {
  existing_records <- list.files('papers', pattern = '_records\\.csv$',
                                 recursive = TRUE, full.names = TRUE)
  # Derive the expected records path for each script and filter to those missing
  expected_records <- str_replace(scripts, '\\.R$', '_records.csv')
  scripts <- scripts[!expected_records %in% existing_records]
  cat('Running', length(scripts), 'unprocessed script(s).\n\n')
} else {
  cat('Running all', length(scripts), 'script(s).\n\n')
}

results <- tibble(script = scripts, status = NA_character_, message = NA_character_)

for (i in seq_along(scripts)) {
  s <- scripts[[i]]
  cat('---', basename(s), '\n')
  result <- tryCatch({
    withCallingHandlers(
      source(s, local = new.env(parent = globalenv())),
      warning = function(w) {
        message('  [warning] ', conditionMessage(w))
        invokeRestart('muffleWarning')
      }
    )
    'OK'
  }, error = function(e) {
    paste0('ERROR: ', conditionMessage(e))
  })
  results$status[[i]]  <- if_else(str_starts(result, 'OK'), 'OK', 'FAILED')
  results$message[[i]] <- result
  cat(result, '\n\n')
}

cat('========== SUMMARY ==========\n')
cat('OK:    ', sum(results$status == 'OK'),     '\n')
cat('FAILED:', sum(results$status == 'FAILED'), '\n\n')

failed <- results %>% filter(status == 'FAILED')
if (nrow(failed) > 0) {
  cat('Failed scripts:\n')
  walk2(failed$script, failed$message, ~cat(' -', .x, '\n   ', .y, '\n'))
}
