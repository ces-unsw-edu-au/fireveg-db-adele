# Williams Ashton 1988
# Traits: surv1, surv5
# surv4 — skip (status: skip in mapping.md)
#
# TRANSCRIPTION NOTES — review before running:
#
# 1. surv1 source: Table 3 (CSV). 7 species. "?" in root_stock for
#    Prostanthera cuneata and Orites lancifolia — paper does not assign a
#    definitive value. Both species have dormant_buds = "+" so surv1 = All
#    regardless of root_stock.
#
# 2. Grevillea australis and Asterolasia trymalioides have both dormant_buds
#    and root_stock absent ("-") — classified as None, consistent with mapping.md
#    exceptions table.
#
# 3. surv5 source: text (Discussion — Persistence and Longevity section).
#    Three species have usable age estimates. All hardcoded from text; no CSV.
#    Asterolasia trymalioides: ">40" — fenced since 1946, at least 40 years,
#    no signs of senescence at time of study. Phebalium squamulosum: "30-47" —
#    10 senescent individuals aged by ring analysis. Prostanthera cuneata:
#    "30-50" — stems dated at c. 30-50 years by ring structure.
#
# 4. This paper does not study fire response directly. surv1 is inferred from
#    morphological proxies (dormant buds, root stock) for resprouting capacity.
#    See TRAIT_LOGIC.md open question #1 on the "root stock" interpretation.

library(tidyverse)
source('funx.R')

# 1. Read data
data <- read.csv('papers/Williams Ashton 1988/williams_ashton_1988.csv')

# 2. No rename needed — CSV columns already R-friendly

# 3. No name cleaning needed — binomials are clean.

# 4. Map surv1: dormant_buds OR root_stock present -> All; both absent -> None
# "?" in root_stock is treated as unknown (not "+"), does not prevent All
# when dormant_buds = "+".
data <- data %>%
  mutate(
    surv1 = case_when(
      dormant_buds == '+' | root_stock == '+' ~ 'All',
      dormant_buds == '-' & root_stock == '-' ~ 'None',
      TRUE ~ NA_character_
    )
  )

# 5. Align taxonomy to Bionet
data <- match_bionet_taxonomy(data, 'species')
data$original_source <- 'Williams Ashton 1988'

# 6a. Build surv1 long-format records
data_long_surv1 <- data %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0('Table 3: Dormant buds=', dormant_buds,
                        '; Root stock=', root_stock)
  )

# 6b. Build surv5 records from text (exceptions only — no CSV)
surv5_exceptions <- tibble(
  original_name = c(
    'Phebalium squamulosum',
    'Prostanthera cuneata',
    'Asterolasia trymalioides'
  ),
  norm_value = c('30-47', '30-50', '>40'),
  raw_value  = c(
    'samples of the largest distinct stems from 10 senescent individuals ranged in age from 30 to 47 years',
    'stems c. 2-3 cm diameter which supported dense mature foliage have been dated at c. 30-50 years',
    'at least 40 years old, but are showing no signs of senescence (fenced since 1946)'
  )
)

surv5_matched <- match_bionet_taxonomy(surv5_exceptions, 'original_name')
surv5_matched$original_source <- 'Williams Ashton 1988'

data_long_surv5 <- surv5_matched %>%
  mutate(trait_code = 'surv5')

# 7. Bind all traits
data_long <- bind_rows(data_long_surv1, data_long_surv5)

# 8. Parse numerical bounds for surv5
data_long <- data_long %>%
  mutate(
    best = case_when(
      trait_code == 'surv5' & str_detect(norm_value, '^[0-9.]+$') ~
        as.numeric(norm_value),
      TRUE ~ NA_real_
    ),
    lower = case_when(
      trait_code == 'surv5' & str_detect(norm_value, '^>') ~
        as.numeric(str_extract(norm_value, '[0-9.]+')),
      trait_code == 'surv5' & str_detect(norm_value, '-') ~
        as.numeric(str_extract(norm_value, '^[0-9.]+')),
      TRUE ~ NA_real_
    ),
    upper = case_when(
      trait_code == 'surv5' & str_detect(norm_value, '^<') ~
        as.numeric(str_extract(norm_value, '[0-9.]+')),
      trait_code == 'surv5' & str_detect(norm_value, '-') ~
        as.numeric(str_extract(norm_value, '[0-9.]+$')),
      TRUE ~ NA_real_
    )
  )

# 9. Select final columns
report_unmatched(data_long)

records <- data_long %>%
  mutate(notes = coalesce(notes, NA_character_)) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates
records <- records %>% filter(!is.na(species_code))

write_csv(records, 'papers/Williams Ashton 1988/williams_ashton_1988_records.csv')

database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Williams Ashton 1988/williams_ashton_1988_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Williams Ashton 1988/williams_ashton_1988_dupes_possible.csv')

# SQL to set weight = 0 for exact/partial duplicate records
# Requires record_id in the database export. Run only if authorised to write to the database.
# library(DBI); library(RPostgres)
# readRenviron('secrets/Renviron.local')
# con <- dbConnect(Postgres(),
#                  dbname   = Sys.getenv("DBNAME"), host     = Sys.getenv("DBHOST"),
#                  port     = Sys.getenv("DBPORT"), user     = Sys.getenv("DBUSER"),
#                  password = Sys.getenv("DBPASSWORD"), sslmode = 'require')
# for (id in dupes$exact_partial$record_id) {
#   dbExecute(con, paste0("UPDATE litrev.surv1 SET weight = 0 WHERE record_id = ", id))
#   dbExecute(con, paste0("UPDATE litrev.surv5 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
