library(tidyverse)

priority_traits <- c('surv1', 'surv4', 'surv5', 'surv6', 'surv7',
                     'germ1', 'germ8', 'grow1', 'rect2',
                     'repr2', 'repr3', 'repr3a', 'repr4', 'disp1')

# read and process database
database <- read_csv('database.csv', show_col_types = FALSE)
database <- database %>%
  mutate(sources = strsplit(gsub('[{"}]', "", original_sources), ",|; ")) %>%
  unnest(sources) %>%
  mutate(sources = trimws(sources))

db_counts <- database %>%
  filter(trait_code %in% priority_traits) %>%
  group_by(sources, trait_code) %>%
  summarise(count = n(), .groups = 'drop')

mapping_files <- list.files('papers', pattern = '^mapping\\.md$',
                             recursive = TRUE, full.names = TRUE)

for (f in mapping_files) {
  lines <- readLines(f, warn = FALSE, encoding = 'UTF-8')

  # extract reference string
  ref_pat <- '^\\*\\*Reference string:\\*\\*'
  ref_idx <- grep(ref_pat, lines)[1]
  if (is.na(ref_idx)) { cat("No reference string found:", f, "\n"); next }
  ref_code <- trimws(gsub('.*`(.*)`.*', '\\1', lines[ref_idx]))

  # build counts lines
  sc <- db_counts %>% filter(sources == ref_code)
  if (nrow(sc) == 0) {
    counts_lines <- c("**Records in database:** none for this source in current export.", "")
  } else {
    counts_lines <- c(
      "**Records in database:**", "",
      "| Trait | n |",
      "|---|---|",
      paste0("| ", sc$trait_code, " | ", sc$count, " |"),
      ""
    )
  }

  # find first horizontal rule
  hr_idx <- which(lines == "---")[1]

  # keep only the header up to and including the reference string line,
  # stripping any existing counts block that may have been inserted previously
  header <- lines[1:ref_idx]

  # reassemble: header + blank + counts + rest from --- onwards
  new_lines <- c(header, "", counts_lines, lines[hr_idx:length(lines)])
  writeLines(new_lines, f)
  cat("Updated:", ref_code, "\n")
}
