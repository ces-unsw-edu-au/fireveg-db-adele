# Williams 2000
# Traits: surv1, surv4, rect2, germ8
#
# TRANSCRIPTION NOTES — review before running:
#
# surv1 (williams_2000_surv1.csv — Table 2):
#   Priority rule: 1997 fire data used where n_individuals_1997 > 0;
#   1996 fire data used as fallback. The 1997 fire (Dec 1997, scorch height
#   14.6 m, intensity 890 kW/m) is described as moderate intensity and is
#   the approved proxy for full canopy scorch. Species with n=0 at 1997 sites
#   were not present there; 1996 data used for these.
#   Banksia aquilonia, Alstonia muelleriana, and Duboisia myoporoides show
#   >100% resprouting due to root suckering (footnote B in paper Table 2);
#   these map to All under the >90% threshold.
#   Several species had only raw resprout counts at Site 2 (no percentage
#   calculable) — these are excluded (NA in pct column).
#
# surv4: all species hardcoded from mapping.md exceptions table.
#   Source is Table 2 text and footnotes describing regenerative mode.
#   No multi-value cases identified in the exceptions table.
#
# rect2 (williams_2000_rect2.csv — Table 3):
#   Classification uses October 1998 seedling survey (Block 2 = last burnt
#   1996, Block 4 = last burnt 1997, Block 5 = unburnt >5 years).
#   Rule: Block 5 mean <= 0.02 AND max(Block2, Block4) > 0.05 -> Intolerant
#         Block 5 mean > 0.02 -> Tolerant
#   Species below threshold in all blocks are excluded (NA).
#
# germ8 (williams_2000_germ8.csv — Table 4):
#   Only species where heat INCREASES germination (heated > unheated, P<0.05)
#   are classified PY. This is the only classification this experiment supports
#   with confidence. Acacia cincinnata and Alphitonia petrei are PY.
#
#   Species where heat REDUCES germination (Melastoma affine, Poaceae spp.) and
#   species with inconsistent direction across blocks (Rhodomyrtus trineura) are
#   EXCLUDED. Reduced germination under heat rules out PY but does not confirm
#   any other dormancy class — the experiment did not test PD, smoke, light, or
#   after-ripening. Assigning ND to these species would overstate the evidence.
#
#   *** MAPPING NOTE: mapping.md originally listed Melastoma affine as PY.
#   Corrected per paper text (Results — Germinable soil seedbank, p.655-656):
#   "Soil seedbank germination of Melastoma affine, Rhodomyrtus trineura and
#   grasses (Poaceae) was significantly reduced by the application of heat."
#   Table 4 confirms: Block 2 Unheated=30.01 >> Heated=0.00;
#   Block 4 Unheated=56.68 >> Heated=10.00; ANOVA heat P=0.002. ***

library(tidyverse)
source('funx.R')

# ── surv1 ─────────────────────────────────────────────────────────────────────

# 1. Read surv1 data
surv1_data <- read.csv('papers/Williams 2000/williams_2000_surv1.csv')

# 2. Apply priority rule: prefer 1997 fire, fall back to 1996 fire
surv1_data <- surv1_data %>%
  mutate(
    pct_use = case_when(
      !is.na(n_individuals_1997) & n_individuals_1997 > 0 ~
        as.numeric(pct_resprouting_1997),
      !is.na(n_individuals_1996) & n_individuals_1996 > 0 ~
        as.numeric(pct_resprouting_1996),
      TRUE ~ NA_real_
    )
  )

# 3. Map surv1 norm_value from resprouting percentage thresholds
surv1_data <- surv1_data %>%
  mutate(
    surv1 = case_when(
      is.na(pct_use)                         ~ NA_character_,
      pct_use == 0                            ~ 'None',
      pct_use >   0 & pct_use <= 30          ~ 'Few',
      pct_use >  30 & pct_use <= 70          ~ 'Half',
      pct_use >  70 & pct_use <= 90          ~ 'Most',
      pct_use >  90                           ~ 'All',
      TRUE ~ NA_character_
    )
  )

# 4. Align taxonomy to Bionet
surv1_data <- match_bionet_taxonomy(surv1_data, 'species')
surv1_data$original_source <- 'Williams 2000'

# 5. Build surv1 long-format records
data_long_surv1 <- surv1_data %>%
  filter(!is.na(surv1)) %>%
  mutate(
    trait_code = 'surv1',
    norm_value = surv1,
    raw_value  = paste0(
      'Table 2: % resprouting=', pct_use,
      ' (fire used: ',
      if_else(!is.na(n_individuals_1997) & n_individuals_1997 > 0,
              'Dec 1997', 'Nov 1996'),
      ')'
    )
  )

# ── surv4 ─────────────────────────────────────────────────────────────────────

# All surv4 from mapping.md exceptions table (text/Table 2 footnotes)
surv4_exceptions <- tibble(
  original_name = c(
    'Alstonia muelleriana',
    'Banksia aquilonia',
    'Duboisia myoporoides',
    'Acacia flavescens',
    'Allocasuarina torulosa',
    'Alphitonia excelsa',
    'Eucalyptus intermedia',
    'Eucalyptus tereticornis',
    'Eucalyptus torelliana',
    'Callicarpa pendunculata',
    'Commersonia bertramia',
    'Glochidion sp.',
    'Melastoma affine',
    'Rhodomyrtus trineura'
  ),
  norm_value = c(
    'Long rhizome or root sucker',
    'Long rhizome or root sucker',
    'Long rhizome or root sucker',
    'Basal',
    'Basal',
    'Basal',
    'Epicormic',
    'Epicormic',
    'Epicormic',
    'Basal',
    'Basal',
    'Basal',
    'Basal',
    'Basal'
  ),
  raw_value = c(
    'Table 2/text: root suckering documented post-fire',
    'Table 2/text: root suckering documented post-fire',
    'Table 2/text: root suckering documented post-fire',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: sclerophyll tree >2 m — epicormic reshooting',
    'text: sclerophyll tree >2 m — epicormic reshooting',
    'text: sclerophyll tree >2 m — epicormic reshooting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting',
    'text: rainforest pioneer — basal stem and root resprouting'
  )
)

surv4_matched <- match_bionet_taxonomy(surv4_exceptions, 'original_name')
surv4_matched$original_source <- 'Williams 2000'

data_long_surv4 <- surv4_matched %>%
  mutate(trait_code = 'surv4')

# ── rect2 ─────────────────────────────────────────────────────────────────────

# Read rect2 data (Table 3, October 1998 survey)
rect2_data <- read.csv('papers/Williams 2000/williams_2000_rect2.csv')

# Classify from seedling density in burnt vs unburnt blocks
# Block 2 = burnt 1996; Block 4 = burnt 1997; Block 5 = unburnt >5 years
rect2_data <- rect2_data %>%
  mutate(
    rect2 = case_when(
      mean_seedlings_block5_1998 <= 0.02 &
        pmax(mean_seedlings_block2_1998, mean_seedlings_block4_1998) > 0.05 ~ 'Intolerant',
      mean_seedlings_block5_1998 > 0.02 ~ 'Tolerant',
      TRUE ~ NA_character_
    )
  )

rect2_data <- match_bionet_taxonomy(rect2_data, 'species')
rect2_data$original_source <- 'Williams 2000'

data_long_rect2 <- rect2_data %>%
  filter(!is.na(rect2)) %>%
  mutate(
    trait_code = 'rect2',
    norm_value = rect2,
    raw_value  = paste0(
      'Table 3 Oct 1998: Block2=', mean_seedlings_block2_1998,
      ', Block4=', mean_seedlings_block4_1998,
      ', Block5 (unburnt)=', mean_seedlings_block5_1998,
      ' seedlings/m2'
    )
  )

# ── germ8 ─────────────────────────────────────────────────────────────────────

# Read germ8 data (Table 4)
germ8_data <- read.csv('papers/Williams 2000/williams_2000_germ8.csv')

# Only retain species where heat increases germination -> PY
# Species where heat reduces or direction is inconsistent are excluded (see header notes)
germ8_data <- germ8_data %>%
  filter(heat_direction == 'increases') %>%
  mutate(germ8 = 'PY')

germ8_data <- match_bionet_taxonomy(germ8_data, 'species')
germ8_data$original_source <- 'Williams 2000'

data_long_germ8 <- germ8_data %>%
  filter(!is.na(germ8)) %>%
  mutate(
    trait_code = 'germ8',
    norm_value = germ8,
    raw_value  = paste0(
      'Table 4: Block2 heated=', block2_heated,
      ', Block2 unheated=', block2_unheated,
      ', Block4 heated=', block4_heated,
      ', Block4 unheated=', block4_unheated,
      '; ANOVA heat treatment p=', p_heat_treatment
    )
  )

# ── combine ───────────────────────────────────────────────────────────────────

# 7. Bind all traits
data_long <- bind_rows(
  data_long_surv1,
  data_long_surv4,
  data_long_rect2,
  data_long_germ8
)

# 8. Section 8 skipped — all traits are categorical.

# 9. Select final columns
report_unmatched(data_long)

records <- data_long %>%
  mutate(
    notes = coalesce(notes, NA_character_),
    best  = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  ) %>%
  select(bionet_name, species_code, original_source, trait_code,
         norm_value, best, lower, upper, raw_value, notes)

# 10. Save records and flag duplicates
records <- records %>% filter(!is.na(species_code))

write_csv(records, 'papers/Williams 2000/williams_2000_records.csv')

database <- read.csv('data/database.csv')
dupes <- flag_duplicates(records, database)

write_csv(dupes$exact_partial, 'papers/Williams 2000/williams_2000_dupes_exact_partial.csv')
write_csv(dupes$possible,      'papers/Williams 2000/williams_2000_dupes_possible.csv')

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
#   dbExecute(con, paste0("UPDATE litrev.surv4 SET weight = 0 WHERE record_id = ", id))
#   dbExecute(con, paste0("UPDATE litrev.rect2 SET weight = 0 WHERE record_id = ", id))
#   dbExecute(con, paste0("UPDATE litrev.germ8 SET weight = 0 WHERE record_id = ", id))
# }
# dbDisconnect(con)
