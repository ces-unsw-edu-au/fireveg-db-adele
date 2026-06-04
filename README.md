# Fireveg Trait Import Pipeline

A reproducible pipeline for extracting plant fire-response traits from published literature and importing them into the fireveg PostgreSQL database (`litrev` schema).

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Fireveg Trait Import Pipeline</title>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<style>
  body {
    font-family: 'Segoe UI', Arial, sans-serif;
    background: #f4f6f8;
    margin: 0;
    padding: 40px 20px;
  }
  .container {
    max-width: 1100px;
    margin: 0 auto;
    background: white;
    border-radius: 12px;
    padding: 40px;
    box-shadow: 0 2px 16px rgba(0,0,0,0.10);
  }
  h1 {
    color: #2c3e50;
    font-size: 1.8em;
    margin-bottom: 4px;
  }
  .subtitle {
    color: #666;
    font-size: 1em;
    margin-bottom: 32px;
  }
  .legend {
    display: flex;
    gap: 24px;
    flex-wrap: wrap;
    margin-bottom: 28px;
    padding: 14px 18px;
    background: #f8f9fa;
    border-radius: 8px;
    font-size: 0.88em;
  }
  .legend-item {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .dot {
    width: 14px;
    height: 14px;
    border-radius: 3px;
    flex-shrink: 0;
  }
  /* Phase/subgraph dots — light fill + coloured border matching diagram subgraph outlines */
  .dot-phase-human  { background: #ebf5fb; border: 2px solid #85c1e9; }
  .dot-phase-claude { background: #f4ecf7; border: 2px solid #c39bd3; }
  .dot-phase-auto   { background: #eafaf1; border: 2px solid #82e0aa; }
  .dot-phase-db     { background: #fef5e7; border: 2px solid #e59866; }
  /* Individual node dots — solid */
  .dot-human  { background: #3498db; }
  .dot-claude { background: #8e44ad; }
  .dot-phase-output { background: #fef9e7; border: 2px solid #f7dc6f; }
  .dot-auto   { background: #27ae60; }
  .dot-grey   { background: #bdc3c7; }
  .dot-io     { background: #fef9e7; border: 2px solid #f7dc6f; }
  .legend-section {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
  }
  .legend-divider {
    width: 1px;
    height: 28px;
    background: #ddd;
    margin: 0 4px;
  }
  .legend-type {
    font-weight: 600;
    color: #555;
    white-space: nowrap;
    font-size: 0.82em;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }
  .mermaid-wrap {
    overflow-x: auto;
  }
</style>
</head>
<body>

<div class="container">
  <h1>Fireveg Trait Import Pipeline</h1>
  <p class="subtitle">Workflow for extracting plant fire-response traits from literature and importing into the fireveg PostgreSQL database</p>

  <div class="legend">
    <div class="legend-section">
      <span class="legend-type">Phases</span>
      <div class="legend-item"><div class="dot dot-io"></div> Inputs / Outputs</div>
      <div class="legend-item"><div class="dot dot-phase-human"></div> Human review</div>
      <div class="legend-item"><div class="dot dot-phase-claude"></div> AI-assisted</div>
      <div class="legend-item"><div class="dot dot-phase-auto"></div> Scripted</div>
      <div class="legend-item"><div class="dot dot-phase-db"></div> Database management</div>
    </div>
  </div>

  <div class="mermaid-wrap">
  <div class="mermaid">



flowchart TD

  A1["Primary Source PDFs"]

  subgraph SETUP["WRITE TRAIT MAPPING - once per paper"]
    direction TB
    B1["Paper folder\npapers/Author Year/"] 
    B3["update_mapping_db_counts.R\nCheck existing database record counts\nfor this source"]
    B2["<b>Create mapping.md</b>\nReview PDF · identify extractable traits\nPropose value mappings · note species exceptions\nExisting database record counts available in header"]
  end

  subgraph REVIEW["REVIEW TRAIT MAPPING"]
    direction TB
    D1{{"Set status per trait:\napproved  /  skip"}}
    D2["Trait not translated"]
  end

  subgraph EXTRACT["DATA EXTRACTION  —  Claude reads PDF"]
    direction TB
    E1{{"Does approved trait\nhave data in a table?"}}
    E2["Transcribe source table\nto CSV file"]
    E3["Species-level exceptions —\ncopy exceptions listed in mapping.md"]
    E4["Write R processing script"]
  end

  E2b["Review CSV\nCheck and fix any transcription issues"]

  subgraph PROCESS["PER PAPER R SCRIPT"]
    direction TB
    F1["Read CSV + mapping.md exceptions"]
    F2["Align species names\nto Bionet via match_bionet_taxonomy()"]
    F2b["report_unmatched()\nList species not matched to Bionet\n(dropped from records)"]
    F3["Apply value mappings\n(exceptions take priority over class mapping)"]
    F4["<b>Flag duplicates against\ndatabase.csv snapshot</b>\n(exact: source + value match\npartial: source matches · value differs\npossible: value matches · source: NA)"]
  end

  L1["Review TRAIT_LOGIC.md\nSanity check interpretation consistency\nacross papers before batch execution"]

  subgraph RUNALL["BATCH EXECUTION"]
    direction TB
    R1["run_all.R\nRuns all paper scripts sequentially\nLogs errors and warnings per script"]
    G1["records CSV\nnew trait records"]
    G2["dupes_exact_partial CSV\nclear duplicates"]
    G3["dupes_possible CSV\nfor manual review"]
  end

  subgraph COMBINE["AGGREGATE FILES ACROSS ALL PAPERS"]
    direction TB
    HC["combine.R"]
    H0["check_records()\nValidate each paper's records\nFlag vocab · parsing · duplicate issues"]
    H1["all_records.csv"]
    H2["all_dupes_exact_partial.csv"]
    H3["all_dupes_possible.csv"]
  end

  subgraph DB["DATABASE MANAGEMENT"]
    direction TB
    I1["Upload new records\nto litrev schema\n(PostgreSQL)"]
    I2["Set weight = 0\nfor duplicate records"]
    I3["Manual review of\npossible duplicates"]
  end

  A1 --> B1
  B1 & B3 --> B2

  B2 --> D1

  D1 -- "skip" --> D2
  D1 -- "approved" --> E1

  E1 -- "yes — table data" --> E2
  E1 -- "no, data in text / footnotes" --> E3
  E2 --> E2b
  E2b --> E4
  E3 --> E4

  E4 --> PROCESS
  L1 --> R1
  F1 --> F2
  F2 --> F2b
  F2b --> F3
  F3 --> F4

  PROCESS["R SCRIPT"] --> R1

  R1 --> G1 & G2 & G3

  G1 & G2 & G3 --> HC
  HC --> H0
  H0 --> H1
  HC --> H2
  HC --> H3

  H1 --> I1
  H2 --> I2
  H3 --> I3


  style SETUP   fill:#f4ecf7,stroke:#c39bd3,color:#1a252f
  style REVIEW  fill:#ebf5fb,stroke:#85c1e9,color:#1a252f
  style EXTRACT fill:#f4ecf7,stroke:#c39bd3,color:#1a252f
  style RUNALL  fill:#eafaf1,stroke:#82e0aa,color:#1a252f
  style PROCESS fill:#eafaf1,stroke:#82e0aa,color:#1a252f
  style COMBINE fill:#eafaf1,stroke:#82e0aa,color:#1a252f
  style DB      fill:#fef5e7,stroke:#e59866,color:#1a252f

  classDef plain fill:#ffffff,stroke:#000000,color:#2c3e50
  classDef output fill:#fef9e7,stroke:#f7dc6f,color:#1a252f
  class B1,B2,E2,E3,E4,F1,F2,F2b,F3,F4,H0,I1,I2,I3 plain
  class A1,G1,G2,G3,H1,H2,H3 output

  style D1  fill:#3498db,color:#fff,stroke:#2980b9
  style E1  fill:#8e44ad,color:#fff,stroke:#7d3c98
  style E2b fill:#ebf5fb,stroke:#85c1e9,color:#1a252f
  style L1  fill:#ebf5fb,stroke:#85c1e9,color:#1a252f
  style D2  fill:#bdc3c7,color:#2c3e50,stroke:#95a5a6
  style R1  fill:#27ae60,color:#fff,stroke:#219a52
  style HC  fill:#27ae60,color:#fff,stroke:#219a52
  style B3  fill:#27ae60,color:#fff,stroke:#219a52

  </div>
  </div>

<script>mermaid.initialize({ startOnLoad: true, theme: 'default', flowchart: { curve: 'basis' } });</script>
</body>
</html>


For an interactive version open `workflow.html` in a browser.

---

## What on earth is this?

A pipeline for extracting plant fire-response traits from published literature and importing them into the fireveg PostgreSQL database (`litrev` schema). 

This repository contains the **scripts, mapping files, and output records** for all papers processed so far. The intended use is ongoing: as new papers are identified, they can be added using the same workflow.

The pipeline uses a Claude AI agent to assist with reading PDFs, transcribing tables, and writing R scripts — but every decision is reviewed and approved by a human before any data is processed. 

---

## Repository structure

```
fireveg-db-adele/
├── README.md                         # this file
├── PIPELINE.md                       # step-by-step pipeline documentation for use by human AND AI
├── TRAIT_LOGIC.md                    # interpretation record — mapping decisions across all papers
├── workflow.html                     # full colour pipeline diagram (open in browser)
├── R/                                # shared R scripts
│   ├── funx.R                        # core functions: taxonomy matching, duplicate flagging, validation
│   ├── combine.R                     # aggregates paper outputs; validates; writes to outputs/
│   ├── run_all.R                     # batch runner — sources all paper scripts sequentially
│   ├── export_database.R             # exports database snapshot to data/database.csv
│   └── update_mapping_db_counts.R    # inserts DB record counts into mapping.md headers
├── data/
│   ├── bionet_species_with_apcalign_suggested_name.csv   # Bionet species list (required by funx.R)
│   └── database.csv                  # full database records to determine duplicates — not committed, run export_database.R to extract
├── outputs/                          # generated by combine.R 
│   ├── all_records.csv               # → ready for database upload
│   ├── all_dupes_exact_partial.csv   # → records to retire (set weight = 0)
│   └── all_dupes_possible.csv        # → possible duplicates for future review
└── papers/                           # one folder per source paper
    ├── completed_manually/           # papers processed before the pipeline was formalised
    └── Author Year/
        ├── mapping.md                # trait extraction spec and approval record
        ├── author_year_data.csv      # raw data transcribed from the paper
        ├── author_year.R             # processing script
        ├── author_year_records.csv           # new trait records (output)
        ├── author_year_dupes_exact_partial.csv  # confirmed duplicates (output)
        └── author_year_dupes_possible.csv       # possible duplicates (output)
```

---

## Getting started

### Prerequisites
- R (≥ 4.1) with packages: `tidyverse`, `APCalign`, `DBI`, `RPostgres`
- Access to the fireveg PostgreSQL database (credentials in `secrets/Renviron.local` — not committed)
- A Claude Pro subscription or API access (for AI-assisted steps)

### First-time setup

1. Clone this repository
2. Set up `secrets/Renviron.local` with database credentials 
3. Run `R/export_database.R` to generate `data/database.csv` — this is a snapshot of existing database records used for duplicate detection. It is not committed because it contains unpublished data; regenerate it whenever you need a fresh snapshot

---

## Running the existing scripts

All papers that have already been processed have R scripts and records CSVs in `papers/`. To regenerate the upload files:

```r
source('R/run_all.R')   # re-runs all paper scripts
source('R/combine.R')   # validates and aggregates into outputs/
```

The three files in `outputs/` are then ready for the database administrator:
- `all_records.csv` — new records to upload
- `all_dupes_exact_partial.csv` — existing records to retire (set weight = 0)
- `all_dupes_possible.csv` — review manually before deciding

---

## Adding a new paper


### Step 1 — Set up the paper folder

Create `papers/Author Year/`, add the PDF of the primary source. 

### Step 2 — Create mapping.md with Claude *(AI-assisted)*

Ask Claude to read the PIPELINE.md file to understand the workflow process, and read the PDF and produce a `mapping.md` file proposing:
- Which traits are extractable from this paper
- How source values map to the fireveg vocabulary (see `PIPELINE.md` for the trait vocabulary)
- Any species-level exceptions

Claude will set all trait statuses to `skip` by default.

### Step 3 — Review and approve the mapping *(human)*

Go through each trait section in `mapping.md` and:
- Change status to `approved` for traits you want to extract — verify the proposed value mapping makes ecological sense
- Leave as `skip` for traits that aren't extractable, aren't needed, or don't have strong enough evidence
- Fill in any `???` values Claude couldn't resolve
- Add, remove, or correct species-level exceptions
- Check the `**Evidence:**` line — does the mapping follow from what the paper actually says?


### Step 4 — Transcribe CSV and verify *(AI-assisted, then human)*

Ask Claude to read the PDF and transcribe the relevant table to CSV. Then **cross-check every cell against the paper yourself.** Transcription errors are the most common source of bad records.

### Step 5 — Generate the R script *(AI-assisted)*

Ask Claude to write the processing script using the approved mapping.md and CSV. It does this based on R scripts that were previously created as part of a manual process, which are templated in `PIPELINE.md`.  

### Step 6 - Review and run the R script *(human)*
Review the script — transcription notes at the top, and particularly the `case_when` logic — to confirm it correctly implements the approved mapping.

If you are adding several papers at one time, you can batch run all the R scripts created using:
```r
source('R/run_all.R')
```
Make sure you still review the scripts in batch running

### Step 7 — Aggregate the records *(human)*

```r
source('R/combine.R')
```
This will produce a combined file of records, and duplicates within the database.

Check the `check_records()` output in combine.R for any flagged issues.

---

## Tips for working with Claude

- Instruct Claude to read the `PIPELINE.md`, `TRAIT_LOGIC.md`, and other `mapping.md` files to get an understanding of the workflow before creating new mapping for the first time

- Claude can make errors in table transcription, especially with complex layouts — always verify the CSV yourself
- There are often some paper-specific-quirks that might come up. You'll need to manage these at the individual script level with Claude, but it often brings improvements to the system as a whole. Update PIPELINE.md or functions where necessary to account for features that might come up across multiple papers to keep improving the workflow.
---

## Key files explained

| File | Purpose |
|---|---|
| `PIPELINE.md` | Full pipeline documentation — read this before adding a new paper |
| `TRAIT_LOGIC.md` | Cross-paper record of how each trait was mapped — review before approving new mappings and before running scripts |
| `workflow.html` | Full colour visual diagram — open in any browser |
| `R/funx.R` | Core functions used by all scripts — taxonomy matching, duplicate flagging, record validation |
| `R/combine.R` | Aggregates all `*_records.csv` files; runs `check_records()` per paper; writes to `outputs/` |
| `R/run_all.R` | Sources all paper scripts in one go; catches and logs errors |
| `R/export_database.R` | Pulls current litrev records into `data/database.csv` for duplicate detection |
| `data/database.csv` | Not committed — generate with `export_database.R` before running |
