# what's in the database now?
primary_sources <- df <- data.frame(
  ref_code = c(
    "Auld 1991",
    "Benson 1985",
    "Benwell 1998",
    "Bradstock Tozer Keith 1997",
    "Clark 1988",
    "Clarke Knox 2002",
    "Enright Goldblum Ata Ashton 1997",
    "Keith 1991",
    "Kirkpatrick 1984",
    "Lunt 1995",
    "Morgan 1996",
    "Morris 2000",
    "Morrison 1995",
    "Morrison Renwick 2000",
    "Myerscough Clarke Skelton 1995",
    "Purdie 1977",
    "Purdie Slatyer 1976",
    "Read Bellairs 1999",
    "Rice Westoby 1981",
    "Russell Parsons 1978",
    "Russell-Smith Ryan Klessa Waight Harwood",
    "Russell-Smith Ryan Klessa Waight Harwood 1998",
    "Specht Rayson Jackman 1958",
    "Tierney 2006",
    "Van Moezel Loneragan Bell 1987",
    "Wark 1997",
    "Wark White Robertson Marriott 1987",
    "Williams 2000",
    "Williams Ashton 1988",
    "Williams Congdon Grice Clarke 2003",
    "Wills Read 2007",
    "Wright Boyd Clarke Peter 2007"
  ),
  stringsAsFactors = FALSE
)

priority_traits <- c('germ1', 'germ8', 'grow1', 'surv1', 'surv4', 'surv5', 'surv6', 'surv7', 'rect2', 'repr2', 'repr3', 'repr3a', 'repr4', 'disp1')

# read the database
database <- read_csv('database.csv')

# seperate original_sources into a list of multiple sources
database$sources <- strsplit(gsub('[{"}]', "", database$original_sources), ",|; ")

# give database a column called sources which unnests records with multiple sources
database <- database %>%
  unnest(sources)

primary_sources <- left_join(primary_sources, database %>%
  filter(trait_code %in% priority_traits) %>%
  group_by(sources, trait_code) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = 'trait_code',
              values_from = 'count',
              values_fill = 0),
  by = c('ref_code' = 'sources'))

